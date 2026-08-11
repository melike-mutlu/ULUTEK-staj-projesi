import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/models/alternative.dart';
import '../../../core/theme/app_text_styles.dart';
import 'alternative_thumbnail.dart';
import 'nutri_score_badge.dart';

/// A single alternative in the horizontally scrolling "Öneriler" list:
/// square image on the left, name + brand + Nutri-Score on the right.
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
  static const int _nameMaxLines = 2;
  static const double _nameGap = 2;
  static const double _badgeGap = 10;

  /// Card width scales down on narrow screens so at least part of the next card
  /// peeks in, hinting the list is scrollable.
  static double widthFor(BuildContext context) {
    final available = MediaQuery.sizeOf(context).width - 40; // page padding
    return math.min(_cardWidth, available * 0.72);
  }

  /// Height needed for the tallest card, honouring the user's text scale so the
  /// horizontal list never overflows regardless of device or font settings.
  static double heightFor(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    double lineHeight(TextStyle style, [int lines = 1]) =>
        scaler.scale(style.fontSize!) * (style.height ?? 1.2) * lines;

    // Matches the column below: name (up to 2 lines), brand, then the badge row.
    final columnHeight = lineHeight(AppTextStyles.title, _nameMaxLines) +
        _nameGap +
        lineHeight(AppTextStyles.caption) +
        _badgeGap +
        _badgeHeight(context);

    // The image sets a floor; the text column can grow past it when scaled up.
    return math.max(_thumbSize, columnHeight).ceilToDouble();
  }

  /// Fixed height of the Nutri-Score chip, including its vertical padding.
  static double _badgeHeight(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    const badgeFontSize = 11.0;
    const badgeVerticalPadding = 4.0;
    return scaler.scale(badgeFontSize) * 1.2 + badgeVerticalPadding * 2;
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
                children: [
                  Text(
                    alternative.productName,
                    maxLines: _nameMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: _nameGap),
                  Text(
                    alternative.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: _badgeGap),
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
