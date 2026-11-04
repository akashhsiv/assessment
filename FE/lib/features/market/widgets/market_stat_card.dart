import 'package:flutter/material.dart';

class MarketStatCard extends StatelessWidget {
  const MarketStatCard(
      {super.key,
      required this.title,
      required this.value,
      required this.icon,
      this.caption});
  final String title, value;
  final IconData icon;
  final String? caption;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(15),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon,
                  size: 17, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 7),
              Expanded(
                  child: Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)))
            ]),
            const SizedBox(height: 12),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            if (caption != null) ...[
              const SizedBox(height: 4),
              Text(caption!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant))
            ],
          ])));
}
