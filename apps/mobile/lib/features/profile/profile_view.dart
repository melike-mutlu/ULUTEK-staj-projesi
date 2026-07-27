import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Profil — alt navigasyonun 4. sekmesi.
/// Figma: "Profil" mockup — alerji/diyet/sağlık bilgilerini düzenleme ekranı.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Figma "Profil" mockup'ına göre düzenlenebilir form.
    // ProfileViewModel.load(userId) ile mevcut profili oku,
    // kaydet'te ProfileViewModel.save(updated) çağır.
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const FeaturePlaceholder(
        icon: Icons.person_rounded,
        title: 'Profil',
        description:
            'Alerji, diyet ve sağlık bilgilerinin düzenlendiği ekran. '
            'Bu ekranın içeriği henüz yazılmadı.',
        todos: <String>[
          'Alerji listesi — çoklu seçim',
          'Diyet tercihi — DietPreference seçimi',
          'Sağlık durumları — çoklu seçim',
          'ProfileViewModel.load / save ile Supabase profiles tablosuna bağla',
          'Onboarding ile aynı seçenek listelerini paylaş, kopyalama',
        ],
      ),
    );
  }
}
