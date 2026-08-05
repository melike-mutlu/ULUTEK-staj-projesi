import 'package:flutter/material.dart';

import '../../../core/models/explanation.dart';
import '../../../core/theme/warning_level_style.dart';
import 'status_dot.dart';

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
            StatusDot(level: explanation.level, size: 20),
            const SizedBox(width: 12),
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
            color: Color(0xFF6B7280),
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
              color: Color(0xFFC0C4CC),
            ),
          ),
        ],
      ],
    );
  }
}
