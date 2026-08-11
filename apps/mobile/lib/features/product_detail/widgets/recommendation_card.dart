import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/models/alternative.dart';
import '../../../core/theme/app_text_styles.dart';
import 'alternative_thumbnail.dart';
import 'nutri_score_badge.dart';

/// A single alternative in the horizontally scrolling "Öneriler" list:
/// square image on the left, name + brand + Nutri-Score on the right.
///
/// The card has a fixed width but no fixed height — the parent list stretches
/// every card to the tallest one, so content (including large text scales) grows
/// and shrinks freely without ever overflowing.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.alternative,
    this.onTap,
  });

  final Alternative alternative;
  final VoidCallback? onTap;

  static const double _thumbSize = 88;
  static const double _cardWidth = 260;

  /// Card width scales down on narrow screens so at least part of the next card
  /// peeks in, hinting the list is scrollable.
  static double widthFor(BuildContext context) {
    final available = MediaQuery.sizeOf(context).width - 40; // page padding
    return math.min(_cardWidth, available * 0.72);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: widthFor(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AlternativeThumbnail(
              imageUrl: alternative.imageUrl,
              size: _thumbSize,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    alternative.productName,
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: NutriScoreBadge(grade: alternative.nutriscoreGrade),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
