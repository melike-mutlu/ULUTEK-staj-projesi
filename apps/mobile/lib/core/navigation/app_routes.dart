import 'package:flutter/material.dart';

import '../../features/dashboard/dashboard_view.dart';
import '../../features/home/home_view.dart';
import '../../features/onboarding/onboarding_view.dart';
import '../../features/product_detail/product_detail_view.dart';
import '../../features/profile/profile_view.dart';
import '../../features/scan/scan_view.dart';
import '../../features/shell/shell_view.dart';

/// Uygulamadaki TÜM route adları ve eşleştikleri ekranlar burada tanımlanır.
///
/// Kural: `Navigator.pushNamed(context, '/scan')` gibi ham string yazılmaz,
/// `Navigator.pushNamed(context, AppRoutes.scan)` kullanılır. Yazım hatası
/// derleme zamanında yakalanır ve bir route adı değişince tek dosya güncellenir.
///
/// Navigasyon deseni docs/flutter-mimari.md'deki gibi düz `Navigator` +
/// named route; bu ölçekte go_router kullanılmıyor.
abstract final class AppRoutes {
  /// Profil kurulumu — uygulamanın ilk açılış akışı.
  static const String onboarding = '/onboarding';

  /// Alt navigasyon kabuğu — onboarding bitince girilen ana ekran.
  /// 4 sekmeyi (Ana Sayfa · Tara · Geçmiş · Profil) barındırır.
  static const String shell = '/';

  /// Ana Sayfa — alt navigasyonun 1. sekmesi.
  static const String dashboard = '/dashboard';

  /// Tarama — alt navigasyonun 2. sekmesi. Sekme dışından (ör. Ana Sayfa'daki
  /// "Tara" butonu) doğrudan açılabilsin diye route olarak da duruyor.
  static const String scan = '/scan';

  /// Geçmiş (son taranan ürünler) — alt navigasyonun 3. sekmesi.
  /// Ekran `features/home` altında yaşar (bkz. docs/flutter-mimari.md).
  static const String home = '/home';

  /// Profil — alt navigasyonun 4. sekmesi.
  static const String profile = '/profile';

  /// Ürün detay. Şimdilik tam ekran route; bottom-sheet'e çevirme kararı
  /// sonraya bırakıldı, o yüzden çağrı tarafı `pushNamed` olarak kalsın.
  static const String productDetail = '/product-detail';

  /// `MaterialApp.routes` tablosu.
  ///
  /// Sekme ekranları alt navigasyon kabuğunun içinde de gösterilir; buradaki
  /// kayıtlar onları ayrıca tek başına (kabuksuz) açabilmek için durur.
  static Map<String, WidgetBuilder> get table => <String, WidgetBuilder>{
        onboarding: (_) => const OnboardingView(),
        shell: (_) => const ShellView(),
        dashboard: (_) => const DashboardView(),
        scan: (_) => const ScanView(),
        home: (_) => const HomeView(),
        profile: (_) => const ProfileView(),
        productDetail: (_) => const ProductDetailView(),
      };
}
