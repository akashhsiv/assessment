class PriceHistoryPoint {
  const PriceHistoryPoint({required this.timestamp, required this.price});
  final DateTime timestamp;
  final double price;

  factory PriceHistoryPoint.fromJson(Map<String, dynamic> json) {
    final time = json['timestamp'] ?? json['time_open'];
    final rawPrice = json['price'] ?? json['close'];
    final timestamp = time == null ? null : DateTime.tryParse(time.toString());
    final price = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '');
    if (timestamp == null || price == null || !price.isFinite || price <= 0) {
      throw const FormatException('Invalid historical price point.');
    }
    return PriceHistoryPoint(timestamp: timestamp, price: price);
  }
}

class PriceHistoryResult {
  const PriceHistoryResult({required this.points, required this.source});
  final List<PriceHistoryPoint> points;
  final String source;
}
