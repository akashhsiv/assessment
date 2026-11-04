import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/mock_data_notice.dart';
import '../../../core/widgets/state_panels.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../market/viewmodels/market_viewmodel.dart';
import '../../market/views/coin_details_screen.dart';
import '../../market/widgets/coin_list_item.dart';
import '../../watchlist/viewmodels/watchlist_viewmodel.dart';
import '../viewmodels/search_viewmodel.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(searchViewModelProvider);
    final market = ref.watch(marketViewModelProvider);
    final watchlist = ref.watch(watchlistViewModelProvider);
    return Scaffold(
        appBar: AppBar(
            title: const Text('Find a coin'),
            actions: const [ThemeToggleButton()]),
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: TextField(
                onChanged: ref.read(searchViewModelProvider.notifier).setQuery,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search name or symbol'),
              )),
          if (market.source == 'mock')
            const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: MockDataNotice()),
          Expanded(
            child: search.loading
                ? const Center(child: CircularProgressIndicator())
                : market.error != null && market.coins.isEmpty
                    ? ErrorPanel(
                        message: market.error!,
                        onRetry:
                            ref.read(marketViewModelProvider.notifier).refresh)
                    : search.query.trim().isEmpty
                        ? EmptyPanel(
                            title: market.coins.isEmpty
                                ? 'Loading the market list'
                                : 'Search the loaded market list',
                            subtitle: market.coins.isEmpty
                                ? 'Market data will appear once the API responds.'
                                : '${market.coins.length} tickers currently loaded; more load from the Market tab.')
                        : search.matches.isEmpty
                            ? const EmptyPanel(
                                title: 'No matching cryptocurrencies')
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 18),
                                itemCount: search.matches.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final coin = search.matches[index];
                                  return Card(
                                      child: CoinListItem(
                                          coin: coin,
                                          onTap: () => Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (_) =>
                                                      CoinDetailsScreen(
                                                          coin: coin))),
                                          isWatched: watchlist.coins
                                              .any((c) => c.id == coin.id),
                                          onWatchToggle: () => ref
                                              .read(watchlistViewModelProvider
                                                  .notifier)
                                              .toggle(coin)));
                                }),
          ),
        ]));
  }
}
