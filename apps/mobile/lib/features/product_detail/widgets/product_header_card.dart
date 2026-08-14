import 'package:flutter/material.dart';
import '../../../core/models/product.dart';
import '../../../core/theme/akilli_sepet_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'nutri_score_badge.dart';

import 'community_verification_card.dart';

/// Nutri-Score values Open Food Facts sends when it has no grade.
const _unknownNutriScores = <String>{'unknown', 'not-applicable'};

/// Product identity: thumbnail, name, brand and badges.
/// The barcode is not shown — it is a lookup key, not information the user
/// needs while deciding.
class ProductHeaderCard extends StatelessWidget {
  const ProductHeaderCard({
    super.key,
    required this.product,
    this.upvotes,
    this.downvotes,
    this.userVote,
    this.onVoteApprove,
    this.onVoteReject,
  });

  final Product product;
  final int? upvotes;
  final int? downvotes;
  final String? userVote;
  final VoidCallback? onVoteApprove;
  final VoidCallback? onVoteReject;

  /// The image takes 40% of the available width; the name gets the rest.
  static const double _imageWidthFactor = 0.4;

  String? get _nutriScore {
    final score = product.nutriscore?.trim().toLowerCase();
    if (score == null || score.isEmpty || _unknownNutriScores.contains(score)) {
      return null;
    }
    return score.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final brand = product.brand?.trim();
    final score = _nutriScore;

    // LayoutBuilder, not MediaQuery: the card is also rendered inside narrower
    // boxes (tests, future split layouts) and must scale with its parent.
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Thumbnail(
                imageUrl: product.imageUrl,
                width: constraints.maxWidth * _imageWidthFactor,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (brand != null && brand.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AkilliSepetColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Badges sit under the row: next to the name they would have to
          // shrink, and a safety badge must never be clipped.
          if (product.isPending || score != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (product.isPending) const _PendingBadge(),
                if (score != null) NutriScoreBadge(grade: score),
              ],
            ),
          ],
          if (product.isPending && onVoteApprove != null && onVoteReject != null) ...[
            const SizedBox(height: 12),
            CommunityVerificationCard(
              upvotes: upvotes ?? 14,
              downvotes: downvotes ?? 3,
              userVote: userVote,
              onVoteApprove: onVoteApprove!,
              onVoteReject: onVoteReject!,
            ),
          ],
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.imageUrl, required this.width});

  final String? imageUrl;
  final double width;

  @override
  Widget build(BuildContext context) {
    // Some Open Food Facts URLs are http; iOS blocks those by default.
    final url = imageUrl?.trim().replaceFirst(RegExp('^http://'), 'https://');

    return Container(
      width: width,
      height: width,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null || url.isEmpty
          ? const _ThumbnailPlaceholder()
          : Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const _ThumbnailPlaceholder(),
            ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 32,
        color: AkilliSepetColors.textSecondary,
      ),
    );
  }
}

class _PendingBadge extends StatelessWidget {
  const _PendingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.gpp_maybe_rounded, size: 13, color: Color(0xFFB45309)),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context).unverified,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB45309),
            ),
          ),
        ],
      ),
    );
  }
}

