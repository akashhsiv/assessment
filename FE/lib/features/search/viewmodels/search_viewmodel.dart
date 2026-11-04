import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../market/models/coin_model.dart';
import '../../market/viewmodels/market_viewmodel.dart';

class SearchState {
  const SearchState(
      {this.query = '', this.matches = const [], this.loading = false});
  final String query;
  final List<CoinModel> matches;
  final bool loading;
}

final searchViewModelProvider =
    NotifierProvider<SearchViewModel, SearchState>(SearchViewModel.new);

class SearchViewModel extends Notifier<SearchState> {
  Timer? _debounce;
  List<CoinModel> _coins = const [];
  String _query = '';
  @override
  SearchState build() {
    _coins = ref.watch(marketViewModelProvider.select((s) => s.coins));
    ref.onDispose(() => _debounce?.cancel());
    return _filter(_query);
  }

  void setQuery(String query) {
    _query = query;
    state = SearchState(
        query: query, matches: state.matches, loading: query.trim().isNotEmpty);
    _debounce?.cancel();
    _debounce =
        Timer(const Duration(milliseconds: 280), () => state = _filter(query));
  }

  SearchState _filter(String query) {
    final term = query.trim().toLowerCase();
    final results = term.isEmpty
        ? <CoinModel>[]
        : _coins
            .where((coin) =>
                coin.name.toLowerCase().contains(term) ||
                coin.symbol.toLowerCase().contains(term))
            .toList();
    return SearchState(query: query, matches: results, loading: false);
  }
}
