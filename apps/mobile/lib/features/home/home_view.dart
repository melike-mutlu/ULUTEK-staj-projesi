import 'package:flutter/material.dart';

/// Geçmiş — alt navigasyonun 3. sekmesi: son taranan ürünlerin listesi.
///
/// Klasör adı `home`, docs/flutter-mimari.md'deki yapı korunsun diye
/// değiştirilmedi; sekmedeki görünen adı "Geçmiş".
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Geçmiş içeriği:
    // - Son taranan ürünler listesi (ürün adı, tarih, uyarı seviyesi rozeti)
    // - Satıra dokununca AppRoutes.productDetail'e ürünle birlikte git
    // - Hiç tarama yoksa boş-durum görünümü
    // - HomeViewModel: geçmiş kaydını tutar ve okur
    //
    // Listeyi SafeArea ile sarmala: alt navigasyon barı için ayrılan boşluk
    // MediaQuery'den geliyor (bkz. features/shell/shell_view.dart).
    return Scaffold(
      appBar: AppBar(title: const Text('Geçmiş')),
    );
  }
}
