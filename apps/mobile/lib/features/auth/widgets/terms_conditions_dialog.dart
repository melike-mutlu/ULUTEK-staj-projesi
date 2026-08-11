import 'package:flutter/material.dart';
import '../../../core/theme/akilli_sepet_colors.dart';

/// Kullanım Şartları ve Gizlilik Sözleşmesi detaylarını gösteren diyalog penceresi.
class TermsConditionsDialog extends StatelessWidget {
  const TermsConditionsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const TermsConditionsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AkilliSepetColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.gavel_rounded,
              color: AkilliSepetColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Kullanım Şartları ve Gizlilik Sözleşmesi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AkilliSepetColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: const SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lütfen Akıllı Sepet uygulamasını kullanmadan önce aşağıdaki kullanım şartlarını ve gizlilik esaslarını dikkatlice okuyunuz.',
                style: TextStyle(
                  fontSize: 13,
                  color: AkilliSepetColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 16),

              _TermsSection(
                title: '1. Taraflar ve Amaç',
                body:
                    'İşbu sözleşme, Akıllı Sepet uygulaması ("Uygulama") ile Uygulamayı kullanan kişi ("Kullanıcı") arasında akdedilmiştir. Uygulamanın amacı, kullanıcılara ürün barkodlarını tarama, ürün içeriklerini görüntüleme ve kişisel alerji/diyet tercihlerine göre yapay zeka destekli rehberlik sunmaktır.',
              ),
              _TermsSection(
                title: '2. Hizmet Kapsamı ve Sorumluluk Reddi (Önemli Uyarı)',
                body:
                    'Uygulama tarafından sağlanan içerik analizleri, alerjegen uyarıları ve ürün değerlendirmeleri yalnızca bilgilendirme ve rehberlik amaçlıdır. Uygulamadaki veriler resmi ambalaj bilgileri ve açık kaynak veri tabanlarından derlenmektedir. Uygulama hiçbir şekilde tıbbi tavsiye, teşhis veya tedavi niteliği taşımaz. Kullanıcının sağlığı, diyet tercihleri ve ürün tüketimi ile ilgili nihai sorumluluk tamamen Kullanıcıya aittir.',
              ),
              _TermsSection(
                title: '3. Kişisel Veriler ve KVKK Aydınlatması',
                body:
                    'Akıllı Sepet, kullanıcının belirlediği alerji, diyet, sağlık verileri ile e-posta adresini hizmetin sunulabilmesi amacıyla güvenli veritabanlarında saklar. Kişisel verileriniz 6698 sayılı KVKK ilkelerine uygun olarak korunmakta olup, üçüncü taraf kurum veya kuruluşlarla ticari amaçla paylaşılmamaktadır.',
              ),
              _TermsSection(
                title: '4. Kullanıcı Yükümlülükleri',
                body:
                    'Kullanıcı, kayıt oluştururken doğru ve güncel bilgiler vermeyi, hesap güvenliğini ve şifre gizliliğini korumayı kabul eder. Yetkisiz hesap kullanımı tespiti halinde derhal uygulama yönetimine haber verilmelidir.',
              ),
              _TermsSection(
                title: '5. Fesih ve Sözleşme Değişiklikleri',
                body:
                    'Uygulama yönetimi, kullanım şartlarını önceden bildirmeksizin güncelleme hakkını saklı tutar. Güncel şartlar Uygulama içerisinde yayınlandığı tarihte yürürlüğe girer. Kullanıcı dilediği zaman hesabını silerek sözleşmeyi sonlandırabilir.',
              ),

              SizedBox(height: 8),
              Text(
                'Son Güncelleme Tarihi: 11 Ağustos 2026',
                style: TextStyle(
                  fontSize: 11,
                  color: AkilliSepetColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AkilliSepetColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Anladım ve Kapat',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class _TermsSection extends StatelessWidget {
  const _TermsSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AkilliSepetColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: AkilliSepetColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
