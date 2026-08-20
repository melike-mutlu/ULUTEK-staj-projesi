import 'package:flutter/material.dart';

class SimpleModeCard extends StatelessWidget {
  final String level; // 'ok', 'caution', 'warning' vb. gelecek

  const SimpleModeCard({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    String title;
    Color bgColor;
    Color borderColor;
    IconData iconData;

    // Gelen risk seviyesine göre kartın rengini ve metnini belirliyoruz
    switch (level.toLowerCase()) {
      case 'ok':
        title = 'Uygun ✅';
        bgColor = Colors.green.shade50;
        borderColor = Colors.green.shade200;
        iconData = Icons.check_circle_outline_rounded;
        break;
      case 'caution':
        title = 'Dikkatli ol ⚠️';
        bgColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade300;
        iconData = Icons.warning_amber_rounded;
        break;
      case 'warning':
      default:
        title = 'Uygun Değil ❌';
        bgColor = Colors.red.shade50;
        borderColor = Colors.red.shade200;
        iconData = Icons.cancel_outlined;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, size: 100, color: borderColor.withOpacity(0.8)),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}