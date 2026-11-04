import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../models/coin_model.dart';
import '../models/market_model.dart';
import '../models/pagination_model.dart';
import '../services/market_service.dart';

enum CoinSort { marketCap, price, volume, change }

enum ChangeFilter { all, positive, negative }

class MarketState {
  const MarketState(
      {this.coins = const [],
      this.stats,
      this.source = 'live',
      this.loading = true,
      this.paginationLoading = false,
      this.hasMore = true,
      this.page = 0,
      this.error,
      this.query = '',
      this.sort = CoinSort.marketCap,
      this.filter = ChangeFilter.all});
  final List<CoinModel> coins;
  final MarketStats? stats;
  final String source;
  final bool loading, paginationLoading, hasMore;
  final int page;
  final String? error;
  final String query;
  final CoinSort sort;
  final ChangeFilter filter;

  MarketState copyWith(
          {List<CoinModel>? coins,
          MarketStats? stats,
          String? source,
          bool? loading,
          bool? paginationLoading,
          bool? hasMore,
          int? page,
          String? error,
          bool clearError = false,
          String? query,
          CoinSort? sort,
          ChangeFilter? filter}) =>
      MarketState(
          coins: coins ?? this.coins,
          stats: stats ?? this.stats,
          source: source ?? this.source,
          loading: loading ?? this.loading,
          paginationLoading: paginationLoading ?? this.paginationLoading,
          hasMore: hasMore ?? this.hasMore,
          page: page ?? this.page,
          error: clearError ? null : error ?? this.error,
          query: query ?? this.query,
          sort: sort ?? this.sort,
          filter: filter ?? this.filter);

  List<CoinModel> get visibleCoins {
    final needle = query.trim().toLowerCase();
    final result = coins.where((c) {
      final matches = needle.isEmpty ||
          c.name.toLowerCase().contains(needle) ||
          c.symbol.toLowerCase().contains(needle);
      final change = c.change24h ?? 0;
      final filtered = filter == ChangeFilter.all ||
          (filter == ChangeFilter.positive && change > 0) ||
          (filter == ChangeFilter.negative && change < 0);
      return matches && filtered;
    }).toList();
    result.sort((a, b) {
      final av = _sortValue(a), bv = _sortValue(b);
      return bv.compareTo(av);
    });
    return result;
  }

  double _sortValue(CoinModel c) => switch (sort) {
        CoinSort.marketCap => c.marketCap ?? 0,
        CoinSort.price => c.price ?? 0,
        CoinSort.volume => c.volume24h ?? 0,
        CoinSort.change => c.change24h ?? 0,
      };
}

final marketViewModelProvider =
    NotifierProvider<MarketViewModel, MarketState>(MarketViewModel.new);

class MarketViewModel extends Notifier<MarketState> {
  late MarketService _service;
  @override
  MarketState build() {
    _service = ref.read(marketServiceProvider);
    scheduleMicrotask(loadInitial);
    return const MarketState();
  }

  Future<void> loadInitial() async {
    if (state.loading && state.page > 0) return;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final result =
          await _service.fetchTickers(page: 1, perPage: AppConstants.pageSize);
      MarketStats? stats = state.stats;
      String source = result.source;
      try {
        final global = await _service.fetchGlobal(result.coins);
        stats = global.stats;
        if (global.source == 'mock') source = 'mock';
      } catch (_) {/* global stats are optional; ticker view remains useful */}
      state = state.copyWith(
          coins: result.coins,
          stats: stats,
          source: source,
          page: 1,
          hasMore: result.pagination.hasNext,
          loading: false,
          clearError: true);
    } catch (e) {
      state = state.copyWith(loading: false, error: _friendlyError(e));
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final result =
          await _service.fetchTickers(page: 1, perPage: AppConstants.pageSize);
      MarketStats? stats = state.stats;
      String source = result.source;
      try {
        final global = await _service.fetchGlobal(result.coins);
        stats = global.stats;
        if (global.source == 'mock') source = 'mock';
      } catch (_) {}
      state = state.copyWith(
          coins: result.coins,
          stats: stats,
          source: source,
          page: 1,
          hasMore: result.pagination.hasNext,
          loading: false,
          clearError: true);
    } catch (e) {
      // Keep the previous page and list visible when refresh fails.
      state = state.copyWith(loading: false, error: _friendlyError(e));
    }
  }

  Future<void> loadNextPage() async {
    if (state.loading ||
        state.paginationLoading ||
        !state.hasMore ||
        state.page == 0) {
      return;
    }
    state = state.copyWith(paginationLoading: true, clearError: true);
    try {
      final result = await _service.fetchTickers(
          page: state.page + 1, perPage: AppConstants.pageSize);
      final seen = state.coins.map((c) => c.id).toSet();
      final appended = [
        ...state.coins,
        ...result.coins.where((c) => seen.add(c.id))
      ];
      state = state.copyWith(
          coins: appended,
          page: result.pagination.page,
          hasMore: result.pagination.hasNext,
          source: result.source,
          paginationLoading: false);
    } catch (e) {
      state =
          state.copyWith(paginationLoading: false, error: _friendlyError(e));
    }
  }

  void setQuery(String value) => state = state.copyWith(query: value);
  void setSort(CoinSort value) => state = state.copyWith(sort: value);
  void setFilter(ChangeFilter value) => state = state.copyWith(filter: value);

  String _friendlyError(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return 'The market request timed out. Check your connection and retry.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'Could not connect. Check your internet connection.';
      }
      return 'Market service error${e.response?.statusCode == null ? '' : ' (${e.response!.statusCode})'}. Please retry.';
    }
    if (e is FormatException) return e.message;
    return 'Unable to load market data. Please try again.';
  }
}
