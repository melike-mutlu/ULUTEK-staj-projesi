/// Information model for food additives (E-numbers).
/// Prepared for integration with Eda's backend API endpoint.
class AdditiveInfo {
  const AdditiveInfo({
    required this.code,
    required this.name,
    required this.category,
    required this.riskLevel,
    required this.description,
    this.source,
  });

  final String code;
  final String name;
  final String category;
  final String riskLevel;
  final String description;
  final String? source;

  factory AdditiveInfo.fromJson(Map<String, dynamic> json) {
    return AdditiveInfo(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'Katkı Maddesi',
      riskLevel: _riskLevelLabel(json['riskLevel'] as String?),
      description: json['description'] as String? ?? '',
      source: json['source'] as String?,
    );
  }

  /// Backend (additives_dictionary.ts) döner: "safe" | "caution" | "avoid".
  /// _RiskBadge Türkçe etiketlere göre renklendiriyor, burada eşliyoruz.
  static String _riskLevelLabel(String? backendRiskLevel) {
    switch (backendRiskLevel) {
      case 'safe':
        return 'Güvenli';
      case 'caution':
        return 'Dikkat Et';
      case 'avoid':
        return 'Yüksek Risk';
      default:
        return 'Bilinmiyor';
    }
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'category': category,
        'risk_level': riskLevel,
        'description': description,
        'source': source,
      };

  /// Returns mock data for standard E-numbers when backend API is not connected.
  static AdditiveInfo getMockInfo(String rawCode) {
    final cleanCode = rawCode.replaceFirst(RegExp('^[a-z]{2}:'), '').toUpperCase().trim();

    final dictionary = <String, AdditiveInfo>{
      'E322': const AdditiveInfo(
        code: 'E322',
        name: 'Lesitin (Soya / Ayçiçeği Lesitini)',
        category: 'Emülgatör',
        riskLevel: 'Düşük Risk',
        description:
            'Gıdalarda homojen karışım sağlamak (yağ ile suyun ayrışmasını önlemek) için kullanılır. Çoğunlukla soya veya ayçiçeğinden elde edilen doğal bir bileşendir.',
        source: 'Bitkisel / Doğal',
      ),
      'E500': const AdditiveInfo(
        code: 'E500',
        name: 'Sodyum Karbonatlar (Kabartıcı Toz)',
        category: 'Kabartıcı & Asitlik Düzenleyici',
        riskLevel: 'Güvenli',
        description:
            'Hamur işleri ve bisküvilerde hacim kazandırmak ve kabartmak amacıyla kullanılır. Sofra tuzuna benzer mineral kaynaklı bir maddedir.',
        source: 'Mineral',
      ),
      'E330': const AdditiveInfo(
        code: 'E330',
        name: 'Sitrik Asit (Limon Tuzu)',
        category: 'Asitlik Düzenleyici & Koruyucu',
        riskLevel: 'Güvenli',
        description:
            'Narenciyelerde doğal olarak bulunan organik bir asittir. Gıdalara ekşi tat vermek ve tazeliğini korumak için yaygın olarak kullanılır.',
        source: 'Doğal / Fermantasyon',
      ),
      'E120': const AdditiveInfo(
        code: 'E120',
        name: 'Karmin (Karminik Asit)',
        category: 'Renklendirici',
        riskLevel: 'Orta Risk',
        description:
            'Kırmızı renk vermek için böcek kabuklarından elde edilen doğal renklendiricidir. Vejetaryen/Vegan beslenmeye ve helal diyet ilkelerine uymayabilir.',
        source: 'Hayvansal (Böcek Kaynaklı)',
      ),
      'E471': const AdditiveInfo(
        code: 'E471',
        name: 'Yağ Asitlerinin Mono- ve Digliseridleri',
        category: 'Emülgatör',
        riskLevel: 'Düşük Risk',
        description:
            'Ürünlerin raf ömrünü uzatmak ve yumuşak doku sağlamak için kullanılır. Bitkisel veya hayvansal yağlardan üretilebilir.',
        source: 'Bitkisel / Hayvansal Değişken',
      ),
      'E211': const AdditiveInfo(
        code: 'E211',
        name: 'Sodyum Benzoat',
        category: 'Koruyucu',
        riskLevel: 'Orta Risk',
        description:
            'Meyve suları ve asitli içeceklerde mantar ve bakteri oluşumunu önlemek için kullanılan sentetik koruyucudur.',
        source: 'Sentetik',
      ),
      'E621': const AdditiveInfo(
        code: 'E621',
        name: 'Monosodyum Glutamat (MSG)',
        category: 'Lezzet Arttırıcı (Umami)',
        riskLevel: 'Dikkat Et',
        description:
            'Aroma ve umami lezzetini pekiştiren tuz bileşenidir. Hassas bireylerde baş ağrısı veya alerjik reaksiyon tetikleyebilir.',
        source: 'Fermantasyon',
      ),
    };

    if (dictionary.containsKey(cleanCode)) {
      return dictionary[cleanCode]!;
    }

    return AdditiveInfo(
      code: cleanCode,
      name: '$cleanCode Katkı Maddesi',
      category: 'Gıda Katkı Maddesi',
      riskLevel: 'Bilgi Alınıyor',
      description:
          '$cleanCode kodlu katkı maddesi hakkında detaylı açıklama Eda\'nın backend servisi bağlandığında otomatik olarak API\'den çekilecektir.',
      source: 'Gıda Bileşeni',
    );
  }
}
