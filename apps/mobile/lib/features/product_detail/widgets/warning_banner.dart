import 'package:flutter/material.dart';
import '../../../core/models/explanation.dart';

/// Ürün detay ekranının en üstündeki kişisel uygunluk sonucu bandı/kartı.
/// 3 duruma karşılık gelir: Kırmızı (warning) / Sarı (caution) / Yeşil (ok).
class WarningBanner extends StatelessWidget {
  const WarningBanner({super.key, required this.explanation});

  final Explanation explanation;

  Color get _mainColor {
    switch (explanation.level) {
      case WarningLevel.warning:
        return const Color(0xFFDC2626); // Kırmızı
      case WarningLevel.caution:
        return const Color(0xFFD97706); // Sarı / Turuncu
      case WarningLevel.ok:
        return const Color(0xFF16A34A); // Yeşil
    }
  }

  Color get _bgColor {
    switch (explanation.level) {
      case WarningLevel.warning:
        return const Color(0xFFFEF2F2);
      case WarningLevel.caution:
        return const Color(0xFFFFFBEB);
      case WarningLevel.ok:
        return const Color(0xFFF0FDF4);
    }
  }

  Color get _borderColor {
    switch (explanation.level) {
      case WarningLevel.warning:
        return const Color(0xFFFCA5A5);
      case WarningLevel.caution:
        return const Color(0xFFFDE68A);
      case WarningLevel.ok:
        return const Color(0xFF86EFAC);
    }
  }

  IconData get _icon {
    switch (explanation.level) {
      case WarningLevel.warning:
        return Icons.gpp_bad_rounded;
      case WarningLevel.caution:
        return Icons.report_problem_rounded;
      case WarningLevel.ok:
        return Icons.verified_user_rounded;
    }
  }

  String get _statusTitle {
    switch (explanation.level) {
      case WarningLevel.warning:
        return 'UYGUN DEĞİL / RİSKLİ';
      case WarningLevel.caution:
        return 'DİKKAT EDİLMELİ';
      case WarningLevel.ok:
        return 'SİZİN İÇİN UYGUN';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border.all(color: _borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _mainColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _mainColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon,
                  color: _mainColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _statusTitle,
                  style: TextStyle(
                    color: _mainColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            explanation.warningMessage.isNotEmpty
                ? explanation.warningMessage
                : explanation.summary,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          if (explanation.dietNote != null && explanation.dietNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.nature_people_rounded, size: 16, color: _mainColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      explanation.dietNote!,
                      style: TextStyle(
                        fontSize: 12,
                        color: _mainColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (explanation.disclaimer.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              explanation.disclaimer,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
