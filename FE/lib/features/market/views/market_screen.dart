import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/mock_data_notice.dart';
import '../../../core/widgets/state_panels.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../watchlist/viewmodels/watchlist_viewmodel.dart';
import '../models/coin_model.dart';
import '../viewmodels/market_viewmodel.dart';
import '../widgets/coin_list_item.dart';
import '../widgets/market_stat_card.dart';
import '../widgets/market_loading_skeleton.dart';
import 'coin_details_screen.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});
  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  final _scroll = ScrollController();
  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.hasClients && _scroll.position.extentAfter < 420) {
      ref.read(marketViewModelProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _openCoin(CoinModel coin) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => CoinDetailsScreen(coin: coin)));

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketViewModelProvider);
    final watchlist = ref.watch(watchlistViewModelProvider);
    final vm = ref.read(marketViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Market overview'), actions: [
        IconButton(
            tooltip: 'Refresh',
            onPressed: vm.refresh,
            icon: const Icon(Icons.refresh_rounded)),
        const ThemeToggleButton(),
        const SizedBox(width: 6),
      ]),
      body: state.loading && state.coins.isEmpty
          ? const MarketLoadingSkeleton()
          : state.error != null && state.coins.isEmpty
              ? ErrorPanel(message: state.error!, onRetry: vm.refresh)
              : RefreshIndicator(
                  onRefresh: vm.refresh,
                  child: CustomScrollView(
                      controller: _scroll,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                            child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 14),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('The market, at a glance',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant)),
                                      if (state.source == 'mock') ...[
                                        const SizedBox(height: 12),
                                        const MockDataNotice()
                                      ],
                                      const SizedBox(height: 16),
                                      GridView.count(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          childAspectRatio: 1.72,
                                          children: [
                                            MarketStatCard(
                                                title: 'Market cap',
                                                value: formatCompact(
                                                    state.stats?.marketCapUsd),
                                                icon: Icons
                                                    .pie_chart_outline_rounded,
                                                caption: state.stats
                                                            ?.marketCapChange24h ==
                                                        null
                                                    ? '24h change unavailable'
                                                    : formatPercent(state.stats!
                                                        .marketCapChange24h)),
                                            MarketStatCard(
                                                title: '24h volume',
                                                value: formatCompact(
                                                    state.stats?.volume24hUsd),
                                                icon: Icons.swap_vert_rounded),
                                            MarketStatCard(
                                                title: 'BTC dominance',
                                                value: state.stats
                                                            ?.bitcoinDominance ==
                                                        null
                                                    ? '—'
                                                    : '${state.stats!.bitcoinDominance!.toStringAsFixed(1)}%',
                                                icon:
                                                    Icons.donut_large_rounded),
                                            MarketStatCard(
                                                title: 'Cryptocurrencies',
                                                value: state.stats
                                                        ?.cryptocurrenciesCount
                                                        ?.toString() ??
                                                    '—',
                                                icon: Icons
                                                    .currency_bitcoin_rounded),
                                          ]),
                                      const SizedBox(height: 22),
                                      Row(children: [
                                        Expanded(
                                            child: Text('Top cryptocurrencies',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w800))),
                                        DropdownButton<CoinSort>(
                                            value: state.sort,
                                            underline: const SizedBox.shrink(),
                                            icon:
                                                const Icon(Icons.sort_rounded),
                                            items: const [
                                              DropdownMenuItem(
                                                  value: CoinSort.marketCap,
                                                  child: Text('Market cap')),
                                              DropdownMenuItem(
                                                  value: CoinSort.price,
                                                  child: Text('Price')),
                                              DropdownMenuItem(
                                                  value: CoinSort.volume,
                                                  child: Text('Volume')),
                                              DropdownMenuItem(
                                                  value: CoinSort.change,
                                                  child: Text('24h change'))
                                            ],
                                            onChanged: (v) {
                                              if (v != null) vm.setSort(v);
                                            }),
                                      ]),
                                      const SizedBox(height: 10),
                                      TextField(
                                          onChanged: vm.setQuery,
                                          decoration: const InputDecoration(
                                              hintText: 'Filter loaded coins',
                                              prefixIcon:
                                                  Icon(Icons.search_rounded))),
                                      const SizedBox(height: 10),
                                      Wrap(spacing: 8, children: [
                                        _FilterChip(
                                            label: 'All',
                                            selected: state.filter ==
                                                ChangeFilter.all,
                                            onTap: () =>
                                                vm.setFilter(ChangeFilter.all)),
                                        _FilterChip(
                                            label: 'Gainers',
                                            selected: state.filter ==
                                                ChangeFilter.positive,
                                            onTap: () => vm.setFilter(
                                                ChangeFilter.positive)),
                                        _FilterChip(
                                            label: 'Losers',
                                            selected: state.filter ==
                                                ChangeFilter.negative,
                                            onTap: () => vm.setFilter(
                                                ChangeFilter.negative)),
                                      ]),
                                    ]))),
                        if (state.error != null)
                          SliverToBoxAdapter(
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(state.error!,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error)))),
                        if (state.visibleCoins.isEmpty)
                          SliverFillRemaining(
                              hasScrollBody: false,
                              child: EmptyPanel(
                                  title: state.coins.isEmpty
                                      ? 'No market data yet'
                                      : 'No matching coins'))
                        else
                          SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                              sliver: SliverList.builder(
                                  itemCount: state.visibleCoins.length +
                                      (state.paginationLoading ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == state.visibleCoins.length) {
                                      return const Padding(
                                          padding: EdgeInsets.all(18),
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()));
                                    }
                                    final coin = state.visibleCoins[index];
                                    return Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        child: CoinListItem(
                                            coin: coin,
                                            onTap: () => _openCoin(coin),
                                            isWatched: watchlist.coins
                                                .any((c) => c.id == coin.id),
                                            onWatchToggle: () => ref
                                                .read(watchlistViewModelProvider
                                                    .notifier)
                                                .toggle(coin)));
                                  }))
                      ])),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => FilterChip(
      label: Text(label), selected: selected, onSelected: (_) => onTap());
}
