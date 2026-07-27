import 'package:flutter/material.dart';

import '../../core/navigation/app_routes.dart';

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
    // TODO: Onboarding içeriği:
    // - Çok adımlı seçim akışı: alerjiler -> diyet tercihi -> sağlık durumları
    // - Adım göstergesi ve geri/ileri gezinme
    // - Son adımda OnboardingViewModel.saveProfile(...) ile profili kaydet
    // - Kaydetme başarılıysa completeOnboarding(context) ile kabuğa geç
    // - Profil zaten varsa bu akışı atla, doğrudan kabuğa gir
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: <Widget>[
              const Spacer(),
              // GEÇİCİ — SİLİNECEK: iskelet aşamasında kabuk ve sekmeler
              // gezilebilsin diye duruyor. Onboarding adımları yazılınca bu
              // buton kaldırılıp yerine son adımın "Bitir" butonu gelecek.
              OutlinedButton(
                onPressed: () => completeOnboarding(context),
                child: const Text('Atla (geçici)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
