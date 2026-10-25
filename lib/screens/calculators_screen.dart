import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../utils/format.dart';

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final spend = _Field(l.s('Spend / Budget', 'Harcama / Bütçe'), _Kind.money);
    final impressions = _Field(l.s('Impressions', 'Impression'), _Kind.count);
    final views = _Field(l.s('Views', 'İzlenme'), _Kind.count);
    final completed =
        _Field(l.s('Completed views', 'Tamamlanan izlenme'), _Kind.count);
    final viewable =
        _Field(l.s('Viewable impr.', 'Görüntülenebilir impr.'), _Kind.count);
    final clicks = _Field(l.s('Clicks', 'Tıklama'), _Kind.count);

    return Scaffold(
      appBar: AppBar(title: Text(l.s('Calculators', 'Hesap makineleri'))),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Text(
              l.s('Fill any two fields — the empty one is calculated.',
                  'Herhangi iki alanı doldur, boş kalan hesaplanır.'),
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ),
          _CalcCard(
            title: 'CPM',
            subtitle: l.s('Cost per 1000 impressions',
                'Bin gösterim başına maliyet'),
            a: spend,
            b: impressions,
            result: const _Field('CPM', _Kind.unitCost),
            factor: 1000,
          ),
          _CalcCard(
            title: 'CTR',
            subtitle: l.s('Click-through rate', 'Tıklama oranı'),
            a: clicks,
            b: impressions,
            result: const _Field('CTR %', _Kind.percent),
            factor: 100,
          ),
          _CalcCard(
            title: 'CPV',
            subtitle: l.s('Cost per view', 'İzlenme başına maliyet'),
            a: spend,
            b: views,
            result: const _Field('CPV', _Kind.unitCost),
          ),
          _CalcCard(
            title: 'CPCV',
            subtitle: l.s('Cost per completed view',
                'Tamamlanan izlenme başına maliyet'),
            a: spend,
            b: completed,
            result: const _Field('CPCV', _Kind.unitCost),
          ),
          _CalcCard(
            title: 'CPV (ThruPlay)',
            subtitle: l.s('Cost per ThruPlay (Meta) / 6s+ view',
                'ThruPlay başına maliyet (Meta) / 6sn+ izlenme'),
            a: spend,
            b: _Field(l.s('ThruPlays', 'ThruPlay'), _Kind.count),
            result: const _Field('CPV', _Kind.unitCost),
          ),
          _CalcCard(
            title: 'CPC',
            subtitle: l.s('Cost per click', 'Tıklama başına maliyet'),
            a: spend,
            b: clicks,
            result: const _Field('CPC', _Kind.unitCost),
          ),
          _CalcCard(
            title: 'CPA',
            subtitle:
                l.s('Cost per acquisition', 'Edinim başına maliyet'),
            a: spend,
            b: _Field(l.s('Conversions', 'Dönüşüm'), _Kind.count),
            result: const _Field('CPA', _Kind.unitCost),
          ),
          _CalcCard(
            title: 'vCPM',
            subtitle: l.s('Cost per 1000 viewable impr.',
                'Bin görüntülenebilir gösterim maliyeti'),
            a: spend,
            b: viewable,
            result: const _Field('vCPM', _Kind.unitCost),
            factor: 1000,
          ),
          _CalcCard(
            title: 'VCR',
            subtitle: l.s('Video completion rate', 'Video tamamlanma oranı'),
            a: completed,
            b: views,
            result: const _Field('VCR %', _Kind.percent),
            factor: 100,
          ),
          _CalcCard(
            title: l.s('Viewability', 'Görüntülenebilirlik'),
            subtitle: l.s('Viewable / total impressions',
                'Görüntülenebilir / toplam gösterim'),
            a: viewable,
            b: impressions,
            result: _Field(l.s('Viewability %', 'Görüntülenebilirlik %'),
                _Kind.percent),
            factor: 100,
          ),
          _CalcCard(
            title: 'ROAS',
            subtitle: l.s('Return on ad spend', 'Reklam harcaması getirisi'),
            a: _Field(l.s('Revenue', 'Gelir'), _Kind.money),
            b: _Field(l.s('Spend', 'Harcama'), _Kind.money),
            result: const _Field('ROAS', _Kind.multiplier),
          ),
        ],
      ),
    );
  }
}

enum _Kind { money, unitCost, count, percent, multiplier }

class _Field {
  final String label;
  final _Kind kind;

  const _Field(this.label, this.kind);

  String format(double v) {
    switch (kind) {
      case _Kind.money:
        return Fmt.money(v);
      case _Kind.unitCost:
        return Fmt.money4(v);
      case _Kind.count:
        return Fmt.num0(v);
      case _Kind.percent:
        return Fmt.pct(v);
      case _Kind.multiplier:
        return Fmt.mult(v);
    }
  }
}

/// Three-way solver for a ratio metric: result = a / b * factor.
/// Whichever field is left empty is derived from the other two.
class _CalcCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final _Field a;
  final _Field b;
  final _Field result;
  final double factor;

  const _CalcCard({
    required this.title,
    required this.subtitle,
    required this.a,
    required this.b,
    required this.result,
    this.factor = 1,
  });

  @override
  State<_CalcCard> createState() => _CalcCardState();
}

class _CalcCardState extends State<_CalcCard> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (_) => TextEditingController());
    for (final c in _controllers) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  double? _parse(TextEditingController c) {
    final t = c.text.trim().replaceAll(' ', '').replaceAll(',', '.');
    return t.isEmpty ? null : double.tryParse(t);
  }

  /// Returns the computed value for the single empty field, or null.
  (int, double)? _solve(List<double?> v) {
    final empty = [for (var i = 0; i < 3; i++) if (v[i] == null) i];
    if (empty.length != 1) return null;
    final k = widget.factor;
    switch (empty.first) {
      case 0: // a = r * b / k
        return (0, v[2]! * v[1]! / k);
      case 1: // b = a * k / r
        return v[2]! > 0 ? (1, v[0]! * k / v[2]!) : null;
      default: // r = a / b * k
        return v[1]! > 0 ? (2, v[0]! / v[1]! * k) : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final theme = Theme.of(context);
    final values = _controllers.map(_parse).toList();
    final solved = _solve(values);
    final fields = [widget.a, widget.b, widget.result];
    final filled = values.where((v) => v != null).length;

    Widget input(int i, {bool large = false}) {
      final computed =
          solved != null && solved.$1 == i ? fields[i].format(solved.$2) : null;
      final highlight = theme.colorScheme.primary;
      return TextField(
        controller: _controllers[i],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: large
            ? theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
            : null,
        decoration: InputDecoration(
          labelText: fields[i].label,
          hintText: computed,
          hintStyle: (large ? theme.textTheme.titleLarge : null)?.copyWith(
                color: highlight,
                fontWeight: FontWeight.bold,
              ) ??
              TextStyle(color: highlight, fontWeight: FontWeight.bold),
          floatingLabelBehavior: computed != null
              ? FloatingLabelBehavior.always
              : FloatingLabelBehavior.auto,
          filled: computed != null,
          fillColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      );
    }

    final String status;
    if (filled == 3) {
      status = l.s('Clear a field to calculate it.',
          'Hesaplamak için bir alanı boşalt.');
    } else if (filled < 2) {
      status = l.s('Fill any two fields.', 'Herhangi iki alanı doldur.');
    } else if (solved == null) {
      status = l.s('Cannot divide by zero.', 'Sıfıra bölünemez.');
    } else {
      status = '${fields[solved.$1].label} = ${fields[solved.$1].format(solved.$2)}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: theme.textTheme.titleMedium),
                      Text(widget.subtitle,
                          style: TextStyle(color: theme.hintColor)),
                    ],
                  ),
                ),
                if (filled > 0)
                  IconButton(
                    tooltip: l.s('Clear', 'Temizle'),
                    icon: const Icon(Icons.clear_all),
                    onPressed: () {
                      for (final c in _controllers) {
                        c.clear();
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: input(0)),
                const SizedBox(width: 8),
                Expanded(child: input(1)),
              ],
            ),
            const SizedBox(height: 10),
            input(2, large: true),
            const SizedBox(height: 8),
            Text(
              status,
              style: TextStyle(
                color: solved != null ? theme.colorScheme.primary : theme.hintColor,
                fontWeight: solved != null ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
