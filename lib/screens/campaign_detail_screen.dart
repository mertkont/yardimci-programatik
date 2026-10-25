import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../db/app_db.dart';
import '../l10n/l10n.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/calc.dart';
import '../utils/format.dart';
import '../widgets/status_helpers.dart';
import '../widgets/trend_chart.dart';
import '../widgets/ui.dart';
import 'campaign_form_screen.dart';
import 'daily_metric_form.dart';

class _Data {
  final Campaign campaign;
  final List<DailyMetric> metrics;
  final List<Attachment> attachments;
  final List<TaskItem> tasks;
  final List<ActivityLog> activity;
  final Map<String, ChecklistState> checklist;
  final CampaignTotals totals;
  final Pacing pacing;
  _Data(this.campaign, this.metrics, this.attachments, this.tasks,
      this.activity, this.checklist, this.totals, this.pacing);
}

class CampaignDetailScreen extends StatefulWidget {
  final int campaignId;
  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  late Future<_Data?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Data?> _load() async {
    final db = AppDb.instance;
    final c = await db.getCampaign(widget.campaignId);
    if (c == null) return null;
    final metrics = await db.getMetrics(c.id!);
    final attachments = await db.getAttachments(c.id!);
    final tasks = await db.getTasksForCampaign(c.id!);
    final activity = await db.getActivityLog(c.id!);
    final checklist = await db.getChecklist(c.id!);
    final totals = CampaignTotals.from(c, metrics);
    final pacing = Pacing.compute(c, totals.spend, DateTime.now());
    return _Data(
        c, metrics, attachments, tasks, activity, checklist, totals, pacing);
  }

  void _refresh() => setState(() {
        _future = _load();
      });

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return FutureBuilder<_Data?>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final d = snap.data;
        if (d == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l.s('Not found', 'Bulunamadı'))),
          );
        }
        return DefaultTabController(
          length: 5,
          child: Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _addOrEditMetric(d.campaign, null),
              icon: const Icon(Icons.add_chart_rounded),
              label: Text(l.s('Add data', 'Veri gir')),
            ),
            appBar: AppBar(
              title: Text(d.campaign.name,
                  style: const TextStyle(fontSize: 18)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CampaignFormScreen(existing: d.campaign),
                      ),
                    );
                    _refresh();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDeleteCampaign(d.campaign),
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(text: l.s('Overview', 'Genel')),
                  Tab(text: l.s('Trends', 'Grafikler')),
                  Tab(text: l.s('Daily', 'Günlük')),
                  Tab(text: l.s('History', 'Geçmiş')),
                  Tab(text: l.s('Files', 'Dosyalar')),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                ListView(
                  padding: const EdgeInsets.only(top: 6, bottom: 96),
                  children: [
                    _infoCard(d),
                    _pacingCard(d),
                    _metricsCard(d),
                    _tasksSection(d),
                  ],
                ),
                _TrendsTab(campaign: d.campaign, metrics: d.metrics),
                ListView(
                  padding: const EdgeInsets.only(top: 6, bottom: 96),
                  children: [_dailySection(d)],
                ),
                ListView(
                  padding: const EdgeInsets.only(top: 6, bottom: 96),
                  children: [_checklistSection(d), _activitySection(d)],
                ),
                ListView(
                  padding: const EdgeInsets.only(top: 6, bottom: 96),
                  children: [_filesSection(d)],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---- Cards --------------------------------------------------------------
  Widget _infoCard(_Data d) {
    final l = L10n.of(context);
    final c = d.campaign;
    return _section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv('${c.client} · ${c.platform}', ''),
          _kv(l.s('Type', 'Tip'), c.pricingType),
          _kv(l.s('Dates', 'Tarihler'),
              '${Fmt.date(c.startDate)} – ${Fmt.date(c.endDate)}'),
          _kv(l.s('Media budget', 'Medya bütçesi'), Fmt.money(c.totalBudget)),
          if (c.usesRealBudget)
            _kv(l.s('Client budget', 'Müşteri bütçesi'),
                Fmt.money(c.realBudget!)),
          _kv(l.s('Status', 'Durum'), c.status),
          if (c.objective.isNotEmpty)
            _kv(l.s('Objective', 'Hedef'), c.objective),
          if (c.notes.isNotEmpty) _kv(l.s('Notes', 'Notlar'), c.notes),
        ],
      ),
    );
  }

  Widget _pacingCard(_Data d) {
    final l = L10n.of(context);
    final p0 = d.pacing;
    final barColor = pacingColor(context, p0.state);
    final expectedFrac = d.campaign.totalBudget > 0
        ? p0.expectedSpend / d.campaign.totalBudget
        : 0.0;
    return _section(
      title: l.s('Pacing', 'Pacing'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusPill(
                  label: pacingLabel(l, p0.state), color: barColor),
              Text(
                  p0.state == PacingState.ended
                      ? l.s('ended', 'bitti')
                      : '${p0.daysLeft} ${l.s('days left', 'gün kaldı')}',
                  style: TextStyle(
                      fontFamily: 'Inter', color: context.palette.muted)),
            ],
          ),
          const SizedBox(height: 14),
          PacingGauge(
            spentFraction: p0.spentFraction(d.campaign.totalBudget),
            expectedFraction: expectedFrac,
            color: barColor,
          ),
          const SizedBox(height: 14),
          _kv(l.s('Spent', 'Harcanan'),
              '${Fmt.money(p0.actualSpend)} / ${Fmt.money(d.campaign.totalBudget)}'),
          _kv(l.s('Expected by today', 'Bugüne kadar beklenen'),
              Fmt.money(p0.expectedSpend)),
          if (p0.budgetEndsOn != null)
            _kv(l.s('Budget runs out ~', 'Bütçe biter ~'),
                Fmt.date(p0.budgetEndsOn!)),
          ..._deliveryRows(d),
        ],
      ),
    );
  }

  Widget _metricsCard(_Data d) {
    final l = L10n.of(context);
    final t = d.totals;
    final primary = t.primaryMetric(d.campaign.pricingType);
    return _section(
      title: l.s('Metrics (total)', 'Metrikler (toplam)'),
      child: Column(
        children: [
          Row(
            children: [
              _bigStat(primary.label, Fmt.byUnit(primary.unit, primary.value),
                  highlight: true),
              _bigStat(
                  '${l.s('Profit', 'Kâr')} · ${Fmt.pct(t.marginPercent)}',
                  Fmt.money(t.profit)),
            ],
          ),
          const Divider(height: 24),
          Wrap(
            spacing: 18,
            runSpacing: 12,
            children: [
              _smallStat('CPM', Fmt.money4(Calc.cpm(t.spend, t.impressions))),
              _smallStat('CPC', Fmt.money4(Calc.cpc(t.spend, t.clicks))),
              _smallStat('CTR', Fmt.pct(Calc.ctr(t.clicks, t.impressions))),
              _smallStat('CPV', Fmt.money4(Calc.cpv(t.spend, t.views))),
              _smallStat(
                  'CPCV', Fmt.money4(Calc.cpcv(t.spend, t.completedViews))),
              _smallStat('VCR', Fmt.pct(Calc.vcr(t.completedViews, t.views))),
              _smallStat(l.s('View%', 'Görün%'),
                  Fmt.pct(Calc.viewability(t.viewableImpressions, t.impressions))),
              if (t.revenue > 0)
                _smallStat('ROAS', Fmt.mult(Calc.roas(t.revenue, t.spend))),
              _smallStat(l.s('Impr.', 'Gösterim'), Fmt.num0(t.impressions)),
              _smallStat(l.s('Clicks', 'Tıklama'), Fmt.num0(t.clicks)),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Daily entries ------------------------------------------------------
  Widget _dailySection(_Data d) {
    final l = L10n.of(context);
    return _section(
      title: l.s('Daily entries', 'Günlük girişler'),
      trailing: TextButton.icon(
        onPressed: () => _addOrEditMetric(d.campaign, null),
        icon: const Icon(Icons.add),
        label: Text(l.s('Add', 'Ekle')),
      ),
      child: d.metrics.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: Text(l.s('No entries yet.', 'Henüz giriş yok.')),
            )
          : Column(
              children: d.metrics.map((m) {
                final metricLine =
                    'CPM ${Fmt.money4(Calc.cpm(m.spend, m.impressions))} · '
                    'CTR ${Fmt.pct(Calc.ctr(m.clicks, m.impressions))}';
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                      '${Fmt.date(m.date)} — ${Fmt.money(m.spend)}'),
                  subtitle: Text(
                      '${Fmt.num0(m.impressions)} impr · $metricLine'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _addOrEditMetric(d.campaign, m);
                      if (v == 'delete') _deleteMetric(m);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                          value: 'edit', child: Text(l.s('Edit', 'Düzenle'))),
                      PopupMenuItem(
                          value: 'delete', child: Text(l.s('Delete', 'Sil'))),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Future<void> _addOrEditMetric(Campaign c, DailyMetric? m) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DailyMetricForm(campaign: c, existing: m),
      ),
    );
    _refresh();
  }

  Future<void> _deleteMetric(DailyMetric m) async {
    await AppDb.instance.deleteMetric(m.id!);
    _refresh();
  }

  // ---- Files (ordino / creatives) ----------------------------------------
  Widget _filesSection(_Data d) {
    final l = L10n.of(context);
    return _section(
      title: l.s('Files (ordino, creatives)', 'Dosyalar (ordino, kreatif)'),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.attach_file),
        onSelected: (type) => _addAttachment(d.campaign.id!, type),
        itemBuilder: (_) => [
          PopupMenuItem(value: 'ordino', child: Text(l.s('Ordino', 'Ordino'))),
          PopupMenuItem(
              value: 'creative', child: Text(l.s('Creative', 'Kreatif'))),
          PopupMenuItem(value: 'other', child: Text(l.s('Other', 'Diğer'))),
        ],
      ),
      child: d.attachments.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: Text(l.s('No files attached.', 'Dosya eklenmemiş.')),
            )
          : Column(
              children: d.attachments.map((a) {
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(_fileIcon(a.type)),
                  title: Text(a.fileName,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(a.type),
                  onTap: () => OpenFilex.open(a.filePath),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteAttachment(a),
                  ),
                );
              }).toList(),
            ),
    );
  }

  IconData _fileIcon(String type) {
    switch (type) {
      case 'ordino':
        return Icons.description;
      case 'creative':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _addAttachment(int campaignId, String type) async {
    final result = await FilePicker.pickFiles();
    if (result == null || result.files.single.path == null) return;
    final src = File(result.files.single.path!);
    final docs = await getApplicationDocumentsDirectory();
    final destDir = Directory(p.join(docs.path, 'attachments', '$campaignId'));
    if (!await destDir.exists()) await destDir.create(recursive: true);
    final fileName = p.basename(src.path);
    final dest = File(p.join(destDir.path, fileName));
    await src.copy(dest.path);
    await AppDb.instance.insertAttachment(Attachment(
      campaignId: campaignId,
      type: type,
      fileName: fileName,
      filePath: dest.path,
      addedAt: DateTime.now(),
    ));
    _refresh();
  }

  Future<void> _deleteAttachment(Attachment a) async {
    try {
      final f = File(a.filePath);
      if (await f.exists()) await f.delete();
    } catch (_) {}
    await AppDb.instance.deleteAttachment(a.id!);
    _refresh();
  }

  // ---- Tasks --------------------------------------------------------------
  Widget _tasksSection(_Data d) {
    final l = L10n.of(context);
    return _section(
      title: l.s('Tasks', 'Görevler'),
      trailing: TextButton.icon(
        onPressed: () => _addTask(d.campaign.id!),
        icon: const Icon(Icons.add),
        label: Text(l.s('Add', 'Ekle')),
      ),
      child: d.tasks.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: Text(l.s('No tasks.', 'Görev yok.')),
            )
          : Column(
              children: d.tasks.map((t) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: t.done,
                  title: Text(
                    t.title,
                    style: t.done
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough)
                        : null,
                  ),
                  subtitle: t.dueDate != null
                      ? Text(Fmt.date(t.dueDate!))
                      : null,
                  onChanged: (v) async {
                    await AppDb.instance
                        .updateTask(t.copyWith(done: v ?? false));
                    _refresh();
                  },
                  secondary: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await AppDb.instance.deleteTask(t.id!);
                      _refresh();
                    },
                  ),
                );
              }).toList(),
            ),
    );
  }

  Future<void> _addTask(int campaignId) async {
    final l = L10n.of(context);
    final controller = TextEditingController();
    DateTime? due;
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(l.s('New task', 'Yeni görev')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                    hintText: l.s('Task title', 'Görev başlığı')),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(due == null
                        ? l.s('No due date', 'Son tarih yok')
                        : Fmt.date(due!)),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) setS(() => due = picked);
                    },
                    child: Text(l.s('Pick date', 'Tarih seç')),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.s('Cancel', 'İptal'))),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.s('Save', 'Kaydet'))),
          ],
        ),
      ),
    );
    if (saved == true && controller.text.trim().isNotEmpty) {
      await AppDb.instance.insertTask(TaskItem(
        campaignId: campaignId,
        title: controller.text.trim(),
        dueDate: due,
      ));
      _refresh();
    }
  }

  // ---- Setup checklist ----------------------------------------------------
  Widget _checklistSection(_Data d) {
    final l = L10n.of(context);
    final tr = l.isTr;
    final p = context.palette;
    final doneCount =
        kChecklistSteps.where((k) => d.checklist[k]?.done ?? false).length;
    return _section(
      title: l.s('Setup checklist', 'Kurulum listesi'),
      trailing: Text('$doneCount/${kChecklistSteps.length}',
          style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w600,
              color: p.muted)),
      child: Column(
        children: kChecklistSteps.map((key) {
          final st = d.checklist[key];
          final isDone = st?.done ?? false;
          final doneAt = st?.doneAt;
          return CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: isDone,
            title: Text(
              checklistStepLabel(key, tr),
              style: isDone
                  ? TextStyle(
                      decoration: TextDecoration.lineThrough, color: p.muted)
                  : null,
            ),
            subtitle: isDone && doneAt != null
                ? Text(
                    l.s('Done ${Fmt.date(doneAt)}',
                        '${Fmt.date(doneAt)} işaretlendi'),
                    style: TextStyle(fontSize: 12, color: p.success),
                  )
                : null,
            onChanged: (v) async {
              await AppDb.instance
                  .setChecklistStep(d.campaign.id!, key, v ?? false);
              _refresh();
            },
          );
        }).toList(),
      ),
    );
  }

  // ---- Activity log -------------------------------------------------------
  Widget _activitySection(_Data d) {
    final l = L10n.of(context);
    return _section(
      title: l.s('Activity log', 'İşlem geçmişi'),
      trailing: TextButton.icon(
        onPressed: () => _addActivity(d.campaign.id!),
        icon: const Icon(Icons.add),
        label: Text(l.s('Add', 'Ekle')),
      ),
      child: d.activity.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: Text(l.s(
                  'No history yet. Log what you did and the day you did it.',
                  'Henüz kayıt yok. Ne yaptığını ve hangi gün yaptığını not al.')),
            )
          : Column(
              children: [for (final a in d.activity) _activityTile(a)],
            ),
    );
  }

  Widget _activityTile(ActivityLog a) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Fmt.date(a.date),
                    style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: p.ink)),
                const SizedBox(height: 2),
                Text(a.text,
                    style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 14, height: 1.35)),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              await AppDb.instance.deleteActivity(a.id!);
              _refresh();
            },
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, size: 18, color: p.muted),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addActivity(int campaignId) async {
    final l = L10n.of(context);
    final controller = TextEditingController();
    DateTime date = DateTime.now();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(l.s('Log activity', 'İşlem ekle')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                    hintText: l.s('What did you do?',
                        'Ne yaptın? (ör. bütçe %20 artırıldı)')),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.event, size: 18, color: context.palette.muted),
                  const SizedBox(width: 8),
                  Expanded(child: Text(Fmt.date(date))),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) setS(() => date = picked);
                    },
                    child: Text(l.s('Change date', 'Tarih değiştir')),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.s('Cancel', 'İptal'))),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.s('Save', 'Kaydet'))),
          ],
        ),
      ),
    );
    if (saved == true && controller.text.trim().isNotEmpty) {
      await AppDb.instance.insertActivity(ActivityLog(
        campaignId: campaignId,
        date: date,
        text: controller.text.trim(),
        createdAt: DateTime.now(),
      ));
      _refresh();
    }
  }

  // ---- Delete campaign ----------------------------------------------------
  Future<void> _confirmDeleteCampaign(Campaign c) async {
    final l = L10n.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.s('Delete campaign?', 'Kampanya silinsin mi?')),
        content: Text(l.s(
            'This removes the campaign and all its data.',
            'Bu, kampanyayı ve tüm verilerini siler.')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.s('Cancel', 'İptal'))),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.s('Delete', 'Sil'))),
        ],
      ),
    );
    if (ok == true) {
      await AppDb.instance.deleteCampaign(c.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  // ---- Small UI helpers ---------------------------------------------------
  Widget _section({String? title, Widget? trailing, required Widget child}) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleMedium),
                  ?trailing,
                ],
              ),
            if (title != null) const SizedBox(height: 4),
            child,
          ],
        ),
      ),
    );
  }

  /// Delivery-vs-target rows shown when the campaign has a volume goal.
  List<Widget> _deliveryRows(_Data d) {
    final c = d.campaign;
    if (c.goalVolume == null || c.goalVolume! <= 0) return const [];
    final l = L10n.of(context);
    final p = context.palette;
    final unit = volumeUnitLabel(volumeUnitFor(c.pricingType), l.isTr);
    final delivered = d.totals.deliveredVolume(c.pricingType);
    final projected =
        Calc.projectFinal(delivered, c.startDate, c.endDate, DateTime.now());
    final goal = c.goalVolume!;
    final ratio = goal > 0 ? projected / goal : 0.0;

    Color projColor = p.success;
    String tag = '';
    if (ratio > 1.10) {
      projColor = p.danger;
      tag = ' (+${((ratio - 1) * 100).round()}%)';
    } else if (ratio < 0.90) {
      projColor = p.warn;
      tag = ' (-${((1 - ratio) * 100).round()}%)';
    }

    return [
      _kv(l.s('Delivered ($unit)', 'Teslim ($unit)'),
          '${Fmt.compact(delivered)} / ${Fmt.compact(goal)}'),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(l.s('Projected', 'Tahmini teslim'),
                  style: TextStyle(color: Theme.of(context).hintColor)),
            ),
            Expanded(
              child: Text('${Fmt.compact(projected)}$tag',
                  style: TextStyle(
                      color: projColor, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(k,
                style: TextStyle(color: Theme.of(context).hintColor)),
          ),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  Widget _bigStat(String label, String value, {bool highlight = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: highlight
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    fontWeight: FontWeight.bold,
                  )),
        ],
      ),
    );
  }

  Widget _smallStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11, color: Theme.of(context).hintColor)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _TrendOption {
  final String label;
  final Color color;
  final double Function(DailyMetric) value;
  final String Function(double) fmt;
  final bool currency;
  const _TrendOption(
      this.label, this.color, this.value, this.fmt, this.currency);
}

/// Charts tab: a metric selector + a daily-trend line chart and a cumulative
/// spend-vs-budget chart.
class _TrendsTab extends StatefulWidget {
  final Campaign campaign;
  final List<DailyMetric> metrics;
  const _TrendsTab({required this.campaign, required this.metrics});

  @override
  State<_TrendsTab> createState() => _TrendsTabState();
}

class _TrendsTabState extends State<_TrendsTab> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final p = context.palette;
    // Chronological order for the X axis.
    final metrics = [...widget.metrics]
      ..sort((a, b) => a.date.compareTo(b.date));

    if (metrics.length < 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart_rounded, size: 56, color: p.muted),
              const SizedBox(height: 12),
              Text(
                l.s('Add at least 2 daily entries to see trends.',
                    'Grafikler için en az 2 günlük giriş ekle.'),
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', color: p.muted),
              ),
            ],
          ),
        ),
      );
    }

    final labels = [for (final m in metrics) Fmt.shortDate(m.date)];
    final options = <_TrendOption>[
      _TrendOption(l.s('Spend', 'Harcama'), p.accent, (m) => m.spend,
          Fmt.money, true),
      _TrendOption('CPM', Theme.of(context).colorScheme.primary,
          (m) => Calc.cpm(m.spend, m.impressions), Fmt.money4, true),
      _TrendOption('CPC', p.warn, (m) => Calc.cpc(m.spend, m.clicks),
          Fmt.money4, true),
      _TrendOption('CTR', p.success,
          (m) => Calc.ctr(m.clicks, m.impressions), Fmt.pct, false),
      _TrendOption(l.s('Impr.', 'Gösterim'), p.neutral,
          (m) => m.impressions.toDouble(), Fmt.num0, false),
    ];
    final opt = options[_selected];
    final values = [for (final m in metrics) opt.value(m)];

    // Cumulative spend.
    double run = 0;
    final cumulative = [
      for (final m in metrics) run += m.spend,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 96),
      children: [
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) => ChoiceChip(
              label: Text(options[i].label),
              selected: _selected == i,
              showCheckmark: false,
              onSelected: (_) => setState(() => _selected = i),
            ),
          ),
        ),
        const SizedBox(height: 12),
        PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading('${opt.label} · ${l.s('daily', 'günlük')}'),
              const SizedBox(height: 16),
              LineTrend(
                values: values,
                labels: labels,
                color: opt.color,
                tooltipFmt: opt.fmt,
                currencyAxis: opt.currency,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(l.s('Cumulative spend', 'Kümülatif harcama')),
              const SizedBox(height: 16),
              LineTrend(
                values: cumulative,
                labels: labels,
                color: Theme.of(context).colorScheme.primary,
                tooltipFmt: Fmt.money,
                currencyAxis: true,
                referenceY: widget.campaign.totalBudget > 0
                    ? widget.campaign.totalBudget
                    : null,
                referenceLabel: l.s('Budget', 'Bütçe'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
