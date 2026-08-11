import 'package:flutter/material.dart';

import '../../../core/models/alternative.dart';
import '../../../core/theme/app_text_styles.dart';
import 'alternative_score_style.dart';

/// Coloured dot plus score label ("Mükemmel" / "İyi") for an alternative.
class AlternativeScoreBadge extends StatelessWidget {
  const AlternativeScoreBadge({super.key, required this.score});

  final AlternativeScore score;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: score.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(score.label, style: AppTextStyles.bodyMuted),
      ],
    );
  }
}
