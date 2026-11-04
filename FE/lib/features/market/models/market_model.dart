import 'coin_model.dart';

class MarketStats {
  const MarketStats(
      {this.marketCapUsd,
      this.volume24hUsd,
      this.bitcoinDominance,
      this.cryptocurrenciesCount,
      this.marketsCount,
      this.marketCapChange24h});
  final double? marketCapUsd,
      volume24hUsd,
      bitcoinDominance,
      marketCapChange24h;
  final int? cryptocurrenciesCount, marketsCount;

  factory MarketStats.fromApi(dynamic raw, List<CoinModel> coins) {
    if (raw is Map) {
      double? d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v');
      int? i(dynamic v) => v is num ? v.toInt() : int.tryParse('$v');
      return MarketStats(
          marketCapUsd: d(raw['market_cap_usd']),
          volume24hUsd: d(raw['volume_24h_usd']),
          bitcoinDominance: d(raw['bitcoin_dominance_percentage']),
          cryptocurrenciesCount: i(raw['cryptocurrencies_number']),
          marketsCount: i(raw['markets_number']),
          marketCapChange24h: d(raw['market_cap_change_24h']));
    }
    // Backwards compatibility for the currently deployed endpoint if it returns ticker rows.
    final cap = coins.fold<double>(0, (sum, c) => sum + (c.marketCap ?? 0));
    final volume = coins.fold<double>(0, (sum, c) => sum + (c.volume24h ?? 0));
    final btc = coins
        .where((c) => c.symbol.toUpperCase() == 'BTC')
        .fold<double>(0, (sum, c) => sum + (c.marketCap ?? 0));
    return MarketStats(
        marketCapUsd: cap == 0 ? null : cap,
        volume24hUsd: volume == 0 ? null : volume,
        bitcoinDominance: cap == 0 ? null : btc * 100 / cap,
        cryptocurrenciesCount: coins.isEmpty ? null : coins.length);
  }
}
