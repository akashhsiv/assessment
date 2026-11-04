import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../market/models/coin_model.dart';
import '../services/watchlist_service.dart';

class WatchlistState {
  const WatchlistState(
      {this.coins = const [], this.loading = true, this.error});
  final List<CoinModel> coins;
  final bool loading;
  final String? error;
  WatchlistState copyWith(
          {List<CoinModel>? coins,
          bool? loading,
          String? error,
          bool clearError = false}) =>
      WatchlistState(
          coins: coins ?? this.coins,
          loading: loading ?? this.loading,
          error: clearError ? null : error ?? this.error);
}

final watchlistViewModelProvider =
    NotifierProvider<WatchlistViewModel, WatchlistState>(
        WatchlistViewModel.new);

class WatchlistViewModel extends Notifier<WatchlistState> {
  late WatchlistService _service;
  @override
  WatchlistState build() {
    _service = ref.read(watchlistServiceProvider);
    _load();
    return const WatchlistState();
  }

  Future<void> reload() async {
    state = state.copyWith(loading: true, clearError: true);
    await _load();
  }

  Future<void> _load() async {
    try {
      final coins = await _service.load();
      state = state.copyWith(coins: coins, loading: false, clearError: true);
    } catch (_) {
      state = state.copyWith(
          loading: false, error: 'Unable to read your saved watchlist.');
    }
  }

  bool contains(String id) => state.coins.any((c) => c.id == id);
  Future<void> toggle(CoinModel coin) async {
    final updated = [...state.coins];
    final index = updated.indexWhere((c) => c.id == coin.id);
    if (index >= 0) {
      updated.removeAt(index);
    } else {
      updated.add(coin);
    }
    state = state.copyWith(coins: updated, clearError: true);
    try {
      await _service.save(updated);
    } catch (_) {
      state =
          state.copyWith(error: 'Could not save changes to your watchlist.');
    }
  }

  Future<void> remove(String id) async {
    final updated = state.coins.where((c) => c.id != id).toList();
    state = state.copyWith(coins: updated);
    try {
      await _service.save(updated);
    } catch (_) {
      state =
          state.copyWith(error: 'Could not save changes to your watchlist.');
    }
  }
}
