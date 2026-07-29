import 'package:flutter/material.dart';

/// Ana Sayfa — alt navigasyonun 1. sekmesi.
///
/// Geçmiş sekmesi (`features/home`) son taranan ürünleri listeler; burası
/// uygulamanın karşılama ekranı: selamlama, büyük "Tara" çağrısı, profil özeti.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Ana Sayfa içeriği:
    // - Figma "Ana Ekran" mockup'ına göre selamlama ve profil özeti
    // - Büyük "Tara" çağrısı -> AppRoutes.scan
    // - DashboardViewModel: selamlama metni ve profil özeti verisi
    //
    // İçeriği yazarken alt navigasyon barı için ayrılan boşluk MediaQuery'den
    // geliyor: gövdeyi SafeArea ile sarmala ki içerik barın arkasında kalmasın
    // (bkz. features/shell/shell_view.dart).
    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
    );
  }
}
