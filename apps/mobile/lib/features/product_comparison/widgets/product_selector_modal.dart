import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/product.dart';
import '../../../core/providers.dart';
import '../../../core/theme/akilli_sepet_colors.dart';
import '../../../core/theme/app_colors.dart';

/// Karşılaştırılacak 2. veya 3. ürünü seçmek için açılan modern alt panel.
class ProductSelectorModal extends ConsumerStatefulWidget {
  const ProductSelectorModal({
    super.key,
    required this.onProductSelected,
  });

  final ValueChanged<Product> onProductSelected;

  static Future<Product?> show(BuildContext context) {
    return showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductSelectorModal(
        onProductSelected: (product) => Navigator.pop(context, product),
      ),
    );
  }

  @override
  ConsumerState<ProductSelectorModal> createState() =>
      _ProductSelectorModalState();
}

class _ProductSelectorModalState extends ConsumerState<ProductSelectorModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchQueryChanged(String query) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final searchRepo = ref.read(productSearchRepositoryProvider);
      final results = await searchRepo.searchByName(query);
      if (mounted) {
        setState(() {
          _searchResults = results
              .map((r) => Product(
                    barcode: r.barcode,
                    name: r.name,
                    brand: r.brand,
                    imageUrl: r.imageUrl,
                    ingredientsText: '',
                    additives: const [],
                    allergensTags: const [],
                    nutriments: const Nutriments(),
                  ))
              .toList();
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyState = ref.watch(homeViewModelProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AkilliSepetColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Tutamaç & Başlık
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.compare_arrows_rounded,
                  color: AkilliSepetColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Karşılaştırılacak Ürün Seç',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AkilliSepetColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Arama Kutusu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchQueryChanged,
              decoration: InputDecoration(
                hintText: 'Ürün adı veya marka ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchQueryChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? AppColors.darkSurfaceMuted
                    : AkilliSepetColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Liste İçeriği
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AkilliSepetColors.primary,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      if (_searchResults.isNotEmpty) ...[
                        _buildSectionTitle('Arama Sonuçları', isDark),
                        ..._searchResults.map((p) => _buildProductTile(p, isDark)),
                        const SizedBox(height: 16),
                      ],

                      if (historyState.fullHistory.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildSectionTitle('Son Taranan Geçmiş', isDark),
                        ...historyState.fullHistory.map((item) {
                          final p = Product(
                            barcode: item.barcode,
                            name: item.productName ?? 'Taranan Ürün (${item.barcode})',
                            brand: 'Geçmiş',
                            imageUrl: null,
                            ingredientsText: '',
                            additives: const [],
                            allergensTags: const [],
                            nutriments: const Nutriments(),
                          );
                          return _buildProductTile(p, isDark);
                        }),
                      ],

                      if (_searchResults.isEmpty && historyState.fullHistory.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text(
                              _searchController.text.trim().isEmpty
                                  ? 'Eklemek istediğin ürünü aramak için yukarıya yaz.'
                                  : 'Sonuç bulunamadı.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AkilliSepetColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
          color: isDark
              ? AppColors.darkTextSecondary
              : AkilliSepetColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildProductTile(Product product, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceMuted : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AkilliSepetColors.divider,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 46,
            height: 46,
            color: isDark ? Colors.black26 : Colors.grey.shade100,
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.fastfood_rounded,
                      color: AkilliSepetColors.primary,
                    ),
                  )
                : const Icon(
                    Icons.fastfood_rounded,
                    color: AkilliSepetColors.primary,
                  ),
          ),
        ),
        title: Text(
          product.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextPrimary
                : AkilliSepetColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${product.brand ?? 'Bilinmeyen Marka'} · ${product.barcode}',
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.darkTextSecondary
                : AkilliSepetColors.textSecondary,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AkilliSepetColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_rounded,
            color: AkilliSepetColors.primary,
            size: 20,
          ),
        ),
        onTap: () => widget.onProductSelected(product),
      ),
    );
  }
}
