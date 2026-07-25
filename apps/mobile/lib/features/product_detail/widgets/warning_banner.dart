import 'package:flutter/material.dart';

import '../../../core/models/explanation.dart';

/// Ürün detay ekranının en üstündeki kişisel uyarı bandı.
/// Figma mockup'larındaki 3 duruma karşılık gelir: Kırmızı / Sarı / Yeşil.
/// Üç ayrı widget yerine tek widget, `level`'a göre renk/metin değiştirir.
class WarningBanner extends StatelessWidget {
  const WarningBanner({super.key, required this.explanation});

  final Explanation explanation;

  Color _backgroundColor() {
    switch (explanation.level) {
      case WarningLevel.warning:
        return const Color(0xFFF0402A);
      case WarningLevel.caution:
        return const Color(0xFFFFB020);
      case WarningLevel.ok:
        return const Color(0xFF1FA463);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: _backgroundColor(),
      child: Text(
        explanation.warningMessage,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
