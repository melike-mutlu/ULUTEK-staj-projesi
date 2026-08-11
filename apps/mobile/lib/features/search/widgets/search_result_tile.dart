import 'package:flutter/material.dart';

import '../../../core/models/product_search_result.dart';
import '../../../core/theme/akilli_sepet_colors.dart';

/// One row in the search results list: product thumbnail, name + brand, chevron.
/// Tapping opens the product, same as scanning its barcode.
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.result,
    required this.onTap,
  });

  final ProductSearchResult result;
  final VoidCallback onTap;

  static const double _thumbSize = 48;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            _Thumbnail(imageUrl: result.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AkilliSepetColors.textPrimary,
                        ),
                  ),
                  if (result.brand.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      result.brand,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AkilliSepetColors.textSecondary,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AkilliSepetColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: SearchResultTile._thumbSize,
        height: SearchResultTile._thumbSize,
        child: imageUrl.isEmpty
            ? _placeholder()
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : _placeholder(),
                errorBuilder: (context, error, stackTrace) => _placeholder(),
              ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AkilliSepetColors.background,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: AkilliSepetColors.textSecondary,
        size: 20,
      ),
    );
  }
}
