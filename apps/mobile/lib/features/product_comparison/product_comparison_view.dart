import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/product.dart';
import '../../core/models/rule_engine_result.dart';
import '../../core/providers.dart';
import '../../core/theme/akilli_sepet_colors.dart';
import '../../core/theme/app_colors.dart';
import 'product_comparison_viewmodel.dart';
import 'widgets/comparison_attribute_row.dart';
import 'widgets/comparison_column_header.dart';
import 'widgets/health_condition_info_card.dart';
import 'widgets/product_selector_modal.dart';

/// Mobil Ürün Karşılaştırma Ekranı.
/// 2-3 ürünü yan yana besin değerleri, Nutri-Score, kural motoru sonuçları ve
/// Sevde'nin sağlık bilgi kartıyla kıyaslamayı sağlar.
class ProductComparisonView extends ConsumerStatefulWidget {
  const ProductComparisonView({
    super.key,
    this.initialProducts,
  });

  /// İsteğe bağlı olarak başlatılırken geçilebilecek başlangıç ürünleri
  final List<Product>? initialProducts;

  @override
  ConsumerState<ProductComparisonView> createState() =>
      _ProductComparisonViewState();
}

class _ProductComparisonViewState
    extends ConsumerState<ProductComparisonView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productComparisonViewModelProvider).initializeWithProducts(
            widget.initialProducts ?? const [],
          );
    });
  }

  void _openProductSelector({int? replaceIndex}) async {
    final selectedProduct = await ProductSelectorModal.show(context);
    if (selectedProduct != null && mounted) {
      final vm = ref.read(productComparisonViewModelProvider);
      if (replaceIndex != null) {
        vm.replaceProductAt(replaceIndex, selectedProduct);
      } else {
        vm.addProduct(selectedProduct);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModel = ref.watch(productComparisonViewModelProvider);
    final products = viewModel.selectedProducts;

    // Gösterilecek sütun sayısı (en az 2, en fazla 3). Eğer 2 ürün varsa 3. slot boş (+ Ekle) olarak durabilir.
    final columnCount = (products.length < ProductComparisonViewModel.maxComparisonCount)
        ? products.length + 1
        : products.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AkilliSepetColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.compare_arrows_rounded, color: AkilliSepetColors.primary),
            SizedBox(width: 8),
            Text(
              'Ürün Karşılaştırma',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          if (products.length < ProductComparisonViewModel.maxComparisonCount)
            TextButton.icon(
              onPressed: () => _openProductSelector(),
              icon: const Icon(Icons.add_rounded, size: 18, color: AkilliSepetColors.primary),
              label: Text(
                'Ekle (${products.length}/3)',
                style: const TextStyle(
                  color: AkilliSepetColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: products.isEmpty
          ? _buildEmptyState(context, isDark)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // 1. Ürün Üst Başlık Kolonları (Yan Yana Ürün Kartları)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(columnCount, (index) {
                      final p = index < products.length ? products[index] : null;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ComparisonColumnHeader(
                            columnIndex: index,
                            product: p,
                            onAdd: () => _openProductSelector(),
                            onReplace: p != null
                                ? () => _openProductSelector(replaceIndex: index)
                                : null,
                            onRemove: p != null && products.length > 1
                                ? () => viewModel.removeProductAt(index)
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // 2. Kural Motoru Kararı
                  ComparisonAttributeRow(
                    title: 'Kural Motoru Kararı',
                    icon: Icons.gavel_rounded,
                    badgeText: 'Algoritma Kararı',
                    badgeColor: AkilliSepetColors.primary,
                    children: List.generate(columnCount, (index) {
                      if (index >= products.length) return const SizedBox.shrink();
                      final p = products[index];
                      final ruleRes = viewModel.ruleResults[p.barcode];
                      return _buildRuleEngineCell(ruleRes, isDark);
                    }),
                  ),

                  // 3. Sağlık Durumu Bilgi Kartı UI (Sevde'nin Yazacağı Metin)
                  ComparisonAttributeRow(
                    title: 'Sağlık Durumu Bilgi Kartı',
                    icon: Icons.health_and_safety_rounded,
                    badgeText: 'Sevde\'nin Sağlık Notu',
                    badgeColor: const Color(0xFF6366F1), // Indigo renk
                    children: List.generate(columnCount, (index) {
                      if (index >= products.length) return const SizedBox.shrink();
                      final p = products[index];
                      final title = viewModel.getHealthInfoTitleForProduct(p);
                      final text = viewModel.getHealthInfoTextForProduct(p);
                      return HealthConditionInfoCard(
                        isCompact: true,
                        conditionName: title,
                        infoText: text,
                        expertName: 'Sevde (Sağlık Uzmanı)',
                      );
                    }),
                  ),

                  // 4. Nutri-Score Karşılaştırması
                  ComparisonAttributeRow(
                    title: 'Nutri-Score Rozeti',
                    icon: Icons.eco_rounded,
                    children: List.generate(columnCount, (index) {
                      if (index >= products.length) return const SizedBox.shrink();
                      final p = products[index];
                      return _buildNutriScoreCell(p.nutriscore, isDark);
                    }),
                  ),

                  // 5. Besin Değerleri Karşılaştırma (100g)
                  ComparisonAttributeRow(
                    title: 'Enerji & Kalori (100g)',
                    icon: Icons.local_fire_department_rounded,
                    children: List.generate(columnCount, (index) {
                      if (index >= products.length) return const SizedBox.shrink();
                      final p = products[index];
                      final val = p.nutriments.energyKcal100g;
                      return _buildValueTile(
                        val != null ? '${val.toStringAsFixed(0)} kcal' : '—',
                        isDark,
                        highlight: val != null && val < 100,
                      );
                    }),
                  ),

                  ComparisonAttributeRow(
                    title: 'Şeker Oranı (100g)',
                    icon: Icons.cookie_rounded,
                    children: List.generate(columnCount, (index) {
                      if (index >= products.length) return const SizedBox.shrink();
                      final p = products[index];
                      final val = p.nutriments.sugars100g;
                      return _buildValueTile(
                        val != null ? '${val.toStringAsFixed(1)} g' : '—',
                        isDark,
                        isWarning: val != null && val > 15.0,
                        highlight: val != null && val <= 5.0,
                      );
                    }),
                  ),

                  ComparisonAttributeRow(
                    title: 'Yağ Miktarı (100g)',
                    icon: Icons.water_drop_rounded,
                    children: List.generate(columnCount, (index) {
                      if (index >= products.length) return const SizedBox.shrink();
                      final p = products[index];
                      final val = p.nutriments.fat100g;
                      return _buildValueTile(
                        val != null ? '${val.toStringAsFixed(1)} g' : '—',
                        isDark,
                        isWarning: val != null && val > 17.5,
                      );
                    }),
                  ),

                  ComparisonAttributeRow(
                    title: 'Protein (100g)',
                    icon: Icons.fitness_center_rounded,
                    children: List.generate(columnCount, (index) {
                      if (index >= products.length) return const SizedBox.shrink();
                      final p = products[index];
                      final val = p.nutriments.proteins100g;
                      return _buildValueTile(
                        val != null ? '${val.toStringAsFixed(1)} g' : '—',
                        isDark,
                        highlight: val != null && val >= 8.0,
                      );
                    }),
                  ),

                  ComparisonAttributeRow(
                    title: 'Tuz Oranı (100g)',
                    icon: Icons.grain_rounded,
                    children: List.generate(columnCount, (index) {
                      if (index >= products.length) return const SizedBox.shrink();
                      final p = products[index];
                      final val = p.nutriments.salt100g;
                      return _buildValueTile(
                        val != null ? '${val.toStringAsFixed(2)} g' : '—',
                        isDark,
                        isWarning: val != null && val > 1.5,
                      );
                    }),
                  ),

                  // 6. Alerjenler & Riskler
                  ComparisonAttributeRow(
                    title: 'Alerjen Durumu & Riskler',
                    icon: Icons.warning_amber_rounded,
                    children: List.generate(columnCount, (index) {
                      if (index >= products.length) return const SizedBox.shrink();
                      final p = products[index];
                      return _buildAllergensCell(p.allergensTags, isDark);
                    }),
                  ),

                  // 7. Diyet Uyumları
                  ComparisonAttributeRow(
                    title: 'Diyet Uyumları',
                    icon: Icons.checklist_rounded,
                    children: List.generate(columnCount, (index) {
                      if (index >= products.length) return const SizedBox.shrink();
                      final p = products[index];
                      final isVegan = !p.allergensTags.contains('en:milk');
                      final isGlutenFree = !p.allergensTags.contains('en:gluten');
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTagChip('Vegan', isVegan, isDark),
                          const SizedBox(height: 4),
                          _buildTagChip('Glutensiz', isGlutenFree, isDark),
                        ],
                      );
                    }),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AkilliSepetColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.compare_arrows_rounded,
                size: 48,
                color: AkilliSepetColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Karşılaştırılacak Ürün Seçilmedi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AkilliSepetColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ürünleri yan yana besin ve sağlık değerlerine göre karşılaştırmak için ürün ekleyin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AkilliSepetColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _openProductSelector(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ürün Seç ve Karşılaştır'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AkilliSepetColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleEngineCell(RuleEngineResult? ruleRes, bool isDark) {
    final hasConflict = ruleRes?.hasConflict ?? false;
    final bgColor = hasConflict
        ? (isDark ? const Color(0xFF3E1F23) : const Color(0xFFFFEBEE))
        : (isDark ? const Color(0xFF1B382B) : const Color(0xFFE8F5E9));
    final textColor = hasConflict
        ? (isDark ? const Color(0xFFFF8A80) : const Color(0xFFC62828))
        : (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32));
    final label = hasConflict ? 'Riskli / Alerjen Çakışması' : 'Profiline Uygun';
    final icon = hasConflict ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: textColor),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutriScoreCell(String? score, bool isDark) {
    final scoreLetter = (score ?? '?').toUpperCase();
    Color badgeColor;
    switch (scoreLetter) {
      case 'A':
        badgeColor = const Color(0xFF038141);
        break;
      case 'B':
        badgeColor = const Color(0xFF85BB2F);
        break;
      case 'C':
        badgeColor = const Color(0xFFFECB02);
        break;
      case 'D':
        badgeColor = const Color(0xFFEE8100);
        break;
      case 'E':
        badgeColor = const Color(0xFFE63E11);
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.4)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                scoreLetter,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Skor: $scoreLetter',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: badgeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueTile(
    String valText,
    bool isDark, {
    bool highlight = false,
    bool isWarning = false,
  }) {
    Color textColor = isDark ? AppColors.darkTextPrimary : AkilliSepetColors.textPrimary;
    Color bgColor = isDark ? AppColors.darkSurfaceMuted : Colors.grey.shade50;

    if (highlight) {
      textColor = isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
      bgColor = isDark ? const Color(0xFF1B382B) : const Color(0xFFE8F5E9);
    } else if (isWarning) {
      textColor = isDark ? const Color(0xFFFF8A80) : const Color(0xFFC62828);
      bgColor = isDark ? const Color(0xFF3E1F23) : const Color(0xFFFFEBEE);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            valText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllergensCell(List<String> allergens, bool isDark) {
    if (allergens.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            'Alerjen Yok',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AkilliSepetColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: allergens.map((a) {
        final cleanName = a.replaceAll('en:', '').toUpperCase();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF3E1F23) : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            cleanName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFFF8A80) : const Color(0xFFC62828),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTagChip(String label, bool isCompatible, bool isDark) {
    final color = isCompatible
        ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32))
        : (isDark ? AppColors.darkTextSecondary : AkilliSepetColors.textSecondary);
    final bg = isCompatible
        ? (isDark ? const Color(0xFF1B382B) : const Color(0xFFE8F5E9))
        : (isDark ? AppColors.darkSurfaceMuted : Colors.grey.shade100);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompatible ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
