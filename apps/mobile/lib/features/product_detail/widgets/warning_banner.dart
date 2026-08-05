import 'package:flutter/material.dart';

import '../../../core/models/explanation.dart';
import '../../../core/theme/akilli_sepet_colors.dart';
import '../../../core/theme/warning_level_style.dart';
import 'status_dot.dart';

/// Sits left of the verdict; sized to the verdict text so the block keeps its
/// current height.
const String _verdictIcon = 'assets/other/warning.png';

/// Verdict — the anchor of the screen. A coloured dot next to a short verdict,
/// with the personal reason underneath. No box: the colour alone carries it.
class WarningBanner extends StatelessWidget {
  const WarningBanner({super.key, required this.explanation});

  final Explanation explanation;

  String get _reason => explanation.warningMessage.isNotEmpty
      ? explanation.warningMessage
      : explanation.summary;

  @override
  Widget build(BuildContext context) {
    final style = WarningLevelStyle.of(explanation.level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              _verdictIcon,
              width: 34,
              height: 34,
              errorBuilder: (_, __, ___) =>
                  StatusDot(level: explanation.level, size: 20),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                style.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: style.main,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _reason,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AkilliSepetColors.textSecondary,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        if (explanation.disclaimer.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            explanation.disclaimer,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AkilliSepetColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
