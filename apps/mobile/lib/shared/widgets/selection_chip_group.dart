import 'package:flutter/material.dart';

import 'question_card.dart';
import 'selectable_chip.dart';

/// Başlık + çoklu seçim çipleri. Onboarding seçim adımı ve profil formu bunu
/// paylaşır. State tutmaz; seçimler ve seçenek listesi dışarıdan gelir.
///
/// Doğal yüksekliğinde çizilir (`Expanded` yok) — kaydırma kararı çağıran
/// ekrana ait: onboarding tek grubu scroll'a sarar, profil üç grubu alt alta
/// dizer.
class SelectionChipGroup extends StatelessWidget {
  const SelectionChipGroup({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onToggle,
    required this.onAddCustom,
    this.titlePadding = EdgeInsets.zero,
  });

  final String title;

  /// Sabit seçenekler + kullanıcının "+" ile eklediği seçenekler.
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onAddCustom;

  /// Başlık kartının dış boşluğu — çipleri etkilemez (onboarding başlığı
  /// progress bar ile hizalamak için sol inset verir).
  final EdgeInsets titlePadding;

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
          padding: titlePadding,
          child: QuestionCard(question: title),
        ),
        const SizedBox(height: _gap),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: <Widget>[
            for (final option in options)
              SelectableChip(
                label: option,
                isSelected: selected.contains(option),
                onTap: () => onToggle(option),
              ),
            SelectableChip.add(onTap: () => _openAddDialog(context)),
          ],
        ),
      ],
    );
  }
}
