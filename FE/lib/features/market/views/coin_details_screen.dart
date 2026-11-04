import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/mock_data_notice.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../models/coin_model.dart';
import '../viewmodels/coin_details_viewmodel.dart';
import '../viewmodels/market_viewmodel.dart';
import '../widgets/price_change_indicator.dart';

class CoinDetailsScreen extends ConsumerWidget {
  const CoinDetailsScreen({super.key, required this.coin});
  final CoinModel coin;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(coinDetailsViewModelProvider(coin));
    final isMock =
        ref.watch(marketViewModelProvider.select((s) => s.source == 'mock'));
    final periods = ChartPeriod.values;
    return Scaffold(
        appBar: AppBar(title: Text('${coin.name} details'), actions: [
          Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                  child: Text(coin.symbol,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700)))),
          const ThemeToggleButton(),
        ]),
        body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              if (isMock)
                const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: MockDataNotice()),
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(coin.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(
                                  child: Text(formatPrice(coin.price),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w800))),
                              PriceChangeIndicator(value: coin.change24h)
                            ]),
                            const SizedBox(height: 10),
                            Text('24-hour change',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)),
                          ]))),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                    child: Text('Price history',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800))),
                const Icon(Icons.touch_app_outlined, size: 18)
              ]),
              const SizedBox(height: 12),
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(children: [
                        Wrap(
                            spacing: 5,
                            children: List.generate(
                                periods.length,
                                (i) => ChoiceChip(
                                    label: Text(_periodLabel(periods[i])),
                                    selected: period == periods[i],
                                    onSelected: (_) => ref
                                        .read(coinDetailsViewModelProvider(coin)
                                            .notifier)
                                        .selectPeriod(periods[i])))),
                        const SizedBox(height: 10),
                        SizedBox(
                            height: 170,
                            child: _UnavailableChart(
                                points: ref
                                    .read(coinDetailsViewModelProvider(coin)
                                        .notifier)
                                    .historicalPoints)),
                        const SizedBox(height: 2),
                        Text(
                            'Historical prices are not available from the current backend.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                      ]))),
              const SizedBox(height: 22),
              Text('Market data',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Card(
                  child: Column(children: [
                _DataRow(
                    label: 'Market capitalization',
                    value: formatCompact(coin.marketCap)),
                _DataRow(
                    label: '24h trading volume',
                    value: formatCompact(coin.volume24h)),
                _DataRow(
                    label: 'Total supply',
                    value: formatSupply(coin.totalSupply)),
                _DataRow(
                    label: 'Maximum supply',
                    value: formatSupply(coin.maxSupply)),
                _DataRow(
                    label: 'All-time high', value: formatPrice(coin.athPrice)),
                _DataRow(
                    label: 'Below all-time high',
                    value: formatPercent(coin.percentFromAth),
                    last: true),
              ])),
            ]));
  }

  String _periodLabel(ChartPeriod p) => switch (p) {
        ChartPeriod.day => '24H',
        ChartPeriod.week => '7D',
        ChartPeriod.month => '30D',
        ChartPeriod.quarter => '90D',
        ChartPeriod.year => '1Y'
      };
}

class _UnavailableChart extends StatelessWidget {
  const _UnavailableChart({required this.points});
  final List<(double, double)> points;
  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.show_chart_rounded,
            size: 42,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: .6)),
        const SizedBox(height: 8),
        const Text('Chart data unavailable'),
      ]));
    }
    return LineChart(LineChartData(lineBarsData: [
      LineChartBarData(spots: points.map((e) => FlSpot(e.$1, e.$2)).toList())
    ]));
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value, this.last = false});
  final String label, value;
  final bool last;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(children: [
        Row(children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700))
        ]),
        if (!last)
          const Padding(
              padding: EdgeInsets.only(top: 14), child: Divider(height: 1)),
      ]));
}
