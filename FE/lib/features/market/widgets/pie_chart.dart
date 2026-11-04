import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/formatters.dart';
import '../models/price_history_model.dart';

class InteractivePriceChart extends StatelessWidget {
  const InteractivePriceChart({super.key, required this.points});
  final List<PriceHistoryPoint> points;

  @override
  Widget build(BuildContext context) {
    final series = points
        .where((point) => point.price.isFinite && point.price > 0)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (series.isEmpty) {
      return const SizedBox(
        height: 210,
        child: Center(child: Text('No valid price points to chart')),
      );
    }

    final first = series.first.price;
    final last = series.last.price;
    final lineColor =
        last >= first ? const Color(0xFF41D6A3) : const Color(0xFFFF687D);
    final prices = series.map((point) => point.price);
    final low = prices.reduce((a, b) => math.min(a, b).toDouble());
    final high = prices.reduce((a, b) => math.max(a, b).toDouble());

    // A minimum range keeps flat/low-volatility assets visible without clipping zero.
    final range = math.max(high - low, high * .012).toDouble();
    final verticalPadding = range * .18;
    final minY = math.max(0.0, low - verticalPadding).toDouble();
    final maxY = high + verticalPadding;
    final maxX = math.max(1, series.length - 1).toDouble();
    final xInterval = maxX >= 3 ? maxX / 3 : 1.0;
    final yInterval = (maxY - minY) / 3;
    final spanHours =
        series.last.timestamp.difference(series.first.timestamp).inHours.abs();
    final datePattern = spanHours <= 48 ? 'HH:mm' : 'MMM d';

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        clipData: const FlClipData.all(),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (value) => FlLine(
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(.22),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 54,
              interval: yInterval,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                space: 8,
                child: Text(
                  formatCompact(value),
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: xInterval,
              getTitlesWidget: (value, meta) {
                final index = value.round().clamp(0, series.length - 1).toInt();
                final label = DateFormat(datePattern)
                    .format(series[index].timestamp.toLocal());
                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < series.length; i++)
                FlSpot(i.toDouble(), series[i].price),
            ],
            isCurved: false,
            color: lineColor,
            barWidth: 2.5,
            dotData: FlDotData(show: series.length < 36),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withOpacity(.20),
                  lineColor.withOpacity(.01)
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchSpotThreshold: 18,
          getTouchLineStart: (_, __) => 0,
          getTouchLineEnd: (_, __) => maxY,
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) => Theme.of(context).colorScheme.surface,
            getTooltipItems: (spots) => spots.map((spot) {
              final index = spot.x.round().clamp(0, series.length - 1).toInt();
              final point = series[index];
              final label = DateFormat('MMM d, y · HH:mm')
                  .format(point.timestamp.toLocal());
              return LineTooltipItem(
                '${formatPrice(point.price)}\n$label',
                TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList(),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }
}
