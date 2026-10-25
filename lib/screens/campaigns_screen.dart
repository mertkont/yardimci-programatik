import 'package:flutter/material.dart';

import '../db/app_db.dart';
import '../l10n/l10n.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/calc.dart';
import '../utils/format.dart';
import '../widgets/status_helpers.dart';
import '../widgets/ui.dart';
import 'campaign_detail_screen.dart';
import 'campaign_form_screen.dart';

class _Row {
  final Campaign campaign;
  final CampaignTotals totals;
  final Pacing pacing;
  _Row(this.campaign, this.totals, this.pacing);
}

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  late Future<List<_Row>> _future;
  String _query = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_Row>> _load() async {
    final db = AppDb.instance;
    await db.archiveExpired();
    final campaigns = await db.getCampaigns();
    final now = DateTime.now();
    final rows = <_Row>[];
    for (final c in campaigns) {
      final metrics = await db.getMetrics(c.id!);
      final totals = CampaignTotals.from(c, metrics);
      final pacing = Pacing.compute(c, totals.spend, now);
      rows.add(_Row(c, totals, pacing));
    }
    return rows;
  }

  void _refresh() => setState(() {
        _future = _load();
      });

  List<_Row> _filter(List<_Row> rows) {
    return rows.where((r) {
      if (_statusFilter != 'all' && r.campaign.status != _statusFilter) {
        return false;
      }
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return r.campaign.name.toLowerCase().contains(q) ||
          r.campaign.client.toLowerCase().contains(q) ||
          r.campaign.platform.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CampaignFormScreen()),
          );
          _refresh();
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(l.s('New', 'Yeni')),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Text(l.s('Campaigns', 'Kampanyalar'),
                      style: Theme.of(context).appBarTheme.titleTextStyle),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  hintText: l.s('Search name, client, platform',
                      'Ad, müşteri, platform ara'),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _filterChip(l.s('All', 'Tümü'), 'all'),
                  _filterChip(l.s('Active', 'Aktif'), 'active'),
                  _filterChip(l.s('Paused', 'Duraklatıldı'), 'paused'),
                  _filterChip(l.s('Ended', 'Bitti'), 'completed'),
                  _filterChip(l.s('Draft', 'Taslak'), 'draft'),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: FutureBuilder<List<_Row>>(
                future: _future,
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final rows = _filter(snap.data!);
                  if (rows.isEmpty) {
                    return _empty(context);
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 96),
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _card(context, rows[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final l = L10n.of(context);
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.campaign_outlined, size: 56, color: p.muted),
          const SizedBox(height: 12),
          Text(
            _query.isNotEmpty || _statusFilter != 'all'
                ? l.s('No campaigns match.', 'Eşleşen kampanya yok.')
                : l.s('No campaigns yet.', 'Henüz kampanya yok.'),
            style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: p.ink),
          ),
          const SizedBox(height: 4),
          Text(l.s('Tap “New” to add one.', '“Yeni” ile ekle.'),
              style: TextStyle(fontFamily: 'Inter', color: p.muted)),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => setState(() => _statusFilter = value),
      ),
    );
  }

  Widget _card(BuildContext context, _Row r) {
    final l = L10n.of(context);
    final p = context.palette;
    final c = r.campaign;
    final metric = r.totals.primaryMetric(c.pricingType);
    final pColor = pacingColor(context, r.pacing.state);
    final expectedFrac = c.totalBudget > 0
        ? r.pacing.expectedSpend / c.totalBudget
        : 0.0;

    return PanelCard(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CampaignDetailScreen(campaignId: c.id!),
          ),
        );
        _refresh();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 2),
                    Text('${c.client}  ·  ${c.platform}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5,
                            color: p.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(
                  label: statusLabel(l, c.status),
                  color: statusColor(context, c.status)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: metric.label,
                  value: Fmt.byUnit(metric.unit, metric.value),
                  valueColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              Expanded(
                child: StatTile(
                  label: l.s('Spent', 'Harcanan'),
                  value: Fmt.money(r.totals.spend),
                ),
              ),
              Expanded(
                child: StatTile(
                  label: l.s('Budget', 'Bütçe'),
                  value: Fmt.money(c.totalBudget),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PacingGauge(
            spentFraction: r.pacing.spentFraction(c.totalBudget),
            expectedFraction: expectedFrac,
            color: pColor,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration:
                        BoxDecoration(color: pColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(pacingLabel(l, r.pacing.state),
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: pColor)),
                ],
              ),
              Text(
                r.pacing.state == PacingState.ended
                    ? l.s('ended', 'bitti')
                    : '${r.pacing.daysLeft} ${l.s('days left', 'gün kaldı')}',
                style: TextStyle(
                    fontFamily: 'Inter', fontSize: 12, color: p.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
