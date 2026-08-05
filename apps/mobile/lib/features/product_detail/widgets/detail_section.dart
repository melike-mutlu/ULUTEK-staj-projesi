import 'package:flutter/material.dart';

/// Flat, card-less section: a bold title and rows separated by hairlines.
/// No borders or shadows — the screen reads as one list, not stacked cards.
class DetailSection extends StatelessWidget {
  const DetailSection({
    super.key,
    required this.title,
    required this.children,
    this.meta,
  });

  final String title;

  /// Small grey text on the right of the title, e.g. "100 g için".
  final String? meta;

  final List<Widget> children;

  /// Dividers start after the leading icon, like a native list.
  static const double dividerInset = 72;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                if (meta != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    meta!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ],
            ),
          ),
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.only(left: dividerInset),
                child:
                    Divider(height: 1, thickness: 1, color: Color(0xFFEDEEF0)),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}
