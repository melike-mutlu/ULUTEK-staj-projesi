import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Henüz yazılmamış ekranların geçici gövdesi.
///
/// Bilinçli olarak boş: ekranın adı zaten AppBar'da yazıyor, yapılacaklar da
/// ekranın kendi TODO yorumlarında. **Ekranın gerçek içeriği yazılınca bu
/// widget kaldırılır.**
///
/// Ayrıca alt navigasyon barının altta bıraktığı boşluğun nasıl tüketildiğini
/// gösterir: gövde `SafeArea` ile sarmalanır, boşluk `MediaQuery` üzerinden
/// zaten geliyor (bkz. features/shell/shell_view.dart).
class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    super.key,
    required this.icon,
    this.action,
  });

  final IconData icon;

  /// Ekrana özel geçici buton vb.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Ortalanmış içerik, ama dar ekranda (yatay mod, küçük telefon)
          // taşmak yerine kayabilsin.
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.brandSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 32, color: AppColors.brandDark),
                    ),
                    if (action != null) ...<Widget>[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: action,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
