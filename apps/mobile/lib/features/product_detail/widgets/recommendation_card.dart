import 'package:flutter/material.dart';

import '../../../core/models/alternative.dart';
import '../../../core/theme/app_text_styles.dart';
import 'alternative_score_badge.dart';
import 'alternative_thumbnail.dart';

/// A single alternative in the horizontally scrolling "Öneriler" list:
/// square image on the left, name + brand + score on the right.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.alternative,
    this.onTap,
  });

  final Alternative alternative;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 260,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AlternativeThumbnail(imageUrl: alternative.imageUrl, size: 88),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alternative.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alternative.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 10),
                  AlternativeScoreBadge(score: alternative.score),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
