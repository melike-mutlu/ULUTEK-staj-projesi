import 'package:flutter/material.dart';

import '../../../shared/widgets/selection_chip_group.dart';
import '../onboarding_steps.dart' as onboarding_steps;

/// 3 seçim ekranının TEK widget'ı: `step.field`'a göre farklı soru/seçenek
/// gösterir. State tutmaz — tüm state `OnboardingViewModel`'de.
///
/// Görsel gövde paylaşılan [SelectionChipGroup]'tan gelir; burada yalnızca
/// adım modeli prop'lara çevrilir ve grup ekranın kaydırma alanına sarılır.
class OnboardingSelectionStep extends StatelessWidget {
  const OnboardingSelectionStep({
    super.key,
    required this.step,
    required this.options,
    required this.selections,
    required this.onToggle,
    required this.onAddCustom,
    this.questionLeftInset = 0,
  });

  final onboarding_steps.OnboardingSelectionStep step;

  /// Sabit seçenekler + kullanıcının "+" ile eklediği seçenekler.
  final List<String> options;
  final Set<String> selections;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onAddCustom;

  /// Soru kutusunun sol kenarını üstteki progress bar ile hizalamak için
  /// eklenen sol boşluk.
  final double questionLeftInset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: SelectionChipGroup(
              title: step.question,
              titlePadding: EdgeInsets.only(left: questionLeftInset),
              options: options,
              selected: selections,
              onToggle: onToggle,
              onAddCustom: onAddCustom,
            ),
          ),
        ),
      ],
    );
  }
}
