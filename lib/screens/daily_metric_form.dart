import 'package:flutter/material.dart';

import '../db/app_db.dart';
import '../help/field_help.dart';
import '../l10n/l10n.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/calc.dart';
import '../utils/format.dart';
import '../widgets/ui.dart';

/// Add or edit a single day's numbers for a campaign.
class DailyMetricForm extends StatefulWidget {
  final Campaign campaign;
  final DailyMetric? existing;
  const DailyMetricForm({super.key, required this.campaign, this.existing});

  @override
  State<DailyMetricForm> createState() => _DailyMetricFormState();
}

class _DailyMetricFormState extends State<DailyMetricForm> {
  late TextEditingController _spend;
  late TextEditingController _impr;
  late TextEditingController _views;
  late TextEditingController _completed;
  late TextEditingController _viewable;
  late TextEditingController _clicks;
  late TextEditingController _conv;
  late TextEditingController _revenue;
  late TextEditingController _margin;
  late TextEditingController _note;
  late DateTime _date;

  late final List<TextEditingController> _numeric;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _spend = _ctrl(e?.spend);
    _impr = _ctrl(e?.impressions);
    _views = _ctrl(e?.views);
    _completed = _ctrl(e?.completedViews);
    _viewable = _ctrl(e?.viewableImpressions);
    _clicks = _ctrl(e?.clicks);
    _conv = _ctrl(e?.conversions);
    _revenue = _ctrl(e?.revenue);
    _margin = _ctrl(e?.marginPercent ?? widget.campaign.marginPercent);
    _note = TextEditingController(text: e?.note ?? '');
    _date = e?.date ?? DateTime.now();
    _numeric = [_spend, _impr, _views, _completed, _viewable, _clicks, _conv,
        _revenue];
    for (final c in _numeric) {
      c.addListener(() => setState(() {}));
    }
  }

  TextEditingController _ctrl(num? v) =>
      TextEditingController(text: (v == null || v == 0) ? '' : _trim(v));

  String _trim(num v) =>
      v == v.toInt() ? v.toInt().toString() : v.toString();

  double _d(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;
  int _i(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  @override
  void dispose() {
    for (final c in [..._numeric, _margin, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final m = DailyMetric(
      id: widget.existing?.id,
      campaignId: widget.campaign.id!,
      date: DateTime(_date.year, _date.month, _date.day),
      spend: _d(_spend),
      impressions: _i(_impr),
      views: _i(_views),
      completedViews: _i(_completed),
      viewableImpressions: _i(_viewable),
      clicks: _i(_clicks),
      conversions: _i(_conv),
      revenue: _d(_revenue),
      marginPercent: _margin.text.trim().isEmpty
          ? null
          : double.tryParse(_margin.text.replaceAll(',', '.')),
      note: _note.text.trim(),
    );
    if (widget.existing == null) {
      await AppDb.instance.insertMetric(m);
    } else {
      await AppDb.instance.updateMetric(m);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final spend = _d(_spend);
    final imp = _i(_impr);
    final views = _i(_views);
    final completed = _i(_completed);
    final viewable = _i(_viewable);
    final clicks = _i(_clicks);
    final conv = _i(_conv);
    final revenue = _d(_revenue);

    return Scaffold(
      appBar: AppBar(title: Text(l.s('Daily entry', 'Günlük giriş'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) setState(() => _date = picked);
            },
            child: InputDecorator(
              decoration: InputDecoration(labelText: l.s('Date', 'Tarih')),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Fmt.date(_date)),
                  const Icon(Icons.calendar_today_rounded, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _group(l.s('Delivery', 'Yayın')),
          _twoCol(
            _field(_spend, l.s('Spend', 'Harcama'), helpKey: 'spend'),
            _field(_impr, l.s('Impressions', 'Impression'),
                helpKey: 'impressions'),
          ),
          _twoCol(
            _field(_clicks, l.s('Clicks', 'Tıklama'), helpKey: 'clicks'),
            _field(_conv, l.s('Conversions', 'Dönüşüm'),
                helpKey: 'conversions'),
          ),
          const SizedBox(height: 6),
          _group(l.s('Video / viewability', 'Video / görüntülenebilirlik')),
          _twoCol(
            _field(_views, l.s('Views', 'İzlenme'), helpKey: 'views'),
            _field(_completed, l.s('Completed views', 'Tamamlanan izlenme'),
                helpKey: 'completedViews'),
          ),
          _twoCol(
            _field(_viewable, l.s('Viewable impr.', 'Görüntülenebilir impr.'),
                helpKey: 'viewableImpressions'),
            _field(_revenue, l.s('Revenue', 'Gelir'), helpKey: 'revenue'),
          ),
          const SizedBox(height: 6),
          _group(l.s('Commercial', 'Ticari')),
          _field(_margin, l.s('Margin % (optional)', 'Margin % (opsiyonel)'),
              helpKey: 'dailyMargin'),
          _field(_note, l.s('Note', 'Not'), number: false),
          const SizedBox(height: 16),
          _calculated(context, spend, imp, views, completed, viewable, clicks,
              conv, revenue),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: Text(l.s('Save entry', 'Girişi kaydet')),
          ),
        ],
      ),
    );
  }

  Widget _group(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10, left: 2),
      child: Text(title.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: context.palette.muted,
          )),
    );
  }

  Widget _twoCol(Widget a, Widget b) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 10),
        Expanded(child: b),
      ],
    );
  }

  Widget _calculated(
    BuildContext context,
    double spend,
    int imp,
    int views,
    int completed,
    int viewable,
    int clicks,
    int conv,
    double revenue,
  ) {
    final l = L10n.of(context);
    final p = context.palette;
    final chips = <Widget>[
      _chip('CPM', Fmt.money4(Calc.cpm(spend, imp))),
      _chip('CPC', Fmt.money4(Calc.cpc(spend, clicks))),
      _chip('CTR', Fmt.pct(Calc.ctr(clicks, imp))),
      _chip('CPV', Fmt.money4(Calc.cpv(spend, views))),
      _chip('CPCV', Fmt.money4(Calc.cpcv(spend, completed))),
      _chip('VCR', Fmt.pct(Calc.vcr(completed, views))),
      _chip(l.s('View%', 'Görün%'), Fmt.pct(Calc.viewability(viewable, imp))),
      _chip('CPA', Fmt.money4(Calc.cpa(spend, conv))),
      _chip('ROAS', Fmt.mult(Calc.roas(revenue, spend))),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.track,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.s('Calculated live', 'Canlı hesaplanan').toUpperCase(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: p.muted,
              )),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label ',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: p.muted)),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {bool number = true, String? helpKey}) {
    final help = helpKey == null
        ? ''
        : FieldHelp.text(
            helpKey, widget.campaign.platform, L10n.of(context).isTr);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: help.isEmpty ? null : HelpDot(help),
          suffixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
      ),
    );
  }
}
