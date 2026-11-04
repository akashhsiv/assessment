import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../models/coin_model.dart';
import 'price_change_indicator.dart';

class CoinListItem extends StatelessWidget {
  const CoinListItem(
      {super.key,
      required this.coin,
      required this.onTap,
      this.isWatched = false,
      this.onWatchToggle});
  final CoinModel coin;
  final VoidCallback onTap;
  final bool isWatched;
  final VoidCallback? onWatchToggle;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(children: [
            SizedBox(
                width: 29,
                child: Text(coin.rank?.toString() ?? '—',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant))),
            CircleAvatar(
                radius: 19,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: .13),
                child: Text(
                    coin.symbol.length > 3
                        ? coin.symbol.substring(0, 3)
                        : coin.symbol,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary))),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(coin.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(coin.symbol,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                ])),
            const SizedBox(width: 4),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(formatPrice(coin.price),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 4),
              PriceChangeIndicator(value: coin.change24h, compact: true),
            ]),
            if (onWatchToggle != null)
              IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onWatchToggle,
                  icon: Icon(
                      isWatched
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: isWatched ? const Color(0xFFFFC857) : null)),
          ])));
}
