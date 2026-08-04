import 'package:flutter/material.dart';

import '../../../core/theme/akilli_sepet_colors.dart';

/// One row of the scan history: product name (or barcode), a status note and
/// when it was scanned. Extracted from HomeView so both the home list and the
/// history sheet share it — and so its layout can be tested on its own.
class RecentScanCard extends StatelessWidget {
  const RecentScanCard({
    super.key,
    required this.title,
    required this.note,
    required this.noteColor,
    required this.backgroundColor,
    required this.time,
    this.onTap,
  });

  final String title;
  final String note;
  final Color noteColor;
  final Color backgroundColor;
  final String time;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        // Product names may wrap to several lines; the date stays pinned to the
        // top instead of drifting down with the growing text block.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: noteColor, width: 2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AkilliSepetColors.textPrimary,
                      ),
                  // Wrap instead of truncating: three lines hold any real
                  // product name, ellipsis only guards absurd input.
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: noteColor),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: noteColor,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AkilliSepetColors.textSecondary,
                ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      ),
    );
  }
}
