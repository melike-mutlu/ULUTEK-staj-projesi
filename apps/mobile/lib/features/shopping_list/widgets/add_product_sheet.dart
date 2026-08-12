import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../search/search_viewmodel.dart';
import '../shopping_list_viewmodel.dart';

class AddProductSheet extends ConsumerStatefulWidget {
  const AddProductSheet({
    super.key,
    required this.listId,
  });

  final String listId;

  @override
  ConsumerState<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends ConsumerState<AddProductSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shoppingListViewModelProvider).loadRecentScans();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _barcodeController.dispose();
    _brandController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addItem({
    required String name,
    String? barcode,
    String? brand,
  }) async {
    if (name.trim().isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    final success = await ref
        .read(shoppingListViewModelProvider)
        .addItemToList(
          listId: widget.listId,
          productName: name.trim(),
          barcode: barcode,
          brand: brand,
        );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$name" listeye eklendi.'),
          backgroundColor: AppColors.brand,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ürün eklenirken bir hata oluştu.'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final vm = ref.watch(shoppingListViewModelProvider);
    final searchVm = ref.watch(searchViewModelProvider);

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Tutma çizgisi
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: secondaryTextColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Başlık
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Listeye Ürün Ekle',
                  style: AppTextStyles.title.copyWith(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: secondaryTextColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.brand,
            labelColor: AppColors.brand,
            unselectedLabelColor: secondaryTextColor,
            tabs: const [
              Tab(
                icon: Icon(Icons.history_rounded, size: 20),
                text: 'Son Tarananlar',
              ),
              Tab(
                icon: Icon(Icons.search_rounded, size: 20),
                text: 'Arama & Elle Ekle',
              ),
            ],
          ),

          // Tab İçerikleri
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Scan History Önerileri
                _buildScanHistoryTab(
                  vm,
                  textColor,
                  secondaryTextColor,
                  borderColor,
                  isDark,
                ),

                // TAB 2: Arama ve Manuel Ekleme
                _buildSearchAndManualTab(
                  searchVm,
                  textColor,
                  secondaryTextColor,
                  borderColor,
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanHistoryTab(
    ShoppingListViewModel vm,
    Color textColor,
    Color secondaryTextColor,
    Color borderColor,
    bool isDark,
  ) {
    if (vm.isLoadingRecentScans) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brand),
      );
    }

    if (vm.recentScans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner_rounded, size: 48, color: secondaryTextColor),
              const SizedBox(height: 12),
              Text(
                'Henüz taranmış ürün bulunmuyor.',
                style: AppTextStyles.title.copyWith(color: secondaryTextColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Barkod tarayarak ürün incelediğinizde öneriler burada görünecektir.',
                style: AppTextStyles.caption.copyWith(color: secondaryTextColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vm.recentScans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = vm.recentScans[index];
        final name = entry.productName ?? 'Barkod: ${entry.barcode}';

        return Material(
          color: isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _isSubmitting
                ? null
                : () => _addItem(
                      name: name,
                      barcode: entry.barcode,
                    ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.brandSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.qr_code_2_rounded,
                      color: AppColors.brandDark,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.title.copyWith(
                            color: textColor,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Barkod: ${entry.barcode}',
                          style: AppTextStyles.caption.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.brand,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Ekle',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchAndManualTab(
    dynamic searchVm,
    Color textColor,
    Color secondaryTextColor,
    Color borderColor,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Manuel Ürün Ekleme Kartı
          Text(
            'Elle Ürün Adı Gir',
            style: AppTextStyles.title.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Örn: Süt, Elma, Yulaf...',
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                  ),
                  onSubmitted: (val) => _addItem(name: val),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () => _addItem(name: _nameController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  minimumSize: const Size(80, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Ekle', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Ürün İsmiyle Canlı Arama
          Text(
            'Ürün İsmine Göre Ara',
            style: AppTextStyles.title.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            onChanged: (val) => searchVm.onQueryChanged(val),
            decoration: InputDecoration(
              hintText: 'Marka veya ürün adı ara...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        searchVm.clear();
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),

          // Arama Sonuçları
          if (searchVm.status == SearchStatus.loading) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(color: AppColors.brand)),
            ),
          ] else if (searchVm.status == SearchStatus.results) ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: searchVm.results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = searchVm.results[index];
                return ListTile(
                  tileColor: isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(item.productName, style: TextStyle(color: textColor)),
                  subtitle: item.brand != null
                      ? Text(item.brand!, style: TextStyle(color: secondaryTextColor))
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.brand),
                    onPressed: () => _addItem(
                      name: item.productName,
                      barcode: item.barcode,
                      brand: item.brand,
                    ),
                  ),
                );
              },
            ),
          ] else if (_searchController.text.length >= 2 &&
              searchVm.status == SearchStatus.empty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Aramaya uygun ürün bulunamadı.',
                  style: TextStyle(color: secondaryTextColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
