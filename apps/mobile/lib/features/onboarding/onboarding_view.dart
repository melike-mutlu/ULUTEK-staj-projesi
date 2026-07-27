import 'package:flutter/material.dart';

import '../../core/navigation/app_routes.dart';

/// Figma: "Onboarding" mockup — alerji/diyet/sağlık seçim adımları.
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Onboarding'),
            const SizedBox(height: 16),
            // Geçici: kabuk ve sekmeler şimdiden gezilebilsin diye.
            // Onboarding adımları yazılınca son adımın butonuyla değiştirilecek.
            TextButton(
              onPressed: () => completeOnboarding(context),
              child: const Text('Atla'),
            ),
          ],
        ),
      ),
    );
  }
}
