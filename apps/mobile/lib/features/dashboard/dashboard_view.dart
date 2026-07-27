import 'package:flutter/material.dart';

/// Ana Sayfa — alt navigasyonun 1. sekmesi.
///
/// Geçmiş sekmesi (`features/home`) son taranan ürünleri listeler; burası
/// uygulamanın karşılama ekranı: selamlama, büyük "Tara" çağrısı, profil
/// özeti gibi giriş içeriği.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Figma "Ana Ekran" mockup'ına göre karşılama içeriğini kur.
    // "Tara" çağrısı -> Navigator.pushNamed(context, AppRoutes.scan)
    return const Scaffold(
      body: Center(child: Text('Ana Sayfa')),
    );
  }
}
