import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/coin_model.dart';
import '../models/market_model.dart';
import '../models/pagination_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TickerPage {
  const TickerPage(
      {required this.coins, required this.pagination, required this.source});
  final List<CoinModel> coins;
  final PaginationModel pagination;
  final String source;
}

class MarketData {
  const MarketData({required this.stats, required this.source});
  final MarketStats stats;
  final String source;
}

final marketServiceProvider =
    Provider<MarketService>((ref) => MarketService(ref.watch(dioProvider)));

class MarketService {
  MarketService(this._dio);
  final Dio _dio;

  Future<MarketData> fetchGlobal(List<CoinModel> knownCoins) async {
    final response = await _dio.get<dynamic>('/api/market/global');
    final body = _asMap(response.data);
    final raw = body['data'];
    final source = body['source']?.toString() ?? 'live';
    List<CoinModel> rows = knownCoins;
    if (raw is List) {
      final parsed = raw
          .whereType<Map>()
          .map((e) => CoinModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (parsed.isNotEmpty) rows = parsed;
    }
    return MarketData(stats: MarketStats.fromApi(raw, rows), source: source);
  }

  Future<TickerPage> fetchTickers(
      {required int page, required int perPage}) async {
    final response = await _dio.get<dynamic>('/api/market/tickers',
        queryParameters: {'page': page, 'per_page': perPage});
    final body = _asMap(response.data);
    final raw = body['data'];
    if (raw is! List) {
      throw const FormatException('The ticker response was not a list.');
    }
    final coins = raw
        .whereType<Map>()
        .map((e) => CoinModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final pagination = PaginationModel.fromJson(
        body['pagination'] is Map
            ? Map<String, dynamic>.from(body['pagination'] as Map)
            : null,
        fallbackPage: page,
        fallbackPerPage: perPage,
        fallbackTotal: coins.length);
    return TickerPage(
        coins: coins,
        pagination: pagination,
        source: body['source']?.toString() ?? 'live');
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const FormatException('The server returned an unexpected response.');
  }
}
