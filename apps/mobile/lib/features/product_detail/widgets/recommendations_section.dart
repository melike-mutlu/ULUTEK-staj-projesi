import 'package:flutter/material.dart';

import '../../../core/models/alternative.dart';
import '../../../core/theme/app_text_styles.dart';
import 'recommendation_card.dart';
import 'recommendations_sheet.dart';

/// "Öneriler" section on product detail: a title with an optional "Tümünü gör"
/// link, a neutrality note, and a horizontally scrolling list of alternatives.
class RecommendationsSection extends StatelessWidget {
  const RecommendationsSection({super.key, required this.alternatives});

  final List<Alternative> alternatives;

  /// "Tümünü gör" only appears when there are more than this many items.
  static const int _seeAllThreshold = 3;

  @override
  Widget build(BuildContext context) {
    if (alternatives.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Expanded(
                child: Text('Öneriler', style: AppTextStyles.heading2),
              ),
              if (alternatives.length > _seeAllThreshold)
                GestureDetector(
                  onTap: () => showRecommendationsSheet(context, alternatives),
                  behavior: HitTestBehavior.opaque,
                  child:
                      const Text('Tümünü gör', style: AppTextStyles.profileLink),
                ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Seçimlerimiz tarafsızdır: hiçbir marka burada yer almak için ödeme yapmaz.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: alternatives.length,
              separatorBuilder: (_, __) => const SizedBox(width: 20),
              itemBuilder: (context, index) {
                return RecommendationCard(alternative: alternatives[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
