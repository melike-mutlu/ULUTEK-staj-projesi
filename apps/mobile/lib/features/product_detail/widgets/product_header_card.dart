import 'package:flutter/material.dart';
import '../../../core/models/product.dart';

/// Ürün adı, marka, barkod ve Nutri-Score rozetini gösteren kart widget'ı.
class ProductHeaderCard extends StatelessWidget {
  const ProductHeaderCard({super.key, required this.product});

  final Product product;

  Widget _buildNutriScoreBadge(String score) {
    final cleanScore = score.trim().toUpperCase();
    
    Color getScoreColor(String s) {
      switch (s) {
        case 'A':
          return const Color(0xFF038141);
        case 'B':
          return const Color(0xFF85BB2F);
        case 'C':
          return const Color(0xFFFECB02);
        case 'D':
          return const Color(0xFFEE8100);
        case 'E':
          return const Color(0xFFE63E11);
        default:
          return const Color(0xFF9CA3AF);
      }
    }

    final scoreColor = getScoreColor(cleanScore);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scoreColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scoreColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: scoreColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              cleanScore,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Nutri-Score $cleanScore',
            style: TextStyle(
              color: scoreColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.gpp_maybe_rounded,
            size: 14,
            color: Color(0xFFB45309),
          ),
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

  Widget _buildImageContainer(String? rawUrl) {
    String? cleanUrl = rawUrl?.trim();
    if (cleanUrl != null && cleanUrl.startsWith('http://')) {
      cleanUrl = cleanUrl.replaceFirst('http://', 'https://');
    }
    final hasUrl = cleanUrl != null && cleanUrl.isNotEmpty;

    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: hasUrl
            ? Image.network(
                cleanUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF10B981),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder('Görsel Yüklenemedi');
                },
              )
            : _buildImagePlaceholder('Ürün Görseli Bulunamadı'),
      ),
    );
  }

  Widget _buildImagePlaceholder(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_not_supported_outlined,
            size: 44,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brandText = product.brand?.isNotEmpty == true ? product.brand! : 'Genel Marka';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageContainer(product.imageUrl),
          // Wrap instead of Row: on narrow screens the Nutri-Score badge moves to
          // the next line rather than overflowing. Badges are never clipped.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Marka Badge — only this one shrinks when space runs out.
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        brandText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ),
                  if (product.isPending) ...[
                    const SizedBox(width: 8),
                    _buildPendingBadge(),
                  ],
                ],
              ),
              // Nutri-Score (Eğer varsa)
              if (product.nutriscore != null && product.nutriscore!.isNotEmpty)
                _buildNutriScoreBadge(product.nutriscore!),
            ],
          ),
          const SizedBox(height: 10),
          // Ürün Adı
          Text(
            product.name,
            softWrap: true,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          // Barkod Bilgisi
          Row(
            children: [
              const Icon(Icons.qr_code_2_rounded, size: 16, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Barkod: ${product.barcode}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
