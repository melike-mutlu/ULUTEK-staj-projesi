import 'package:flutter/material.dart';

import '../onboarding_steps.dart' as onboarding_steps;
import 'onboarding_question_card.dart';
import 'selectable_chip.dart';

/// 3 seçim ekranının TEK widget'ı: `step.field`'a göre farklı soru/seçenek
/// gösterir. State tutmaz — tüm state `OnboardingViewModel`'de.
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

  static const double _gap = 20;

  Future<void> _openAddDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Seçenek ekle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (String value) => Navigator.pop(dialogContext, value),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
    if (result != null) onAddCustom(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: questionLeftInset),
          child: OnboardingQuestionCard(question: step.question),
        ),
        const SizedBox(height: _gap),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: <Widget>[
                for (final option in options)
                  SelectableChip(
                    label: option,
                    isSelected: selections.contains(option),
                    onTap: () => onToggle(option),
                  ),
                SelectableChip.add(onTap: () => _openAddDialog(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
