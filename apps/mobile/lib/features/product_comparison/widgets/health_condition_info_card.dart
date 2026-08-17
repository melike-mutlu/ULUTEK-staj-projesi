import 'package:flutter/material.dart';

import '../../../core/theme/akilli_sepet_colors.dart';
import '../../../core/theme/app_colors.dart';

/// Sevde'nin yazacağı sağlık durumu bilgi metnini gösteren özel UI kartı.
///
/// Kural motorunun kesin (uygun / çakışma) kararlarından net bir şekilde
/// ayrışması için özel indigo/soft-teal arka plan, belirgin ikon ve
/// "Sağlık Bilgi Notu · Kural Motorundan Bağımsızdır" alt rozeti içerir.
class HealthConditionInfoCard extends StatelessWidget {
  const HealthConditionInfoCard({
    super.key,
    this.conditionName = 'Sağlık Durumu Değerlendirmesi',
    this.infoText =
        'Bu ürün için sağlık uzmanı tarafından hazırlanan beslenme ve tüketim rehberi notudur.',
    this.expertName = 'Sevde (Beslenme & Sağlık Uzmanı)',
    this.isCompact = false,
  });

  /// Sağlık durumu başlığı (ör. "Diyabet Uyarısı", "Tansiyon & Sodyum Dengesi", "Genel Sağlık Notu")
  final String conditionName;

  /// Sevde'nin kaleme aldığı detaylı/özet sağlık bilgisi metni
  final String infoText;

  /// Bilgiyi yazan uzmanın adı / unvanı
  final String expertName;

  /// Yan yana karşılaştırma matrisinde dar sütunlar için daha sıkışık görünüm
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Kural motorunun kırmızı/yeşil uyarı tonlarıyla KARIŞMAMASI için indigo/soft-teal tonlar
    final cardBg = isDark
        ? const Color(0xFF1E2638)
        : const Color(0xFFF0F4FF);
    final borderColor = isDark
        ? const Color(0xFF3B4B75)
        : const Color(0xFFC7D2FE);
    final iconBgColor = isDark
        ? const Color(0xFF314068)
        : const Color(0xFFE0E7FF);
    final titleColor = isDark
        ? const Color(0xFFE0E7FF)
        : const Color(0xFF3730A3);
    final bodyColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF4338CA);
    final badgeBg = isDark
        ? const Color(0xFF283556)
        : const Color(0xFFE0E7FF);
    final badgeTextColor = isDark
        ? const Color(0xFFA5B4FC)
        : const Color(0xFF4338CA);

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_information_rounded,
                  size: 16,
                  color: titleColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    conditionName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              infoText,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1.3,
                color: bodyColor,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Bilgi Notu',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: badgeTextColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF6366F1))
                .withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kart Üst Başlık & Rozet
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.health_and_safety_rounded,
                  size: 20,
                  color: titleColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conditionName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      expertName,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AkilliSepetColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Metin Alanı
          Text(
            infoText,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: bodyColor,
            ),
          ),
          const SizedBox(height: 10),

          // Kural Motorundan Ayrıştıran Açık Ayrım Rozeti
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor.withOpacity(0.5), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 13,
                  color: badgeTextColor,
                ),
                const SizedBox(width: 5),
                Text(
                  'Genel Bilgilendirme · Kural Motoru Kararından Bağımsızdır',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: badgeTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
