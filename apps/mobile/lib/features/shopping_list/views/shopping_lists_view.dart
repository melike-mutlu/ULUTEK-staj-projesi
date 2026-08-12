import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ShoppingListsView extends ConsumerStatefulWidget {
  const ShoppingListsView({super.key});

  @override
  ConsumerState<ShoppingListsView> createState() => _ShoppingListsViewState();
}

class _ShoppingListsViewState extends ConsumerState<ShoppingListsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shoppingListViewModelProvider).loadLists();
    });
  }

  Future<void> _showCreateListDialog() async {
    final nameController = TextEditingController();

    final String? result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.playlist_add_rounded, color: AppColors.brand),
              SizedBox(width: 8),
              Text('Yeni Liste Oluştur'),
            ],
          ),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Liste Adı (Örn: Hafta Sonu Pazarı)',
              prefixIcon: Icon(Icons.edit_outlined),
            ),
            onSubmitted: (val) => Navigator.pop(dialogContext, val),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, nameController.text),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand),
              child: const Text('Oluştur', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (result != null && result.trim().isNotEmpty && mounted) {
      final newList = await ref
          .read(shoppingListViewModelProvider)
          .createList(result.trim());

      if (newList != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${newList.name}" listesi oluşturuldu.'),
            backgroundColor: AppColors.brand,
          ),
        );
        // Doğrudan detayına git
        Navigator.pushNamed(
          context,
          AppRoutes.shoppingListDetail,
          arguments: newList.id,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final vm = ref.watch(shoppingListViewModelProvider);

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
          'Alışveriş Listelerim',
          style: AppTextStyles.heading2.copyWith(color: textColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.brand, size: 28),
            tooltip: 'Yeni Liste',
            onPressed: _showCreateListDialog,
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brand))
          : vm.lists.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.format_list_bulleted_rounded,
                          size: 72,
                          color: secondaryTextColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz bir alışveriş listeniz yok',
                          style: AppTextStyles.title.copyWith(
                            color: textColor,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Market veya pazar alışverişlerinizi kolayca planlamak için yeni bir liste oluşturabilirsiniz.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showCreateListDialog,
                          icon: const Icon(Icons.add_rounded, color: Colors.white),
                          label: const Text(
                            'Yeni Liste Oluştur',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brand,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.lists.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final list = vm.lists[index];

                    return Material(
                      color: surfaceColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: borderColor),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.shoppingListDetail,
                            arguments: list.id,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: AppColors.brandSoft,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.shopping_bag_outlined,
                                      color: AppColors.brandDark,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          list.name,
                                          style: AppTextStyles.title.copyWith(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${list.totalItems} ürün • ${list.boughtItems} alındı',
                                          style: AppTextStyles.caption.copyWith(
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.brand,
                                  ),
                                ],
                              ),
                              if (list.totalItems > 0) ...[
                                const SizedBox(height: 14),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: list.progress,
                                    minHeight: 6,
                                    backgroundColor: isDark
                                        ? AppColors.darkSurfaceMuted
                                        : AppColors.surfaceMuted,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      AppColors.brand,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: vm.lists.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showCreateListDialog,
              backgroundColor: AppColors.brand,
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            )
          : null,
    );
  }
}
