import 'package:flutter/material.dart';

import '../../../core/models/explanation.dart';
import '../../../core/theme/warning_level_style.dart';

/// Verdict banner — the visual anchor of the product detail screen.
/// Shows the personal suitability level and the reason behind it.
class WarningBanner extends StatelessWidget {
  const WarningBanner({super.key, required this.explanation});

  final Explanation explanation;

  String get _reason => explanation.warningMessage.isNotEmpty
      ? explanation.warningMessage
      : explanation.summary;

  @override
  Widget build(BuildContext context) {
    final style = WarningLevelStyle.of(explanation.level);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: style.background,
        border: Border.all(color: style.border, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: style.main.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(style.icon, color: style.main, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      style.title,
                      style: TextStyle(
                        color: style.main,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _reason,
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (explanation.disclaimer.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              explanation.disclaimer,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
