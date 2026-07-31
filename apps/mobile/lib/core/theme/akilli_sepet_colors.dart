import 'package:flutter/material.dart';

/// Figma Renk Paletesi
///
/// `menus` PR'ında app.dart içinde tanımlanmıştı; app.dart'ın asıl işi
/// (AppRoutes/AppTheme ile routing kurmak) olduğu için buraya taşındı.
/// TODO: core/theme/app_colors.dart (AppColors) ile aynı anda yaşıyor —
/// onboarding+shell bir paleti, home/scan/product-detail diğerini kullanıyor.
/// İkisini tek palette birleştirmek ayrı bir iştir.
class AkilliSepetColors {
  static const Color primary = Color(0xFF26B384); // Yeşil
  static const Color primaryLight = Color(0xFFE6F9F5);
  static const Color warning = Color(0xFFFF4757); // Kırmızı (Uyarı)
  static const Color caution = Color(0xFFFFD93D); // Sarı (Dikkat)
  static const Color success = Color(0xFF27AE60); // Yeşil (Uygun)
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);
}
