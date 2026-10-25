import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n.dart';
import '../services/summary.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/ui.dart';
import 'backup_screen.dart';
import 'campaign_detail_screen.dart';
import 'settings_screen.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  Future<DailyBrief>? _future;
  Locale? _loadedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The brief text is language-specific; reload it when the language
    // changes (the tab is kept alive in an IndexedStack).
    final locale = Localizations.localeOf(context);
    if (_loadedLocale != locale) {
      _loadedLocale = locale;
      _future = _load();
    }
  }

  Future<DailyBrief> _load() {
    final isTr = L10n.of(context).isTr;
    return SummaryService.build(tr: isTr, now: DateTime.now());
  }

  void _refresh() => setState(() {
        _future = _load();
      });

  Color _color(BuildContext c, Severity s) {
    final p = c.palette;
    switch (s) {
      case Severity.urgent:
        return p.danger;
      case Severity.warn:
        return p.warn;
      case Severity.info:
        return p.accent;
      case Severity.good:
        return p.success;
    }
  }

  IconData _icon(Severity s) {
    switch (s) {
      case Severity.urgent:
        return Icons.priority_high_rounded;
      case Severity.warn:
        return Icons.bolt_rounded;
      case Severity.info:
        return Icons.edit_note_rounded;
      case Severity.good:
        return Icons.trending_up_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: FutureBuilder<DailyBrief>(
            future: _future,
            builder: (context, snap) {
              final brief = snap.data;
              final items = brief?.items ?? const <ActionItem>[];
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _hero(context, brief)),
                  if (brief == null)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _allClear(context),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      sliver: SliverList.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) =>
                            _actionCard(context, items[i]),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context, DailyBrief? brief) {
    final l = L10n.of(context);
    final p = context.palette;
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? l.s('Good morning', 'Günaydın')
        : hour < 18
            ? l.s('Good afternoon', 'İyi günler')
            : l.s('Good evening', 'İyi akşamlar');
    final dateStr = DateFormat('EEEE, d MMMM', l.isTr ? 'tr' : 'en').format(now);
    final count = brief?.attentionCount ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateStr.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                          color: p.muted,
                        )),
                    const SizedBox(height: 4),
                    Text(greeting,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.05,
                        )),
                  ],
                ),
              ),
              _circleButton(context, Icons.settings_outlined, () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
                _refresh();
              }),
              const SizedBox(width: 8),
              _circleButton(context, Icons.settings_backup_restore_rounded,
                  () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BackupScreen()),
                );
                _refresh();
              }),
              const SizedBox(width: 8),
              _circleButton(context, Icons.refresh_rounded, _refresh),
            ],
          ),
          const SizedBox(height: 14),
          if (brief != null) ...[
            _overviewStrip(context, brief),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: count == 0
                    ? p.success.withValues(alpha: 0.10)
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    count == 0
                        ? Icons.check_circle_rounded
                        : Icons.flag_rounded,
                    size: 18,
                    color: count == 0
                        ? p.success
                        : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    count == 0
                        ? l.s('All clear today', 'Bugün her şey yolunda')
                        : l.s('$count thing(s) need attention',
                            '$count şey dikkat istiyor'),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: count == 0
                          ? p.success
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Compact overview: active campaigns, total spend and total profit.
  Widget _overviewStrip(BuildContext context, DailyBrief brief) {
    final l = L10n.of(context);
    return PanelCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: StatTile(
                label: l.s('Active', 'Aktif'),
                value: '${brief.activeCount}'),
          ),
          Expanded(
            child: StatTile(
                label: l.s('Spend', 'Harcama'),
                value: Fmt.money(brief.totalSpend)),
          ),
          Expanded(
            child: StatTile(
              label: l.s('Profit', 'Kâr'),
              value: Fmt.money(brief.totalProfit),
              valueColor: context.palette.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(
      BuildContext context, IconData icon, VoidCallback onTap) {
    final p = context.palette;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: CircleBorder(side: BorderSide(color: p.line)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: p.ink),
        ),
      ),
    );
  }

  Widget _actionCard(BuildContext context, ActionItem item) {
    final color = _color(context, item.severity);
    return PanelCard(
      padding: const EdgeInsets.all(14),
      onTap: item.campaignId == null
          ? null
          : () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CampaignDetailScreen(campaignId: item.campaignId!),
                ),
              );
              _refresh();
            },
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(_icon(item.severity), size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.text,
                style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 14, height: 1.35)),
          ),
          if (item.campaignId != null)
            Icon(Icons.chevron_right_rounded, color: context.palette.muted),
        ],
      ),
    );
  }

  Widget _allClear(BuildContext context) {
    final l = L10n.of(context);
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: p.success.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.coffee_rounded, size: 48, color: p.success),
          ),
          const SizedBox(height: 18),
          Text(l.s('Nothing on fire', 'Yangın yok'),
              style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              l.s('No pacing issues, deadlines or pending entries today.',
                  'Bugün pacing sorunu, deadline ya da bekleyen giriş yok.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Inter', color: p.muted, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
