import 'package:flutter/material.dart';

import '../db/app_db.dart';
import '../help/field_help.dart';
import '../l10n/l10n.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/calc.dart';
import '../utils/format.dart';
import '../widgets/ui.dart';

class CampaignFormScreen extends StatefulWidget {
  final Campaign? existing;
  const CampaignFormScreen({super.key, this.existing});

  @override
  State<CampaignFormScreen> createState() => _CampaignFormScreenState();
}

class _CampaignFormScreenState extends State<CampaignFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _client;
  late TextEditingController _objective;
  late TextEditingController _budget;
  late TextEditingController _kpi;
  late TextEditingController _goalVolume;
  late TextEditingController _margin;
  late TextEditingController _realBudget;
  late TextEditingController _notes;

  String _platform = kPlatforms.first;
  String _pricing = kPricingTypes.first;
  String _status = kStatuses.first;
  late DateTime _start;
  late DateTime _end;

  bool get _isDv360 => _platform == 'DV360';

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _client = TextEditingController(text: e?.client ?? '');
    _objective = TextEditingController(text: e?.objective ?? '');
    _budget = TextEditingController(text: _fmt(e?.totalBudget));
    _kpi = TextEditingController(text: _fmt(e?.kpiTarget));
    _goalVolume = TextEditingController(text: _fmt(e?.goalVolume));
    _margin = TextEditingController(text: _fmt(e?.marginPercent));
    _realBudget = TextEditingController(text: _fmt(e?.realBudget));
    _notes = TextEditingController(text: e?.notes ?? '');
    _platform = e?.platform ?? kPlatforms.first;
    _pricing = e?.pricingType ?? kPricingTypes.first;
    _status = e?.status ?? kStatuses.first;
    _start = e?.startDate ?? DateTime.now();
    _end = e?.endDate ?? DateTime.now().add(const Duration(days: 30));
    // Rebuild the suggested-spend hint as the user types.
    _realBudget.addListener(() => setState(() {}));
    _margin.addListener(() => setState(() {}));
  }

  String _fmt(double? v) => (v == null) ? '' : _trim(v);
  String _trim(num v) => v == v.toInt() ? v.toInt().toString() : v.toString();
  double? _parse(TextEditingController c) => c.text.trim().isEmpty
      ? null
      : double.tryParse(c.text.replaceAll(',', '.'));

  @override
  void dispose() {
    for (final c in [
      _name,
      _client,
      _objective,
      _budget,
      _kpi,
      _goalVolume,
      _margin,
      _realBudget,
      _notes
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _statusLabel(L10n l, String s) {
    switch (s) {
      case 'active':
        return l.s('Active', 'Aktif');
      case 'paused':
        return l.s('Paused', 'Duraklatıldı');
      case 'completed':
        return l.s('Ended', 'Bitti');
      case 'draft':
        return l.s('Draft', 'Taslak');
    }
    return s;
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final c = Campaign(
      id: widget.existing?.id,
      name: _name.text.trim(),
      platform: _platform,
      client: _client.text.trim(),
      objective: _objective.text.trim(),
      pricingType: _pricing,
      totalBudget: _parse(_budget) ?? 0,
      startDate: _start,
      endDate: _end,
      status: _status,
      kpiTarget: _parse(_kpi),
      goalVolume: _parse(_goalVolume),
      marginPercent: _parse(_margin),
      realBudget: _isDv360 ? null : _parse(_realBudget),
      notes: _notes.text.trim(),
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );
    if (widget.existing == null) {
      await AppDb.instance.insertCampaign(c);
    } else {
      await AppDb.instance.updateCampaign(c);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null
            ? l.s('New campaign', 'Yeni kampanya')
            : l.s('Edit campaign', 'Kampanyayı düzenle')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _text(_name, l.s('Campaign name', 'Kampanya adı'),
                required: true, helpKey: 'name'),
            _text(_client, l.s('Client / advertiser', 'Müşteri / reklamveren'),
                required: true, helpKey: 'client'),
            _dropdown(l.s('Platform', 'Platform'), _platform, kPlatforms,
                (v) => setState(() => _platform = v!),
                helpKey: 'platform'),
            _dropdown(l.s('Pricing type', 'Yayın / fiyatlama tipi'), _pricing,
                kPricingTypes, (v) => setState(() => _pricing = v!),
                helpKey: 'pricingType'),
            _text(_objective, l.s('Objective (optional)', 'Hedef (opsiyonel)'),
                helpKey: 'objective'),
            _text(_budget, l.s('Media budget', 'Medya bütçesi'),
                number: true, required: true, helpKey: 'totalBudget'),
            _text(_kpi,
                l.s('Target $_pricing (optional)',
                    'Hedef $_pricing (opsiyonel)'),
                number: true, helpKey: 'kpiTarget'),
            _text(
                _goalVolume,
                l.s(
                    'Target ${volumeUnitLabel(volumeUnitFor(_pricing), false)} (optional)',
                    'Hedef ${volumeUnitLabel(volumeUnitFor(_pricing), true)} (opsiyonel)'),
                number: true,
                helpKey: 'goalVolume'),
            // Margin: DV360 uses a markup %, others a real budget + target.
            if (_isDv360)
              _text(_margin, l.s('Margin %', 'Margin %'),
                  number: true, helpKey: 'marginDv360')
            else ...[
              _text(_realBudget,
                  l.s('Real / client budget', 'Gerçek / müşteri bütçesi'),
                  number: true, helpKey: 'realBudget'),
              _text(_margin, l.s('Target margin %', 'Hedef margin %'),
                  number: true, helpKey: 'targetMargin'),
              _suggestion(l),
            ],
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _dateTile(
                      l.s('Start', 'Başlangıç'), _start, () => _pickDate(true)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dateTile(
                      l.s('End', 'Bitiş'), _end, () => _pickDate(false)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 14),
                  child: HelpDot(
                      FieldHelp.text('dates', _platform, l.isTr)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _dropdown(l.s('Status', 'Durum'), _status, kStatuses,
                (v) => setState(() => _status = v!),
                labelOf: (s) => _statusLabel(l, s), helpKey: 'status'),
            _text(_notes, l.s('Notes', 'Notlar'), maxLines: 3),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: Text(l.s('Save campaign', 'Kampanyayı kaydet')),
            ),
          ],
        ),
      ),
    );
  }

  /// Suggested media spend that keeps the target margin on the real budget.
  Widget _suggestion(L10n l) {
    final rb = _parse(_realBudget) ?? 0;
    final tm = _parse(_margin) ?? 0;
    if (rb <= 0 || tm <= 0) return const SizedBox(height: 4);
    final spend = Calc.suggestedSpend(rb, tm);
    final p = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded,
              color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.s('Suggested media spend', 'Önerilen medya harcaması'),
                  style: TextStyle(
                      fontFamily: 'Inter', fontSize: 12, color: p.muted),
                ),
                Text(
                  '${Fmt.money(spend)}  ·  ${l.s('keeps', 'korur')} ${Fmt.pct(tm)} ${l.s('margin', 'margin')}',
                  style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _budget.text = _trim(spend)),
            child: Text(l.s('Use', 'Kullan')),
          ),
        ],
      ),
    );
  }

  Widget _withHelp(Widget field, String? helpKey, {double topPad = 14}) {
    final help = helpKey == null
        ? ''
        : FieldHelp.text(helpKey, _platform, L10n.of(context).isTr);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: field),
          if (help.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 2, top: topPad),
              child: HelpDot(help),
            ),
        ],
      ),
    );
  }

  Widget _text(TextEditingController c, String label,
      {bool number = false,
      bool required = false,
      int maxLines = 1,
      String? helpKey}) {
    return _withHelp(
      TextFormField(
        controller: c,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty)
                ? L10n.of(context).s('Required', 'Zorunlu')
                : null
            : null,
      ),
      helpKey,
    );
  }

  Widget _dropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged,
      {String Function(String)? labelOf, String? helpKey}) {
    return _withHelp(
      DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: items
            .map((e) => DropdownMenuItem(
                value: e, child: Text(labelOf != null ? labelOf(e) : e)))
            .toList(),
        onChanged: onChanged,
      ),
      helpKey,
    );
  }

  Widget _dateTile(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(Fmt.date(date)),
            const Icon(Icons.calendar_today_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
