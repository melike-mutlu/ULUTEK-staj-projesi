import 'package:flutter/material.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/widgets/feature_placeholder.dart';

/// Figma: "Onboarding" mockup — alerji/diyet/sağlık seçim adımları.
/// Uygulamanın ilk açılış akışı; bittiğinde alt navigasyon kabuğuna geçilir.
class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  /// Onboarding tamamlandığında çağrılır: alt navigasyon kabuğuna geçilir.
  /// `pushReplacement` çünkü kullanıcı geri tuşuyla onboarding'e dönmemeli.
  static void completeOnboarding(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.shell);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Figma "Onboarding" mockup'ına göre çok adımlı seçim ekranını kur.
    // Son adımdaki "Bitir" butonu OnboardingViewModel.saveProfile(...) çağırıp
    // ardından completeOnboarding(context) ile kabuğa geçmeli.
    return Scaffold(
      body: FeaturePlaceholder(
        icon: Icons.assignment_ind_rounded,
        title: 'Onboarding',
        description:
            'Kullanıcının alerji, diyet ve sağlık bilgilerini topladığımız '
            'ilk açılış akışı. Bu ekranın içeriği henüz yazılmadı.',
        todos: const <String>[
          'Çok adımlı seçim akışı: alerjiler → diyet tercihi → sağlık durumları',
          'Adım göstergesi ve geri/ileri gezinme',
          'Son adımda OnboardingViewModel.saveProfile(...) ile profili kaydet',
          'Kaydetme başarılıysa completeOnboarding(context) ile kabuğa geç',
          'Profil zaten varsa bu akışı atla, doğrudan kabuğa gir',
        ],
        // GEÇİCİ — SİLİNECEK: iskelet aşamasında kabuk ve sekmeler
        // gezilebilsin diye duruyor. Onboarding adımları yazılınca bu buton
        // kaldırılıp yerine son adımın "Bitir" butonu gelecek.
        action: OutlinedButton(
          onPressed: () => completeOnboarding(context),
          child: const Text('Atla (geçici)'),
        ),
      ),
    );
  }
}
