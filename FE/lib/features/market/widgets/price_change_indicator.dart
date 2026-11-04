import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';

class PriceChangeIndicator extends StatelessWidget {
  const PriceChangeIndicator({super.key, this.value, this.compact = false});
  final num? value;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final positive = (value ?? 0) >= 0;
    final color = positive ? const Color(0xFF41D6A3) : const Color(0xFFFF687D);
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: compact ? 7 : 9, vertical: compact ? 4 : 6),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(8)),
        child: Text(formatPercent(value),
            style: TextStyle(
                color: color,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w700)));
  }
}
