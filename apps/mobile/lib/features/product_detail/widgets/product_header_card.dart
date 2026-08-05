import 'package:flutter/material.dart';
import '../../../core/models/product.dart';

/// Nutri-Score values Open Food Facts sends when it has no grade.
const _unknownNutriScores = <String>{'unknown', 'not-applicable'};

/// Compact product identity: thumbnail + name, brand, badges and barcode.
/// Kept deliberately small so the verdict below it stays the visual anchor.
class ProductHeaderCard extends StatelessWidget {
  const ProductHeaderCard({super.key, required this.product});

  final Product product;

  static const double _thumbnailSize = 64;

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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Thumbnail(imageUrl: product.imageUrl, size: _thumbnailSize),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                  height: 1.25,
                ),
              ),
              if (brand != null && brand.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  brand,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
              if (product.isPending || score != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (product.isPending) const _PendingBadge(),
                    if (score != null) _NutriScoreBadge(score: score),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.qr_code_2_rounded,
                      size: 14, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      product.barcode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.imageUrl, required this.size});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Some Open Food Facts URLs are http; iOS blocks those by default.
    final url = imageUrl?.trim().replaceFirst(RegExp('^http://'), 'https://');

    return Container(
      width: size,
      height: size,
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
        size: 24,
        color: Color(0xFF9CA3AF),
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
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.gpp_maybe_rounded, size: 13, color: Color(0xFFB45309)),
          SizedBox(width: 4),
          Text(
            'Doğrulanmadı',
            style: TextStyle(
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

class _NutriScoreBadge extends StatelessWidget {
  const _NutriScoreBadge({required this.score});

  final String score;

  static const _scoreColors = <String, Color>{
    'A': Color(0xFF038141),
    'B': Color(0xFF85BB2F),
    'C': Color(0xFFFECB02),
    'D': Color(0xFFEE8100),
    'E': Color(0xFFE63E11),
  };

  @override
  Widget build(BuildContext context) {
    final color = _scoreColors[score] ?? const Color(0xFF9CA3AF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(
        'Nutri-Score $score',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
