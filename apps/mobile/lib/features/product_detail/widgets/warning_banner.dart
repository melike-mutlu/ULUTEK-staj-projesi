import 'package:flutter/material.dart';

import '../../../core/models/explanation.dart';
import '../../../core/theme/akilli_sepet_colors.dart';
import '../../../core/theme/warning_level_style.dart';
import 'status_dot.dart';

/// Only the "Uygun değil" verdict gets an illustration; the softer levels stay
/// with the coloured dot.
const String _warningIcon = 'assets/other/warning.png';

/// Verdict — the anchor of the screen: the level on the left, the short verdict
/// and the personal reason on the right. No box: the colour alone carries it.
class WarningBanner extends StatelessWidget {
  const WarningBanner({super.key, required this.explanation});

  final Explanation explanation;

  /// The illustration spans the title and the reason standing next to it.
  static const double _iconSize = 110;

  String get _reason => explanation.warningMessage.isNotEmpty
      ? explanation.warningMessage
      : explanation.summary;

  bool get _isWarning => explanation.level == WarningLevel.warning;

  @override
  Widget build(BuildContext context) {
    final style = WarningLevelStyle.of(explanation.level);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_isWarning)
          Image.asset(
            _warningIcon,
            width: _iconSize,
            height: _iconSize,
            errorBuilder: (_, __, ___) =>
                StatusDot(level: explanation.level, size: 20),
          )
        else
          StatusDot(level: explanation.level, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                style.title,
                style: TextStyle(
                  color: style.main,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _reason,
                style: const TextStyle(
                  color: AkilliSepetColors.textSecondary,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              if (explanation.disclaimer.isNotEmpty) ...[
                // One blank line, then the disclaimer right under the reason.
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 13,
                      color: AkilliSepetColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        explanation.disclaimer,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AkilliSepetColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
