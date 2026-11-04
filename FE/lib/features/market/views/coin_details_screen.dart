import 'package:crypto_research/features/market/widgets/pie_chart.dart';
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
    final chartState = ref.watch(coinDetailsViewModelProvider(coin));
    final period = chartState.period;
    final chartData = chartState.points;
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
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                                spacing: 5,
                                children: List.generate(periods.length, (i) {
                                  final p = periods[i];
                                  return ChoiceChip(
                                      label: Text(_periodLabel(p)),
                                      selected: period == p,
                                      onSelected: (_) => ref
                                          .read(
                                              coinDetailsViewModelProvider(coin)
                                                  .notifier)
                                          .selectPeriod(p));
                                })),
                            const SizedBox(height: 12),
                            if (chartState.loading)
                              const SizedBox(
                                  height: 190,
                                  child: Center(
                                      child: CircularProgressIndicator()))
                            else if (chartData.isEmpty)
                              const SizedBox(
                                  height: 190,
                                  child: Center(
                                      child: Text(
                                          'Historical data is unavailable for this coin and period.',
                                          textAlign: TextAlign.center)))
                            else ...[
                              SizedBox(
                                  height: 210,
                                  child:
                                      InteractivePriceChart(points: chartData)),
                              const SizedBox(height: 8),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _EndpointLabel(
                                        label: chartState.source == 'summary'
                                            ? 'Start (derived)'
                                            : 'Period start',
                                        value:
                                            formatPrice(chartData.first.price)),
                                    if (chartState.changePercent != null)
                                      PriceChangeIndicator(
                                          value: chartState.changePercent),
                                    _EndpointLabel(
                                        label: 'Latest',
                                        value:
                                            formatPrice(chartData.last.price),
                                        alignEnd: true),
                                  ]),
                            ],
                            const SizedBox(height: 10),
                            Text(
                                chartState.source == 'live'
                                    ? 'Historical price points from the backend. Touch the chart to inspect a point.'
                                    : chartState.source == 'summary'
                                        ? 'Showing the API-reported period return as two endpoints. Deploy the backend history route for a full price series.'
                                        : 'No historical price data was returned. Check the connection or try another period.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)),
                            if (!chartState.loading)
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                      onPressed: ref
                                          .read(
                                              coinDetailsViewModelProvider(coin)
                                                  .notifier)
                                          .refresh,
                                      icon: const Icon(Icons.refresh_rounded,
                                          size: 16),
                                      label: const Text('Refresh chart'))),
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

class _EndpointLabel extends StatelessWidget {
  const _EndpointLabel(
      {required this.label, required this.value, this.alignEnd = false});
  final String label, value;
  final bool alignEnd;
  @override
  Widget build(BuildContext context) => Column(
          crossAxisAlignment:
              alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 3),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ]);
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
