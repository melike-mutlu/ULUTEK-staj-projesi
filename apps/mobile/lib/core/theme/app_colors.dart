import 'package:flutter/material.dart';

/// Uygulamadaki TÜM renkler burada tanımlanır.
///
/// Kural: hiçbir widget içinde `Color(0xFF...)` veya `Colors.red` yazılmaz.
/// Yeni bir renge ihtiyaç duyarsan önce buraya bir token ekle, sonra kullan.
/// Böylece Figma paleti kesinleştiğinde tek dosya değişir.
abstract final class AppColors {
  // --- Marka ---
  // TODO(figma): Marka renkleri Figma paleti kesinleşince güncellenecek.
  // Şimdilik placeholder; ekranlar bu token'lar üzerinden çalışsın diye var.
  static const Color brand = Color(0xFF1FA463);
  static const Color brandDark = Color(0xFF16794A);
  static const Color brandSoft = Color(0xFFE3F5EC);

  // --- Yüzeyler ---
  static const Color background = Color(0xFFF7F8F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEFF1F0);
  static const Color border = Color(0xFFE0E3E1);

  // --- Metin ---
  static const Color textPrimary = Color(0xFF12211A);
  static const Color textSecondary = Color(0xFF5F6D66);
  static const Color textOnBrand = Color(0xFFFFFFFF);
  static const Color textOnStatus = Color(0xFFFFFFFF);

  // --- Durum renkleri ---
  // Sözleşme 2'deki `personal_warning.level` değerleriyle birebir eşleşir:
  // "ok" | "caution" | "warning" (bkz. docs/architecture.md).
  // Kararı UI vermez, backend/LLM'den gelen level'a bağlanır.
  static const Color ok = Color(0xFF1FA463);
  static const Color caution = Color(0xFFFFB020);
  static const Color warning = Color(0xFFF0402A);

  /// Durum renklerinin açık/soft tonları (arka plan, chip, rozet için).
  static const Color okSoft = Color(0xFFE3F5EC);
  static const Color cautionSoft = Color(0xFFFFF3DC);
  static const Color warningSoft = Color(0xFFFDE6E2);

  // --- Cam efekti (floating bottom navigation) ---
  /// Yarı saydam bar zemini — arkasındaki içerik blur'lanıp bunun altından görünür.
  static const Color glassSurface = Color(0xCCFFFFFF);

  /// Kapsülün kenar çizgisi. Açık zeminde beyaz bir kenar kaybolduğu için
  /// düşük opaklıkta koyu ton kullanılıyor.
  static const Color glassBorder = Color(0x1F12211A);
  static const Color glassShadow = Color(0x1A12211A);

  /// Aktif sekmenin arkasında kayan soft pill highlight.
  /// Marka rengi değil nötr bir ton: vurguyu ikon ve etiket taşıyor,
  /// highlight sadece konumu belli ediyor.
  static const Color navIndicator = Color(0x1412211A);
  static const Color navSelected = brandDark;
  static const Color navUnselected = textPrimary;
}
