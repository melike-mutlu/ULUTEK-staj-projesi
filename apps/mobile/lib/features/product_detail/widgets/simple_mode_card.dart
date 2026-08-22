import 'package:flutter/material.dart';

class SimpleModeCard extends StatelessWidget {
  final String level;
  final List<String>? conflictPhrases; // Artık düz yazı değil, liste alıyoruz!

  const SimpleModeCard({
    super.key,
    required this.level,
    this.conflictPhrases,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    Color bgColor;
    Color borderColor;
    Color iconColor;
    IconData iconData;

    String prefix = '';
    String suffix = '';
    final isOk = level.toLowerCase() == 'ok';

    // 1. Temel Renkler ve Cümle Kalıpları
    switch (level.toLowerCase()) {
      case 'ok':
        title = 'Uygun';
        prefix = 'Bu ürün beslenme ve sağlık profilinize tam uyumludur, güvenle tüketebilirsiniz.';
        bgColor = Colors.green.shade50;
        borderColor = Colors.green.shade300;
        iconColor = Colors.green.shade700;
        iconData = Icons.check_circle_rounded;
        break;
      
      case 'caution':
        title = 'Dikkatli Ol';
        prefix = 'Bu ürünü ';
        suffix = ' sebebiyle dikkatli tüketmeniz önerilmektedir.';
        bgColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade300;
        iconColor = Colors.orange.shade700;
        iconData = Icons.warning_rounded;
        break;
      
      case 'warning':
      default:
        title = 'Uygun Değil';
        prefix = 'Bu ürün ';
        suffix = ' sebebiyle tüketiminize uygun değildir.';
        bgColor = Colors.red.shade50;
        borderColor = Colors.red.shade300;
        iconColor = Colors.red.shade700;
        iconData = Icons.cancel_rounded;
        break;
    }

    // 2. Yazı Stilleri (Normal ve Kalın)
    final normalStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: Colors.black87.withOpacity(0.8),
      height: 1.45,
    );

    final boldStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold, // İŞTE BURASI KALIN YAPAN YER
      color: Colors.black87,
      height: 1.45,
    );

// 3. Lego Parçalarını (TextSpan) Birleştirme İşlemi
    List<TextSpan> spans = [];

    if (isOk) {
      // Ürün uygunsa doğrudan olumlu tam cümleyi bas (prefix)
      spans.add(TextSpan(text: prefix, style: normalStyle));
      
    } else if (conflictPhrases == null || conflictPhrases!.isEmpty) {
      // Ürün Sarı veya Kırmızı ama elimizde spesifik bir sebep yoksa (liste boşsa):
      // Yukarıda ayarladığımız prefix ve suffix'i birleştir!
      spans.add(TextSpan(
        text: '$prefix profilinizdeki kısıtlamalar$suffix',
        style: normalStyle,
      ));
      
    } else {
      // Ürün uyumsuzsa ve elimizde sebepler varsa:
      spans.add(TextSpan(text: prefix, style: normalStyle)); // "Bu ürün "

      for (int i = 0; i < conflictPhrases!.length; i++) {
        // Sebebin KENDİSİNİ KALIN YAZ ("Fındık alerjiniz")
        spans.add(TextSpan(text: conflictPhrases![i], style: boldStyle));

        // Araya virgül veya "ve" bağlaçlarını NORMAL YAZ
        if (i < conflictPhrases!.length - 2) {
          spans.add(TextSpan(text: ", ", style: normalStyle));
        } else if (i == conflictPhrases!.length - 2) {
          spans.add(TextSpan(text: " ve ", style: normalStyle));
        }
      }

      spans.add(TextSpan(text: suffix, style: normalStyle)); // " sebebiyle..." (Duruma göre değişir)
    }

    // 4. Kart Tasarımı
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
          
          // ESKİ TEXT WİDGET'I YERİNE ARTIK RICHTEXT KULLANIYORUZ
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(children: spans),
          ),
        ],
      ),
    );
  }
}