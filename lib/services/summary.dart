import '../db/app_db.dart';
import '../models/models.dart';
import '../utils/calc.dart';
import '../utils/format.dart';

/// Order matters: index is used for sorting (higher = more urgent) and `good`
/// must sort last.
enum Severity { good, info, warn, urgent }

class ActionItem {
  final Severity severity;
  final String text;
  final int? campaignId;

  const ActionItem(this.severity, this.text, {this.campaignId});
}

/// The morning overview: action items plus headline numbers.
class DailyBrief {
  final List<ActionItem> items;
  final int activeCount;
  final double totalSpend;
  final double totalProfit;

  const DailyBrief({
    required this.items,
    required this.activeCount,
    required this.totalSpend,
    required this.totalProfit,
  });

  /// Items that actually need action (positives excluded).
  int get attentionCount =>
      items.where((i) => i.severity != Severity.good).length;
}

/// Builds the morning overview used by the Today screen and the 09:00
/// notification. Language is passed in (true = Turkish) because the
/// notification is built without a BuildContext.
class SummaryService {
  static String s(bool tr, String en, String trText) => tr ? trText : en;

  static Future<DailyBrief> build({
    required bool tr,
    required DateTime now,
  }) async {
    final db = AppDb.instance;
    final items = <ActionItem>[];

    // Keep the buckets correct: archive anything past its end date first.
    await db.archiveExpired();

    final campaigns = await db.getCampaigns();
    final today = DateTime(now.year, now.month, now.day);
    final missingEntry = await db.campaignsMissingEntryFor(today);

    int activeCount = 0;
    double totalSpend = 0, totalProfit = 0;

    for (final c in campaigns) {
      if (c.status == 'completed' || c.status == 'draft') continue;

      final metrics = await db.getMetrics(c.id!);
      final totals = CampaignTotals.from(c, metrics);
      final pacing = Pacing.compute(c, totals.spend, now);

      if (c.status == 'active') {
        activeCount++;
        totalSpend += totals.spend;
        totalProfit += totals.profit;
      }

      // Ending soon.
      final end = DateTime(c.endDate.year, c.endDate.month, c.endDate.day);
      final daysLeft = end.difference(today).inDays;
      if (daysLeft >= 0 && daysLeft <= 3 && c.status == 'active') {
        items.add(ActionItem(
          daysLeft == 0 ? Severity.urgent : Severity.warn,
          daysLeft == 0
              ? s(tr, '${c.name}: ends today — prepare the report.',
                  '${c.name}: bugün bitiyor — raporu hazırla.')
              : s(tr, '${c.name}: ends in $daysLeft day(s) — check it.',
                  '${c.name}: $daysLeft gün sonra bitiyor — kontrol et.'),
          campaignId: c.id,
        ));
      }

      // Paused but still within flight dates.
      if (c.status == 'paused' && !today.isAfter(end)) {
        items.add(ActionItem(
          Severity.warn,
          s(tr, '${c.name}: paused but still in flight — check why.',
              '${c.name}: duruyor ama tarih aralığında — neden durduğunu kontrol et.'),
          campaignId: c.id,
        ));
      }

      if (c.status != 'active') continue;

      // Today's data not entered yet (your daily routine).
      if (missingEntry.contains(c.id) &&
          !today.isBefore(DateTime(
              c.startDate.year, c.startDate.month, c.startDate.day))) {
        items.add(ActionItem(
          Severity.info,
          s(tr, '${c.name}: enter today\'s data.',
              '${c.name}: bugünün verisini gir.'),
          campaignId: c.id,
        ));
      }

      // Delivery pacing. When a volume goal is set, judge against the
      // target volume (±10% tolerance); otherwise fall back to budget pacing.
      final hasVolumeGoal = c.goalVolume != null && c.goalVolume! > 0;
      if (hasVolumeGoal) {
        _addVolumeDeliveryItem(items, c, totals, now, tr);
      } else if (pacing.state == PacingState.underpacing) {
        items.add(ActionItem(
          Severity.warn,
          s(
            tr,
            '${c.name}: underdelivering (${Fmt.money(totals.spend)} of ${Fmt.money(pacing.expectedSpend)} expected). Raise budget/bid or widen targeting.',
            '${c.name}: yavaş ilerliyor (beklenen ${Fmt.money(pacing.expectedSpend)} yerine ${Fmt.money(totals.spend)}). Bütçe/teklif artır ya da hedeflemeyi genişlet.',
          ),
          campaignId: c.id,
        ));
      } else if (pacing.state == PacingState.overpacing) {
        final endsMsg = pacing.budgetEndsOn != null
            ? ' ${s(tr, 'Budget runs out ~', 'Bütçe ~')}${Fmt.date(pacing.budgetEndsOn!)}.'
            : '';
        items.add(ActionItem(
          Severity.warn,
          s(
            tr,
            '${c.name}: overdelivering (${Fmt.money(totals.spend)} of ${Fmt.money(pacing.expectedSpend)} expected).$endsMsg Lower the daily cap.',
            '${c.name}: çok hızlı ilerliyor (beklenen ${Fmt.money(pacing.expectedSpend)} yerine ${Fmt.money(totals.spend)}).$endsMsg Günlük limiti düşür.',
          ),
          campaignId: c.id,
        ));
      }

      // Performance vs KPI efficiency target (CPM/CPC/ROAS…).
      _addPerformanceItem(items, c, totals, tr);
    }

    // Tasks due today or overdue.
    final tasks = await db.getTasks(openOnly: true);
    for (final t in tasks) {
      if (t.dueDate == null) continue;
      final due = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      if (due.isAfter(today)) continue;
      final overdue = due.isBefore(today);
      items.add(ActionItem(
        overdue ? Severity.urgent : Severity.info,
        overdue
            ? s(tr, 'Overdue task: ${t.title}', 'Geciken görev: ${t.title}')
            : s(tr, 'Task due today: ${t.title}', 'Bugün son tarih: ${t.title}'),
        campaignId: t.campaignId,
      ));
    }

    // Sort by severity (urgent first, positives last).
    items.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return DailyBrief(
      items: items,
      activeCount: activeCount,
      totalSpend: totalSpend,
      totalProfit: totalProfit,
    );
  }

  /// Judge delivery against the target volume. Up to +10% over is fine; more
  /// than that is over-delivery, and pacing below 90% is under-delivery.
  static void _addVolumeDeliveryItem(
    List<ActionItem> items,
    Campaign c,
    CampaignTotals totals,
    DateTime now,
    bool tr,
  ) {
    final goal = c.goalVolume!;
    final delivered = totals.deliveredVolume(c.pricingType);
    final projected =
        Calc.projectFinal(delivered, c.startDate, c.endDate, now);
    if (projected <= 0) return;
    final unit = volumeUnitLabel(volumeUnitFor(c.pricingType), tr);
    final ratio = projected / goal;
    final projC = Fmt.compact(projected);
    final goalC = Fmt.compact(goal);

    if (ratio > 1.10) {
      final pct = ((ratio - 1) * 100).round();
      items.add(ActionItem(
        Severity.warn,
        s(tr,
            '${c.name}: on pace to over-deliver $unit by $pct% (proj. $projC vs target $goalC). Cap delivery or lower the budget.',
            '${c.name}: $unit hedefini %$pct aşacak gidişatta (tahmini $projC, hedef $goalC). Teslimi sınırla ya da bütçeyi düşür.'),
        campaignId: c.id,
      ));
    } else if (ratio < 0.90) {
      final pct = ((1 - ratio) * 100).round();
      items.add(ActionItem(
        Severity.warn,
        s(tr,
            '${c.name}: on pace to under-deliver $unit by $pct% (proj. $projC vs target $goalC). Push delivery.',
            '${c.name}: $unit hedefinin %$pct altında kalacak gidişatta (tahmini $projC, hedef $goalC). Teslimi hızlandır.'),
        campaignId: c.id,
      ));
    }
  }

  /// Compare the campaign's headline metric to its target and flag when it is
  /// running expensive (optimize) or beating the target (doing well).
  static void _addPerformanceItem(
    List<ActionItem> items,
    Campaign c,
    CampaignTotals totals,
    bool tr,
  ) {
    final target = c.kpiTarget;
    if (target == null || target <= 0 || totals.spend <= 0) return;
    final pm = totals.primaryMetric(c.pricingType);
    final val = pm.value;
    if (val <= 0) return;

    final fmtVal = Fmt.byUnit(pm.unit, val);
    final fmtTgt = Fmt.byUnit(pm.unit, target);
    final ratio = val / target;

    if (c.pricingType == 'ROAS') {
      // Higher is better.
      if (ratio < 0.85) {
        items.add(ActionItem(
          Severity.warn,
          s(tr,
              '${c.name}: ROAS $fmtVal vs target $fmtTgt — underperforming. Optimize creatives/audiences.',
              '${c.name}: ROAS $fmtVal, hedef $fmtTgt — hedefin altında. Kreatif/kitle optimize et.'),
          campaignId: c.id,
        ));
      } else if (ratio > 1.1) {
        items.add(ActionItem(
          Severity.good,
          s(tr,
              '${c.name}: ROAS $fmtVal above target $fmtTgt — consider scaling budget.',
              '${c.name}: ROAS $fmtVal, hedef $fmtTgt üstünde — bütçeyi artırmayı düşün.'),
          campaignId: c.id,
        ));
      }
    } else {
      // Cost metric — lower is better.
      final overPct = ((ratio - 1) * 100).round();
      if (ratio > 1.15) {
        items.add(ActionItem(
          Severity.warn,
          s(tr,
              '${c.name}: ${pm.label} $fmtVal vs target $fmtTgt — $overPct% over. Optimize: pause weak placements/creatives or lower the bid.',
              '${c.name}: ${pm.label} $fmtVal, hedef $fmtTgt — hedefin %$overPct üstünde. Optimize et: zayıf placement/kreatifleri durdur ya da teklifi düşür.'),
          campaignId: c.id,
        ));
      } else if (ratio < 0.9) {
        items.add(ActionItem(
          Severity.good,
          s(tr, '${c.name}: ${pm.label} $fmtVal beating target $fmtTgt — looking good.',
              '${c.name}: ${pm.label} $fmtVal, hedef $fmtTgt altında — iyi gidiyor.'),
          campaignId: c.id,
        ));
      }
    }
  }

  /// Build the notification title + body from a brief.
  static (String, String) notificationText(DailyBrief brief, bool tr) {
    final title =
        s(tr, 'Good morning — today\'s overview', 'Günaydın — bugünün özeti');
    final attention =
        brief.items.where((i) => i.severity != Severity.good).toList();
    if (attention.isEmpty) {
      final positives = brief.items.length;
      if (positives > 0) {
        return (
          title,
          s(tr, 'All on track. $positives campaign(s) performing well.',
              'Her şey yolunda. $positives kampanya iyi gidiyor.')
        );
      }
      return (
        title,
        s(tr, 'All clear. No actions needed today.',
            'Her şey yolunda. Bugün aksiyon gerekmiyor.')
      );
    }
    final top = attention.take(4).map((e) => '• ${e.text}').join('\n');
    final more = attention.length > 4
        ? '\n${s(tr, '+${attention.length - 4} more', '+${attention.length - 4} tane daha')}'
        : '';
    return (title, '$top$more');
  }
}
