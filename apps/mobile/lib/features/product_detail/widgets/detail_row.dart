import 'package:flutter/material.dart';

import '../../../core/models/explanation.dart';
import '../../../core/theme/akilli_sepet_colors.dart';
import 'status_dot.dart';

/// One list row: leading icon, title with an explanatory subtitle, an optional
/// value and a status dot. Every section on the screen uses it, so spacing and
/// type stay identical everywhere.
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.value,
    this.level,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final String? value;
  final WarningLevel? level;

  /// Keeps the icon column the same width as the divider inset.
  static const double leadingWidth = 64;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: leadingWidth,
            child: Center(child: leading ?? const SizedBox.shrink()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                    height: 1.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AkilliSepetColors.textSecondary,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: 10),
            Text(
              value!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AkilliSepetColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(width: 10),
          SizedBox(
            width: 12,
            child: level == null ? null : StatusDot(level: level!, size: 12),
          ),
        ],
      ),
    );
  }
}
