typedef JsonMap = Map<String, dynamic>;

class CoinModel {
  const CoinModel(
      {required this.id,
      required this.name,
      required this.symbol,
      this.rank,
      this.totalSupply,
      this.maxSupply,
      this.betaValue,
      this.firstDataAt,
      this.lastUpdated,
      this.price,
      this.volume24h,
      this.marketCap,
      this.change24h,
      this.change7d,
      this.change30d,
      this.change1y,
      this.athPrice,
      this.athDate,
      this.percentFromAth});

  final String id, name, symbol;
  final int? rank;
  final double? totalSupply, maxSupply, betaValue;
  final String? firstDataAt, lastUpdated;
  final double? price,
      volume24h,
      marketCap,
      change24h,
      change7d,
      change30d,
      change1y;
  final double? athPrice, percentFromAth;
  final String? athDate;

  factory CoinModel.fromJson(JsonMap json) {
    final quotes = _map(json['quotes']);
    final usd = _map(quotes['USD']);
    return CoinModel(
      id: _str(json['id']) ?? _str(json['symbol']) ?? 'unknown',
      name: _str(json['name']) ?? 'Unknown asset',
      symbol: (_str(json['symbol']) ?? '?').toUpperCase(),
      rank: _int(json['rank']),
      totalSupply: _double(json['total_supply']),
      maxSupply: _double(json['max_supply']),
      betaValue: _double(json['beta_value']),
      firstDataAt: _str(json['first_data_at']),
      lastUpdated: _str(json['last_updated']),
      price: _double(usd['price']),
      volume24h: _double(usd['volume_24h']),
      marketCap: _double(usd['market_cap']),
      change24h: _double(usd['percent_change_24h']),
      change7d: _double(usd['percent_change_7d']),
      change30d: _double(usd['percent_change_30d']),
      change1y: _double(usd['percent_change_1y']),
      athPrice: _double(usd['ath_price']),
      athDate: _str(usd['ath_date']),
      percentFromAth: _double(usd['percent_from_price_ath']),
    );
  }

  JsonMap toJson() => {
        'id': id,
        'name': name,
        'symbol': symbol,
        'rank': rank,
        'total_supply': totalSupply,
        'max_supply': maxSupply,
        'beta_value': betaValue,
        'first_data_at': firstDataAt,
        'last_updated': lastUpdated,
        'quotes': {
          'USD': {
            'price': price,
            'volume_24h': volume24h,
            'market_cap': marketCap,
            'percent_change_24h': change24h,
            'percent_change_7d': change7d,
            'percent_change_30d': change30d,
            'percent_change_1y': change1y,
            'ath_price': athPrice,
            'ath_date': athDate,
            'percent_from_price_ath': percentFromAth,
          }
        },
      };

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map<String, dynamic> ? value : <String, dynamic>{};
  static String? _str(dynamic value) => value == null ? null : value.toString();
  static double? _double(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');
  static int? _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');
}
