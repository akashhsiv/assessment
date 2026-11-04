import 'package:flutter/material.dart';

class MockDataNotice extends StatelessWidget {
  const MockDataNotice({super.key});
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFFFC857).withValues(alpha: .12),
          borderRadius: BorderRadius.circular(12)),
      child: const Row(children: [
        Icon(Icons.info_outline_rounded, color: Color(0xFFFFC857), size: 19),
        SizedBox(width: 9),
        Expanded(
            child: Text(
                'Illustrative mock market data — not verified live prices.',
                style: TextStyle(
                    color: Color(0xFFFFD77A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)))
      ]));
}
