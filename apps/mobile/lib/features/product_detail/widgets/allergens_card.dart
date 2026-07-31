import 'package:flutter/material.dart';
import '../../../core/models/product.dart';
import '../../../core/models/rule_engine_result.dart';

/// Alerjen etiketleri ve İçindekiler metnini gösteren kart.
/// Kullanıcının profiliyle eşleşen alerjenler belirgin kırmızı/turuncu renkle vurgulanır.
class AllergensCard extends StatelessWidget {
  const AllergensCard({
    super.key,
    required this.product,
    this.ruleEngineResult,
  });

  final Product product;
  final RuleEngineResult? ruleEngineResult;

  String _cleanAllergenName(String tag) {
    // "en:gluten" -> "Gluten", "en:milk" -> "Süt / Milk"
    final clean = tag.replaceAll('en:', '').replaceAll('tr:', '').trim();
    switch (clean.toLowerCase()) {
      case 'gluten':
        return 'Gluten';
      case 'milk':
        return 'Süt / Laktoz';
      case 'soy':
      case 'soya':
        return 'Soya';
      case 'nuts':
        return 'Kabuklu Yemişler';
      case 'peanuts':
        return 'Yer Fıstığı';
      case 'eggs':
        return 'Yumurta';
      default:
        return clean.isNotEmpty ? clean[0].toUpperCase() + clean.substring(1) : tag;
    }
  }

  bool _isMatchedAllergen(String tag) {
    if (ruleEngineResult == null) return false;
    final clean = tag.replaceAll('en:', '').replaceAll('tr:', '').toLowerCase().trim();
    return ruleEngineResult!.matchedAllergens.any(
      (m) => m.toLowerCase().contains(clean) || clean.contains(m.toLowerCase()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchedCount = ruleEngineResult?.matchedAllergens.length ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: matchedCount > 0 ? const Color(0xFFDC2626) : const Color(0xFF26B384),
              ),
              const SizedBox(width: 8),
              const Text(
                'Alerjenler & İçindekiler',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Alerjen Badgeleri
          if (product.allergensTags.isNotEmpty) ...[
            const Text(
              'Tespit Edilen Alerjenler:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.allergensTags.map((tag) {
                final isMatched = _isMatchedAllergen(tag);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isMatched ? const Color(0xFFFEF2F2) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isMatched ? const Color(0xFFFCA5A5) : const Color(0xFFE5E7EB),
                      width: isMatched ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isMatched) ...[
                        const Icon(Icons.error_outline_rounded, size: 14, color: Color(0xFFDC2626)),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        _cleanAllergenName(tag),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isMatched ? FontWeight.bold : FontWeight.w500,
                          color: isMatched ? const Color(0xFFDC2626) : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ] else ...[
            const Text(
              'Bu üründe bilinen alerjen bilgisi kaydı yok.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
          ],

          // Katkı Maddeleri
          if (product.additives.isNotEmpty) ...[
            const Text(
              'Katkı Maddeleri:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: product.additives.map((add) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    add,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // İçindekiler Metni
          if (product.ingredientsText.isNotEmpty) ...[
            const Text(
              'İçindekiler:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Text(
                product.ingredientsText,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF374151),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
