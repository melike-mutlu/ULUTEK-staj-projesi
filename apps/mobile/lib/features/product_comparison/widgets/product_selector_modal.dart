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

  // Hazır Karşılaştırma Örnek Ürünleri (Hızlı test ve gösterim için)
  static final List<Product> _sampleProducts = [
    const Product(
      barcode: '8690504018001',
      name: 'Tam Yağlı Taze Süt 1L',
      brand: 'Sütaş',
      imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=300',
      ingredientsText: 'Pastörize inek sütü.',
      additives: [],
      allergensTags: ['en:milk'],
      nutriments: Nutriments(
        energyKcal100g: 62,
        sugars100g: 4.7,
        fat100g: 3.3,
        proteins100g: 3.2,
        salt100g: 0.1,
        carbohydrates100g: 4.7,
      ),
      nutriscore: 'b',
      status: 'VERIFIED',
    ),
    const Product(
      barcode: '8690504018002',
      name: 'Yulaf Sütü Organik 1L',
      brand: 'Alpro',
      imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300',
      ingredientsText: 'Su, yulaf (%10), ayçiçek yağı, deniz tuzu.',
      additives: [],
      allergensTags: ['en:gluten'],
      nutriments: Nutriments(
        energyKcal100g: 44,
        sugars100g: 3.2,
        fat100g: 1.5,
        proteins100g: 0.8,
        salt100g: 0.08,
        carbohydrates100g: 6.8,
      ),
      nutriscore: 'a',
      status: 'VERIFIED',
    ),
    const Product(
      barcode: '8690504018003',
      name: 'Yulaf Ezmesi 500g',
      brand: 'Eti Lifalif',
      imageUrl: 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=300',
      ingredientsText: '%100 Yulaf Ezmesi.',
      additives: [],
      allergensTags: ['en:gluten'],
      nutriments: Nutriments(
        energyKcal100g: 356,
        sugars100g: 1.2,
        fat100g: 7.0,
        proteins100g: 12.5,
        salt100g: 0.02,
        carbohydrates100g: 57.0,
      ),
      nutriscore: 'a',
      status: 'VERIFIED',
    ),
    const Product(
      barcode: '8690504018004',
      name: 'Fındıklı Sütlü Çikolata 80g',
      brand: 'Ülker',
      imageUrl: 'https://images.unsplash.com/photo-1549007994-cb92caebd54b?w=300',
      ingredientsText: 'Şeker, tam yağlı süt tozu, kakao yağı, fındık (%13), kakao kitlesi, emülgatör (soya lesitini).',
      additives: ['E322'],
      allergensTags: ['en:milk', 'en:nuts', 'en:soybeans'],
      nutriments: Nutriments(
        energyKcal100g: 545,
        sugars100g: 48.0,
        fat100g: 33.0,
        proteins100g: 9.0,
        salt100g: 0.2,
        carbohydrates100g: 52.0,
      ),
      nutriscore: 'e',
      status: 'VERIFIED',
    ),
    const Product(
      barcode: '8690504018005',
      name: 'Bitter Çikolata %70 Kakao 80g',
      brand: 'Lindt',
      imageUrl: 'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=300',
      ingredientsText: 'Kakao kitlesi, şeker, kakao yağı, vanilya.',
      additives: [],
      allergensTags: [],
      nutriments: Nutriments(
        energyKcal100g: 566,
        sugars100g: 29.0,
        fat100g: 41.0,
        proteins100g: 9.5,
        salt100g: 0.05,
        carbohydrates100g: 34.0,
      ),
      nutriscore: 'd',
      status: 'VERIFIED',
    ),
  ];

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

                      _buildSectionTitle('Örnek Karşılaştırma Ürünleri', isDark),
                      ..._sampleProducts.map((p) => _buildProductTile(p, isDark)),

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
