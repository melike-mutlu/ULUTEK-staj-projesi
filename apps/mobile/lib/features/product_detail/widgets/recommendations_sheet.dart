import 'package:flutter/material.dart';

import '../../../core/models/alternative.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'alternative_score_badge.dart';
import 'alternative_thumbnail.dart';

/// Opens the "Tümünü gör" bottom sheet listing every recommended alternative.
Future<void> showRecommendationsSheet(
  BuildContext context,
  List<Alternative> alternatives,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RecommendationsSheet(alternatives: alternatives),
  );
}

class _RecommendationsSheet extends StatelessWidget {
  const _RecommendationsSheet({required this.alternatives});

  final List<Alternative> alternatives;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              const _SheetHandle(),
              const _SheetHeader(),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: alternatives.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
                  itemBuilder: (context, index) {
                    return _RecommendationRow(alternative: alternatives[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 12, 12),
      child: Row(
        children: [
          // Balances the trailing menu icon so the title stays centred.
          SizedBox(width: 40),
          Expanded(
            child: Text(
              'Öneriler',
              textAlign: TextAlign.center,
              style: AppTextStyles.title,
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_horiz_rounded),
            color: AppColors.textSecondary,
            onPressed: null, // Not wired up yet.
          ),
        ],
      ),
    );
  }
}

/// One alternative as a full-width row: image, name + brand + score, chevron.
class _RecommendationRow extends StatelessWidget {
  const _RecommendationRow({required this.alternative});

  final Alternative alternative;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          AlternativeThumbnail(imageUrl: alternative.imageUrl, size: 64),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alternative.name,
                  maxLines: 1,
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
                const SizedBox(height: 8),
                AlternativeScoreBadge(score: alternative.score),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
