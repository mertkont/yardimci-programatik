import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';

/// A small line chart for a single metric over time, themed to the app.
class LineTrend extends StatelessWidget {
  final List<double> values;
  final List<String> labels; // date label per point
  final Color color;
  final String Function(double) tooltipFmt;
  final bool currencyAxis;
  final double? referenceY; // e.g. total budget
  final String? referenceLabel;

  const LineTrend({
    super.key,
    required this.values,
    required this.labels,
    required this.color,
    required this.tooltipFmt,
    this.currencyAxis = false,
    this.referenceY,
    this.referenceLabel,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final n = values.length;
    final spots = [
      for (var i = 0; i < n; i++) FlSpot(i.toDouble(), values[i]),
    ];

    var maxY = values.fold<double>(0, (m, v) => v > m ? v : m);
    if (referenceY != null && referenceY! > maxY) maxY = referenceY!;
    if (maxY <= 0) maxY = 1;
    maxY *= 1.18; // headroom
    final labelStep = ((n - 1) / 3).ceil().clamp(1, n);

    String axis(double v) =>
        currencyAxis ? Fmt.compact(v) : Fmt.compact(v);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (n - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (v) =>
                FlLine(color: p.line, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: maxY / 4,
                getTitlesWidget: (v, meta) {
                  if (v == 0 || v >= meta.max) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(axis(v),
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: p.muted)),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (v, meta) {
                  final i = v.round();
                  if (i < 0 || i >= n) return const SizedBox.shrink();
                  if (i % labelStep != 0 && i != n - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(labels[i],
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: p.muted)),
                  );
                },
              ),
            ),
          ),
          extraLinesData: referenceY == null
              ? const ExtraLinesData()
              : ExtraLinesData(horizontalLines: [
                  HorizontalLine(
                    y: referenceY!,
                    color: p.muted,
                    strokeWidth: 1.4,
                    dashArray: [6, 4],
                    label: HorizontalLineLabel(
                      show: referenceLabel != null,
                      alignment: Alignment.topRight,
                      style: TextStyle(
                          fontFamily: 'Inter', fontSize: 10, color: p.muted),
                      labelResolver: (_) => referenceLabel ?? '',
                    ),
                  ),
                ]),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => p.ink,
              getTooltipItems: (touched) => touched.map((s) {
                final i = s.x.round();
                final date = (i >= 0 && i < n) ? '${labels[i]}\n' : '';
                return LineTooltipItem(
                  '$date${tooltipFmt(s.y)}',
                  const TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.25,
              color: color,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: n <= 14),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.20),
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
