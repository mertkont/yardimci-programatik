import '../models/models.dart';

/// Pure functions for advertising metrics. All guard against divide-by-zero.
class Calc {
  /// Cost per mille (per 1000 impressions).
  static double cpm(double spend, int impressions) =>
      impressions > 0 ? spend / impressions * 1000 : 0;

  /// Cost per view.
  static double cpv(double spend, int views) =>
      views > 0 ? spend / views : 0;

  /// Cost per click.
  static double cpc(double spend, int clicks) =>
      clicks > 0 ? spend / clicks : 0;

  /// Cost per completed view (uses the views field as completed views).
  static double cpcv(double spend, int completedViews) =>
      completedViews > 0 ? spend / completedViews : 0;

  /// Cost per acquisition / action.
  static double cpa(double spend, int conversions) =>
      conversions > 0 ? spend / conversions : 0;

  /// Click-through rate as a percentage.
  static double ctr(int clicks, int impressions) =>
      impressions > 0 ? clicks / impressions * 100 : 0;

  /// View rate (views / impressions) as a percentage.
  static double vtr(int views, int impressions) =>
      impressions > 0 ? views / impressions * 100 : 0;

  /// Video completion rate (completed views / views) as a percentage.
  static double vcr(int completedViews, int views) =>
      views > 0 ? completedViews / views * 100 : 0;

  /// Viewability rate (viewable impressions / impressions) as a percentage.
  static double viewability(int viewable, int impressions) =>
      impressions > 0 ? viewable / impressions * 100 : 0;

  /// Viewable CPM (cost per 1000 viewable impressions).
  static double vcpm(double spend, int viewable) =>
      viewable > 0 ? spend / viewable * 1000 : 0;

  /// Return on ad spend (revenue / spend), as a multiplier.
  static double roas(double revenue, double spend) =>
      spend > 0 ? revenue / spend : 0;

  /// Profit from a spend given a margin percentage.
  static double profit(double spend, double marginPercent) =>
      spend * marginPercent / 100;

  /// Impressions you can buy with [budget] at a target [cpm].
  static double impressionsForBudget(double budget, double cpm) =>
      cpm > 0 ? budget / cpm * 1000 : 0;

  /// Media spend that keeps [targetMarginPct] margin on a [realBudget] (the
  /// client/sold budget). spend = revenue x (1 - margin%).
  static double suggestedSpend(double realBudget, double targetMarginPct) =>
      realBudget * (1 - targetMarginPct / 100).clamp(0, 1);

  /// Project the final value at end of flight from the value [toDate], using
  /// the share of the flight elapsed. Returns [toDate] if it can't project.
  static double projectFinal(
      double toDate, DateTime start, DateTime end, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    if (today.isBefore(s) || today.isAfter(e)) return toDate;
    final totalDays = e.difference(s).inDays + 1;
    final elapsed = today.difference(s).inDays + 1;
    if (elapsed <= 0 || totalDays <= 0) return toDate;
    return toDate * totalDays / elapsed;
  }
}

/// The delivery-volume unit a pricing type is measured in.
enum VolumeUnit {
  impressions,
  viewableImpressions,
  views,
  completedViews,
  clicks,
  conversions,
}

String volumeUnitLabel(VolumeUnit u, bool tr) {
  switch (u) {
    case VolumeUnit.viewableImpressions:
      return tr ? 'görüntülenebilir gösterim' : 'viewable impr.';
    case VolumeUnit.views:
      return tr ? 'izlenme' : 'views';
    case VolumeUnit.completedViews:
      return tr ? 'tamamlanan izlenme' : 'completed views';
    case VolumeUnit.clicks:
      return tr ? 'tıklama' : 'clicks';
    case VolumeUnit.conversions:
      return tr ? 'dönüşüm' : 'conversions';
    case VolumeUnit.impressions:
      return tr ? 'gösterim' : 'impressions';
  }
}

VolumeUnit volumeUnitFor(String pricingType) {
  switch (pricingType) {
    case 'vCPM':
      return VolumeUnit.viewableImpressions;
    case 'CPV':
      return VolumeUnit.views;
    case 'CPCV':
      return VolumeUnit.completedViews;
    case 'CPC':
      return VolumeUnit.clicks;
    case 'CPA':
      return VolumeUnit.conversions;
    case 'CPM':
    case 'ROAS':
    case 'Flat':
    default:
      return VolumeUnit.impressions;
  }
}

/// The primary metric for a campaign, based on its pricing type.
class PrimaryMetric {
  final String label; // e.g. "CPM"
  final double value;
  final String unit; // currency / percent

  const PrimaryMetric(this.label, this.value, this.unit);
}

/// Aggregate of all daily metrics for a campaign.
class CampaignTotals {
  final double spend;
  final int impressions;
  final int views;
  final int completedViews;
  final int viewableImpressions;
  final int clicks;
  final int conversions;
  final double revenue;
  final double profit;
  final double marginPercent; // effective margin %
  final bool realBudgetModel; // profit = client budget - spend

  const CampaignTotals({
    this.spend = 0,
    this.impressions = 0,
    this.views = 0,
    this.completedViews = 0,
    this.viewableImpressions = 0,
    this.clicks = 0,
    this.conversions = 0,
    this.revenue = 0,
    this.profit = 0,
    this.marginPercent = 0,
    this.realBudgetModel = false,
  });

  static CampaignTotals from(Campaign c, List<DailyMetric> metrics) {
    double spend = 0, markupProfit = 0, revenue = 0;
    int imp = 0, views = 0, completed = 0, viewable = 0, clicks = 0, conv = 0;
    for (final m in metrics) {
      spend += m.spend;
      imp += m.impressions;
      views += m.views;
      completed += m.completedViews;
      viewable += m.viewableImpressions;
      clicks += m.clicks;
      conv += m.conversions;
      revenue += m.revenue;
      final margin = m.marginPercent ?? c.marginPercent ?? 0;
      markupProfit += Calc.profit(m.spend, margin);
    }

    // Profit model: real (client) budget for non-DV360, else markup on spend.
    final double profit;
    final double marginPct;
    if (c.usesRealBudget) {
      profit = c.realBudget! - spend;
      marginPct = c.realBudget! > 0 ? profit / c.realBudget! * 100 : 0;
    } else {
      profit = markupProfit;
      marginPct = spend > 0 ? markupProfit / spend * 100 : 0;
    }

    return CampaignTotals(
      spend: spend,
      impressions: imp,
      views: views,
      completedViews: completed,
      viewableImpressions: viewable,
      clicks: clicks,
      conversions: conv,
      revenue: revenue,
      profit: profit,
      marginPercent: marginPct,
      realBudgetModel: c.usesRealBudget,
    );
  }

  /// The delivered count in the volume unit for [pricingType].
  double deliveredVolume(String pricingType) {
    switch (volumeUnitFor(pricingType)) {
      case VolumeUnit.viewableImpressions:
        return viewableImpressions.toDouble();
      case VolumeUnit.views:
        return views.toDouble();
      case VolumeUnit.completedViews:
        return completedViews.toDouble();
      case VolumeUnit.clicks:
        return clicks.toDouble();
      case VolumeUnit.conversions:
        return conversions.toDouble();
      case VolumeUnit.impressions:
        return impressions.toDouble();
    }
  }

  /// The headline metric to display for this campaign type.
  PrimaryMetric primaryMetric(String pricingType) {
    switch (pricingType) {
      case 'vCPM':
        return PrimaryMetric(
            'vCPM', Calc.vcpm(spend, viewableImpressions), 'currency');
      case 'CPV':
        return PrimaryMetric('CPV', Calc.cpv(spend, views), 'currency');
      case 'CPCV':
        return PrimaryMetric(
            'CPCV', Calc.cpcv(spend, completedViews), 'currency');
      case 'CPC':
        return PrimaryMetric('CPC', Calc.cpc(spend, clicks), 'currency');
      case 'CPA':
        return PrimaryMetric('CPA', Calc.cpa(spend, conversions), 'currency');
      case 'ROAS':
        return PrimaryMetric('ROAS', Calc.roas(revenue, spend), 'multiplier');
      case 'Flat':
        return PrimaryMetric('Spend', spend, 'currency');
      case 'CPM':
      default:
        return PrimaryMetric('CPM', Calc.cpm(spend, impressions), 'currency');
    }
  }
}

/// Pacing assessment for a campaign at a given moment.
enum PacingState { notStarted, ended, onTrack, underpacing, overpacing }

class Pacing {
  final PacingState state;
  final double expectedSpend;
  final double actualSpend;
  final int daysLeft;
  final DateTime? budgetEndsOn; // projected date the budget runs out

  const Pacing({
    required this.state,
    required this.expectedSpend,
    required this.actualSpend,
    required this.daysLeft,
    this.budgetEndsOn,
  });

  /// Fraction of the budget already spent (0..1+).
  double spentFraction(double totalBudget) =>
      totalBudget > 0 ? actualSpend / totalBudget : 0;

  static Pacing compute(Campaign c, double actualSpend, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(c.startDate.year, c.startDate.month, c.startDate.day);
    final end = DateTime(c.endDate.year, c.endDate.month, c.endDate.day);

    if (today.isBefore(start)) {
      return Pacing(
        state: PacingState.notStarted,
        expectedSpend: 0,
        actualSpend: actualSpend,
        daysLeft: end.difference(today).inDays,
      );
    }
    final totalDays = end.difference(start).inDays + 1;
    if (today.isAfter(end)) {
      return Pacing(
        state: PacingState.ended,
        expectedSpend: c.totalBudget,
        actualSpend: actualSpend,
        daysLeft: 0,
      );
    }
    final elapsed = today.difference(start).inDays + 1;
    final frac = totalDays > 0 ? elapsed / totalDays : 0;
    final expected = c.totalBudget * frac;
    final daysLeft = end.difference(today).inDays;

    // Project the date the budget runs out at the current daily rate.
    DateTime? budgetEndsOn;
    final dailyRate = elapsed > 0 ? actualSpend / elapsed : 0;
    if (dailyRate > 0 && c.totalBudget > 0) {
      final daysToExhaust = (c.totalBudget / dailyRate).ceil();
      budgetEndsOn = start.add(Duration(days: daysToExhaust - 1));
    }

    PacingState state;
    if (expected <= 0) {
      state = PacingState.onTrack;
    } else if (actualSpend < expected * 0.8) {
      state = PacingState.underpacing;
    } else if (actualSpend > expected * 1.1) {
      state = PacingState.overpacing;
    } else {
      state = PacingState.onTrack;
    }

    return Pacing(
      state: state,
      expectedSpend: expected,
      actualSpend: actualSpend,
      daysLeft: daysLeft,
      budgetEndsOn: budgetEndsOn,
    );
  }
}
