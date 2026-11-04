import 'package:flutter/material.dart';

class MarketLoadingSkeleton extends StatelessWidget {
  const MarketLoadingSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    final color =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: .08);
    Widget bar(double width, double height) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(8)));
    return ListView(padding: const EdgeInsets.all(16), children: [
      bar(180, 20),
      const SizedBox(height: 18),
      Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(
              4,
              (_) => SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 42) / 2,
                  height: 92,
                  child: Card(
                      child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [bar(82, 12), bar(106, 19)])))))),
      const SizedBox(height: 26),
      bar(190, 22),
      const SizedBox(height: 14),
      ...List.generate(
          6,
          (_) => Card(
              margin: const EdgeInsets.only(bottom: 9),
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    CircleAvatar(backgroundColor: color),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          bar(100, 13),
                          const SizedBox(height: 7),
                          bar(48, 10)
                        ])),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          bar(75, 13),
                          const SizedBox(height: 7),
                          bar(45, 11)
                        ]),
                  ])))),
    ]);
  }
}
