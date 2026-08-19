import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/theme/akilli_sepet_colors.dart';
import 'models/food_dictionary_model.dart';

class FoodDictionaryView extends ConsumerStatefulWidget {
  const FoodDictionaryView({super.key});

  @override
  ConsumerState<FoodDictionaryView> createState() => _FoodDictionaryViewState();
}

class _FoodDictionaryViewState extends ConsumerState<FoodDictionaryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTermDetailSheet(BuildContext context, FoodTerm term) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20.0),
          child: DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              final safetyColor = _getSafetyColor(term.safetyLevel);
              return ListView(
                controller: scrollController,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Category & Safety badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AkilliSepetColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          term.category.title,
                          style: const TextStyle(
                            color: AkilliSepetColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: safetyColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: safetyColor, width: 1),
                        ),
                        child: Text(
                          term.safetyLevel.label,
                          style: TextStyle(
                            color: safetyColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Display Title
                  Text(
                    term.displayTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AkilliSepetColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    term.subCategory,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AkilliSepetColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Divider(height: 24),

                  // Description
                  const Text(
                    'Açıklama',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AkilliSepetColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    term.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AkilliSepetColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details (if available)
                  if (term.details != null && term.details!.isNotEmpty) ...[
                    const Text(
                      'Detaylı Bilgi & Sağlık Etkileri',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AkilliSepetColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AkilliSepetColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        term.details!,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AkilliSepetColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Usage Areas (if available)
                  if (term.usageAreas != null && term.usageAreas!.isNotEmpty) ...[
                    const Text(
                      'Bulunduğu Gıdalar & Kullanım Alanı',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AkilliSepetColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      term.usageAreas!,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AkilliSepetColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tags
                  if (term.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: term.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }

  Color _getSafetyColor(SafetyLevel level) {
    switch (level) {
      case SafetyLevel.safe:
        return AkilliSepetColors.success;
      case SafetyLevel.caution:
        return const Color(0xFFE67E22);
      case SafetyLevel.avoid:
        return AkilliSepetColors.warning;
      case SafetyLevel.neutral:
        return const Color(0xFF3498DB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(foodDictionaryViewModelProvider);

    return Scaffold(
      backgroundColor: AkilliSepetColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gıda Sözlüğü',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'E-kodları, terimler, alerjenler ve besinler',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Column(
        children: [
          // Top Search Bar Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => viewModel.updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Terim, E-kodu veya gıda ara (örn: E100, pastörizasyon)...',
                hintStyle: const TextStyle(fontSize: 13, color: AkilliSepetColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AkilliSepetColors.primary),
                suffixIcon: viewModel.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          viewModel.clearSearch();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                filled: true,
                fillColor: AkilliSepetColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Category Chips Horizontal Scroll List
          Container(
            color: Colors.white,
            height: 48,
            padding: const EdgeInsets.only(bottom: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: FoodDictionaryCategory.values.length,
              itemBuilder: (context, index) {
                final category = FoodDictionaryCategory.values[index];
                final isSelected = viewModel.selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category.title),
                    selected: isSelected,
                    onSelected: (_) => viewModel.selectCategory(category),
                    selectedColor: AkilliSepetColors.primary,
                    backgroundColor: AkilliSepetColors.background,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AkilliSepetColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12.5,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AkilliSepetColors.primary : Colors.grey.shade300,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1, color: AkilliSepetColors.divider),

          // Result Stats & Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${viewModel.filteredTerms.length} terim bulundu',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AkilliSepetColors.textSecondary,
                  ),
                ),
                if (viewModel.selectedCategory != FoodDictionaryCategory.all || viewModel.searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      viewModel.resetFilters();
                    },
                    child: const Text(
                      'Filtreleri Temizle',
                      style: TextStyle(
                        fontSize: 12,
                        color: AkilliSepetColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Main Terms List
          Expanded(
            child: viewModel.filteredTerms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'Aranan terim bulunamadı',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AkilliSepetColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Farklı bir arama kelimesi veya kategori deneyin.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: viewModel.filteredTerms.length,
                    itemBuilder: (context, index) {
                      final term = viewModel.filteredTerms[index];
                      final safetyColor = _getSafetyColor(term.safetyLevel);

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AkilliSepetColors.divider),
                        ),
                        child: InkWell(
                          onTap: () => _showTermDetailSheet(context, term),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Safety Indicator Bar
                                Container(
                                  width: 4,
                                  height: 48,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: safetyColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              term.displayTitle,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: AkilliSepetColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AkilliSepetColors.background,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              term.subCategory,
                                              style: const TextStyle(
                                                fontSize: 10.5,
                                                color: AkilliSepetColors.textSecondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        term.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          color: AkilliSepetColors.textSecondary,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
