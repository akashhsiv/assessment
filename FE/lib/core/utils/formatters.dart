import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(locale: 'en_US', symbol: r'$');
final _compact = NumberFormat.compactCurrency(locale: 'en_US', symbol: r'$');

String formatPrice(num? value) {
  if (value == null) return '—';
  if (value.abs() >= 1) return _currency.format(value);
  return '\$${value.toStringAsFixed(value.abs() < .0001 ? 8 : 4)}';
}

String formatCompact(num? value) =>
    value == null ? '—' : _compact.format(value);
String formatPercent(num? value) => value == null
    ? '—'
    : '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}%';
String formatSupply(num? value) =>
    value == null ? '—' : NumberFormat.compact(locale: 'en_US').format(value);
