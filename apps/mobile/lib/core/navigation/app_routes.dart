import 'package:flutter/material.dart';

import '../../features/auth/auth_view.dart';
import '../../features/chatbot/chatbot_view.dart';
import '../../features/home/home_view.dart';
import '../../features/onboarding/onboarding_view.dart';
import '../../features/pending_product/pending_product_view.dart';
import '../../features/product_detail/product_detail_view.dart';
import '../../features/profile/profile_view.dart';
import '../../features/scan/scan_view.dart';
import '../../features/settings/settings_view.dart';
import '../../features/shell/shell_view.dart';
import '../../features/startup/startup_gate.dart';

/// Uygulamadaki TÜM route adları ve eşleştikleri ekranlar burada tanımlanır.
///
/// Kural: `Navigator.pushNamed(context, '/scan')` gibi ham string yazılmaz,
/// `Navigator.pushNamed(context, AppRoutes.scan)` kullanılır. Yazım hatası
/// derleme zamanında yakalanır ve bir route adı değişince tek dosya güncellenir.
///
/// Navigasyon deseni docs/flutter-mimari.md'deki gibi düz `Navigator` +
/// named route; bu ölçekte go_router kullanılmıyor.
abstract final class AppRoutes {
  /// Açılış kapısı — oturum + profil durumuna bakıp auth/onboarding/shell
  /// arasında seçim yapar. `MaterialApp.home` bu ekran; route olarak da durur
  /// ki giriş başarılı olunca kararı tekrar buraya devredebilelim.
  static const String startup = '/startup';

  /// Giriş / kayıt. Başarılı olunca [startup]'a dönülür; hedefi oradaki gate
  /// seçer, böylece onboarding'de her zaman geçerli bir oturum olur.
  static const String auth = '/auth';

  /// Profil kurulumu — yalnızca profil satırı olmayan (yeni kayıt) kullanıcı
  /// için, [startup] tarafından seçilir.
  static const String onboarding = '/onboarding';

  /// Alt navigasyon kabuğu — onboarding bitince girilen ana ekran.
  /// 4 sekmeyi (Ana Sayfa · Tara · Chatbot · Profil) barındırır.
  ///
  /// Bilerek '/' DEĞİL: `initialRoute` çok parçalı bir ad aldığında (örneğin
  /// '/onboarding') Flutter route yığınını ['/', '/onboarding'] olarak kurar.
  /// Kabuk '/' adresinde olursa uygulama onboarding'in ALTINDA kabukla açılır
  /// ve kullanıcı geri tuşuyla onboarding'i atlayabilir.
  static const String shell = '/shell';

  /// Ana Sayfa — alt navigasyonun 1. sekmesi.
  static const String home = '/home';

  /// Tarama — alt navigasyonun 2. sekmesi. Sekme dışından (ör. Ana Sayfa'daki
  /// "Tara" butonu) doğrudan açılabilsin diye route olarak da duruyor.
  static const String scan = '/scan';

  /// Chatbot (AI destekli asistan) — alt navigasyonun 3. sekmesi.
  static const String chatbot = '/chatbot';

  /// Profil — alt navigasyonun 4. sekmesi.
  static const String profile = '/profile';

  /// Ayarlar — profil ekranının sağ üstündeki dişli ikonundan açılır.
  static const String settings = '/settings';

  /// Ürün detay. Şimdilik tam ekran route; bottom-sheet'e çevirme kararı
  /// sonraya bırakıldı, o yüzden çağrı tarafı `pushNamed` olarak kalsın.
  static const String productDetail = '/product-detail';

  /// Bulunamayan veya eksik ürün bildirimi (Pending Product) ekranı.
  static const String pendingProduct = '/pending-product';

  /// `MaterialApp.routes` tablosu.
  ///
  /// Sekme ekranları alt navigasyon kabuğunun içinde de gösterilir; buradaki
  /// kayıtlar onları ayrıca tek başına (kabuksuz) açabilmek için durur.
  static Map<String, WidgetBuilder> get table => <String, WidgetBuilder>{
        startup: (_) => const StartupGate(),
        auth: (_) => const AuthView(),
        onboarding: (_) => const OnboardingView(),
        shell: (_) => const ShellView(),
        home: (_) => const HomeView(),
        scan: (_) => const ScanView(),
        chatbot: (_) => const ChatbotView(),
        profile: (_) => const ProfileView(),
        settings: (_) => const SettingsView(),
        productDetail: (_) => const ProductDetailView(),
        pendingProduct: (_) => const PendingProductView(),
      };
}
