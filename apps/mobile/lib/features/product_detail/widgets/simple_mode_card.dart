import 'package:flutter/material.dart';

class SimpleModeCard extends StatelessWidget {
  final String level;
  final String? matchedReasons; // Boşluğa gelecek kısım (Örn: "süt alerjiniz")

  const SimpleModeCard({
    super.key,
    required this.level,
    this.matchedReasons,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    String subtitle;
    Color bgColor;
    Color borderColor;
    Color iconColor;
    IconData iconData;

    final hasReason = matchedReasons != null && matchedReasons!.trim().isNotEmpty;
    final reasonText = hasReason ? matchedReasons!.trim() : 'profilinizdeki kısıtlamalar';

    // Seviyeye göre KALIP CÜMLELERİ burada oluşturuyoruz
    switch (level.toLowerCase()) {
      case 'ok':
        title = 'Uygun';
        subtitle = 'Bu ürün beslenme ve sağlık profilinize tam uyumludur, güvenle tüketebilirsiniz.';
        bgColor = Colors.green.shade50;
        borderColor = Colors.green.shade300;
        iconColor = Colors.green.shade700;
        iconData = Icons.check_circle_rounded;
        break;
      
      case 'caution':
        title = 'Dikkatli Ol';
        subtitle = 'Bu ürünü $reasonText sebebiyle dikkatli tüketmeniz önerilmektedir.';
        bgColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade300;
        iconColor = Colors.orange.shade700;
        iconData = Icons.warning_rounded;
        break;
      
      case 'warning':
      default:
        title = 'Uygun Değil';
        subtitle = 'Bu ürün $reasonText sebebiyle tüketiminize uygun değildir.';
        bgColor = Colors.red.shade50;
        borderColor = Colors.red.shade300;
        iconColor = Colors.red.shade700;
        iconData = Icons.cancel_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, size: 56, color: iconColor),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: iconColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle, // Şablona oturtulmuş cümle burada basılıyor
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87.withOpacity(0.8),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}