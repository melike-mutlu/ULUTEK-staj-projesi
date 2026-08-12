import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/add_product_sheet.dart';

class ShoppingListDetailView extends ConsumerStatefulWidget {
  const ShoppingListDetailView({
    super.key,
    this.listId,
  });

  final String? listId;

  @override
  ConsumerState<ShoppingListDetailView> createState() =>
      _ShoppingListDetailViewState();
}

class _ShoppingListDetailViewState
    extends ConsumerState<ShoppingListDetailView> {
  String? _effectiveListId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is String) {
      _effectiveListId = routeArgs;
    } else if (widget.listId != null) {
      _effectiveListId = widget.listId;
    }

    if (_effectiveListId != null) {
      ref
          .read(shoppingListViewModelProvider)
          .loadListDetail(_effectiveListId!);
    }
  }

  void _openAddProductSheet() {
    if (_effectiveListId == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddProductSheet(listId: _effectiveListId!),
    );
  }

  Future<void> _deleteList() async {
    if (_effectiveListId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: AppColors.warning),
              SizedBox(width: 8),
              Text('Listeyi Sil'),
            ],
          ),
          content: const Text(
            'Bu alışveriş listesini ve içindeki tüm ürünleri silmek istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
              ),
              child: const Text('Evet, Sil', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(shoppingListViewModelProvider)
          .deleteList(_effectiveListId!);

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Liste silindi.')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final vm = ref.watch(shoppingListViewModelProvider);
    final list = vm.activeList;

    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          list?.name ?? 'Liste Detayı',
          style: AppTextStyles.heading2.copyWith(color: textColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.warning),
            tooltip: 'Listeyi Sil',
            onPressed: list != null ? _deleteList : null,
          ),
        ],
      ),
      body: vm.isLoading || list == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.brand))
          : Column(
              children: [
                // İlerleme Kartı
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Alışveriş İlerlemesi',
                            style: AppTextStyles.title.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${list.boughtItems} / ${list.totalItems} Alındı',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.brand,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: list.progress,
                          minHeight: 8,
                          backgroundColor: isDark
                              ? AppColors.darkSurfaceMuted
                              : AppColors.surfaceMuted,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.brand,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Ürünler Listesi
                Expanded(
                  child: list.items.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 64,
                                  color: secondaryTextColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Bu listede henüz ürün yok',
                                  style: AppTextStyles.title.copyWith(
                                    color: secondaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Aşağıdaki "Ürün Ekle" butonuna dokunarak son tarananlardan veya arama ile ürün ekleyebilirsiniz.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.caption.copyWith(
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: list.items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = list.items[index];

                            return Material(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: item.isBought
                                      ? AppColors.brand.withOpacity(0.3)
                                      : borderColor,
                                ),
                              ),
                              child: ListTile(
                                leading: Checkbox(
                                  value: item.isBought,
                                  activeColor: AppColors.brand,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (_) {
                                    ref
                                        .read(shoppingListViewModelProvider)
                                        .toggleItemBought(list.id, item.id);
                                  },
                                ),
                                title: Text(
                                  item.productName,
                                  style: AppTextStyles.title.copyWith(
                                    color: item.isBought
                                        ? secondaryTextColor
                                        : textColor,
                                    decoration: item.isBought
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item.brand != null && item.brand!.isNotEmpty)
                                      Text(
                                        item.brand!,
                                        style: AppTextStyles.caption.copyWith(
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                    if (item.barcode != null && item.barcode!.isNotEmpty)
                                      Text(
                                        'Barkod: ${item.barcode}',
                                        style: AppTextStyles.caption.copyWith(
                                          color: secondaryTextColor,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (item.barcode != null && item.barcode!.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.info_outline_rounded,
                                          color: AppColors.brand,
                                          size: 20,
                                        ),
                                        tooltip: 'Ürün Detayı',
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.productDetail,
                                            arguments: item.barcode,
                                          );
                                        },
                                      ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close_rounded,
                                        color: secondaryTextColor,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        ref
                                            .read(shoppingListViewModelProvider)
                                            .removeItemFromList(list.id, item.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: list != null
          ? FloatingActionButton.extended(
              onPressed: _openAddProductSheet,
              backgroundColor: AppColors.brand,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Ürün Ekle',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
