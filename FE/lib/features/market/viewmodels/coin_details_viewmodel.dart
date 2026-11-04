import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coin_model.dart';
import '../models/price_history_model.dart';
import '../services/market_service.dart';

enum ChartPeriod { day, week, month, quarter, year }

class CoinDetailsState {
  const CoinDetailsState(
      {this.period = ChartPeriod.day,
      this.points = const [],
      this.loading = true,
      this.source = 'loading'});
  final ChartPeriod period;
  final List<PriceHistoryPoint> points;
  final bool loading;

  /// `live` = backend history endpoint; `summary` = two actual API-derived endpoints; `unavailable` = no values.
  final String source;
  double? get changePercent => points.length < 2 || points.first.price <= 0
      ? null
      : ((points.last.price / points.first.price) - 1) * 100;

  CoinDetailsState copyWith(
          {ChartPeriod? period,
          List<PriceHistoryPoint>? points,
          bool? loading,
          String? source}) =>
      CoinDetailsState(
          period: period ?? this.period,
          points: points ?? this.points,
          loading: loading ?? this.loading,
          source: source ?? this.source);
}

final coinDetailsViewModelProvider =
    NotifierProvider.family<CoinDetailsViewModel, CoinDetailsState, CoinModel>(
        CoinDetailsViewModel.new);

class CoinDetailsViewModel extends FamilyNotifier<CoinDetailsState, CoinModel> {
  late CoinModel _coin;
  late MarketService _service;
  int _requestId = 0;

  @override
  CoinDetailsState build(CoinModel coin) {
    _coin = coin;
    _service = ref.read(marketServiceProvider);
    scheduleMicrotask(() => _loadHistory(ChartPeriod.day));
    return const CoinDetailsState();
  }

  void selectPeriod(ChartPeriod period) {
    if (state.period == period && !state.loading) return;
    state = CoinDetailsState(period: period, loading: true, source: 'loading');
    unawaited(_loadHistory(period));
  }

  Future<void> refresh() async {
    state = CoinDetailsState(
        period: state.period, loading: true, source: 'loading');
    await _loadHistory(state.period);
  }

  Future<void> _loadHistory(ChartPeriod period) async {
    final requestId = ++_requestId;
    try {
      final result = await _service.fetchPriceHistory(
          coinId: _coin.id, period: _periodParam(period));
      if (requestId != _requestId) return;
      if (result.points.isNotEmpty) {
        state = CoinDetailsState(
            period: period,
            points: result.points,
            loading: false,
            source: 'live');
        return;
      }
    } catch (_) {
      if (requestId != _requestId) return;
    }

    if (requestId != _requestId) return;
    final summary = _summaryPoints(period);
    state = CoinDetailsState(
        period: period,
        points: summary,
        loading: false,
        source: summary.isEmpty ? 'unavailable' : 'summary');
  }

  List<PriceHistoryPoint> _summaryPoints(ChartPeriod period) {
    final price = _coin.price;
    final change = switch (period) {
      ChartPeriod.day => _coin.change24h,
      ChartPeriod.week => _coin.change7d,
      ChartPeriod.month => _coin.change30d,
      ChartPeriod.quarter => null,
      ChartPeriod.year => _coin.change1y,
    };
    if (price == null || price <= 0 || change == null) return const [];
    final divisor = 1 + change / 100;
    if (divisor <= 0) return const [];
    final startPrice = price / divisor;
    if (!startPrice.isFinite || !price.isFinite) return const [];
    final now = DateTime.now().toUtc();
    final start = now.subtract(Duration(
        days: switch (period) {
      ChartPeriod.day => 1,
      ChartPeriod.week => 7,
      ChartPeriod.month => 30,
      ChartPeriod.quarter => 90,
      ChartPeriod.year => 365,
    }));
    return [
      PriceHistoryPoint(timestamp: start, price: startPrice),
      PriceHistoryPoint(timestamp: now, price: price)
    ];
  }

  String _periodParam(ChartPeriod period) => switch (period) {
        ChartPeriod.day => '24h',
        ChartPeriod.week => '7d',
        ChartPeriod.month => '30d',
        ChartPeriod.quarter => '90d',
        ChartPeriod.year => '1y',
      };
}
