import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Uygulamadaki TÜM tipografi burada tanımlanır.
///
/// Kural: widget içinde ham `TextStyle(fontSize: ..., fontWeight: ...)` yazılmaz.
/// Buradaki token'lardan biri kullanılır; gerekirse `.copyWith(color: ...)` ile
/// sadece rengi (yine [AppColors]'tan) değiştirilir.
abstract final class AppTextStyles {
  /// Tek font ailesi. `null` = platformun varsayılan fontu.
  // TODO(figma): Figma'daki font ailesi kesinleşince pubspec.yaml'a asset olarak
  // eklenip adı buraya yazılacak. Font adı SADECE burada geçmeli.
  static const String? fontFamily = null;

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );

  /// Alt navigasyon barındaki sekme etiketi.
  static const TextStyle navLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );

  /// Ürün detaydaki uyarı bandının metni (koyu zemin üzerinde).
  static const TextStyle bannerMessage = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnStatus,
  );

  // --- Onboarding ---
  /// Seçim ekranlarındaki soru kartının başlığı.
  static const TextStyle onboardingQuestion = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Seçim çiplerinin etiketi.
  static const TextStyle chipLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Kaynak: Figma "Onboarding" dosyası — karşılama ekranları (node 0:3, 1:2).
  // Figma'daki font ailesi "Nunito"; henüz asset olarak eklenmedi, bkz.
  // yukarıdaki `fontFamily` TODO'su — o kesinleşince bu stiller otomatik alır.

  /// Karşılama ekranlarının başlığı.
  static const TextStyle onboardingWelcomeTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    height: 1.025,
    fontWeight: FontWeight.w700,
    color: AppColors.onboardingTextPrimary,
  );

  /// Karşılama ekranlarının açıklama metni.
  static const TextStyle onboardingWelcomeBody = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.375,
    fontWeight: FontWeight.w400,
    color: AppColors.onboardingTextPrimary,
  );

  /// Onboarding'in tek CTA butonu.
  static const TextStyle onboardingButtonLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.1,
    fontWeight: FontWeight.w700,
    color: AppColors.onboardingButtonText,
  );

  /// 1. karşılama ekranındaki "Skip" linki.
  static const TextStyle onboardingSkipLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.375,
    fontWeight: FontWeight.w400,
    color: AppColors.onboardingSkipText,
  );
}
