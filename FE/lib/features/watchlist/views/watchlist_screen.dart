import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/mock_data_notice.dart';
import '../../../core/widgets/state_panels.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../market/viewmodels/market_viewmodel.dart';
import '../../market/views/coin_details_screen.dart';
import '../../market/widgets/coin_list_item.dart';
import '../viewmodels/watchlist_viewmodel.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(watchlistViewModelProvider);
    final isMock =
        ref.watch(marketViewModelProvider.select((s) => s.source == 'mock'));
    return Scaffold(
        appBar: AppBar(
            title: const Text('Your watchlist'),
            actions: const [ThemeToggleButton()]),
        body: Column(children: [
          if (isMock)
            const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: MockDataNotice()),
          Expanded(
              child: state.loading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null && state.coins.isEmpty
                      ? ErrorPanel(
                          message: state.error!,
                          onRetry: ref
                              .read(watchlistViewModelProvider.notifier)
                              .reload)
                      : state.coins.isEmpty
                          ? const EmptyPanel(
                              title: 'Your watchlist is empty',
                              subtitle:
                                  'Star a coin in Market or Search to keep it close.')
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.coins.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final coin = state.coins[index];
                                return Card(
                                    child: CoinListItem(
                                        coin: coin,
                                        onTap: () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    CoinDetailsScreen(
                                                        coin: coin))),
                                        isWatched: true,
                                        onWatchToggle: () => ref
                                            .read(watchlistViewModelProvider
                                                .notifier)
                                            .remove(coin.id)));
                              })),
        ]));
  }
}
