import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Henüz yazılmamış ekranların geçici gövdesi.
///
/// Amacı iskeletin gezilebilir olması ve her ekranın sahibine ne yapacağını
/// hatırlatması. **Ekranın gerçek içeriği yazılınca bu widget kaldırılır.**
///
/// Ayrıca alt navigasyon barının altta bıraktığı boşluğun nasıl tüketildiğini
/// gösterir: gövde `SafeArea` ile sarmalanır, boşluk `MediaQuery` üzerinden
/// zaten geliyor (bkz. features/shell/shell_view.dart).
class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.todos = const <String>[],
    this.action,
  });

  final IconData icon;
  final String title;
  final String description;

  /// Bu ekranı yazacak kişi için maddeler.
  final List<String> todos;

  /// Ekrana özel geçici buton vb.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: <Widget>[
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.brandSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.brandDark),
            ),
          ),
          const SizedBox(height: 20),
          Text(title, style: AppTextStyles.heading2, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
          if (todos.isNotEmpty) ...<Widget>[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Bu ekranda yapılacaklar',
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 12),
                    for (final todo in todos)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Icon(
                              Icons.check_box_outline_blank_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(todo, style: AppTextStyles.body),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (action != null) ...<Widget>[
            const SizedBox(height: 24),
            action!,
          ],
        ],
      ),
    );
  }
}
