import 'package:flutter/foundation.dart';

import '../../core/models/explanation.dart';
import '../../core/models/product.dart';
import '../../core/models/rule_engine_result.dart';
import '../../core/models/user_profile.dart';
import '../../data/repositories/explanation_repository.dart';
import '../../data/repositories/product_repository.dart';

enum ProductDetailStatus { loading, found, notFound, partial, error }

class ProductDetailViewModel extends ChangeNotifier {
  ProductDetailViewModel([this._explanationRepository]);

  final ExplanationRepository? _explanationRepository;

  ProductDetailStatus status = ProductDetailStatus.found;
  Product? product;
  RuleEngineResult? ruleEngineResult;
  Explanation? explanation;

  ProductDetailViewModel.withMock({String mockState = 'warning'})
      : _explanationRepository = null {
    loadMockState(mockState);
  }

  void loadMockState(String state) {
    status = ProductDetailStatus.loading;
    notifyListeners();

    switch (state) {
      case 'warning':
      case 'red':
        product = const Product(
          barcode: '8690504041502',
          name: 'Çikolatalı Gofret',
          brand: 'Ülker',
          ingredientsText:
              'Buğday unu, şeker, bitkisel yağ (palm), kakao kitlesi, tam yağlı süt tozu, fındık püresi, emülgatör (soya lesitini), kabartıcı (sodyum hidrojen karbonat), tuz.',
          additives: ['E322', 'E500'],
          allergensTags: ['en:gluten', 'en:milk', 'en:soy', 'en:nuts'],
          nutriments: Nutriments(
            energyKcal100g: 495,
            sugars100g: 38.2,
            fat100g: 27.1,
            proteins100g: 6.5,
            salt100g: 0.35,
          ),
          nutriscore: 'd',
        );

        ruleEngineResult = const RuleEngineResult(
          matchedAllergens: ['gluten', 'milk'],
          hasConflict: true,
          veganCompatible: false,
          diabeticNote: 'Yüksek şeker içeriği (100g kalıpta 38.2g)',
        );

        explanation = const Explanation(
          summary:
              'Bu ürün buğday unu, şeker, kakao ve süt tozu içeren çikolatalı bir gofrettir.',
          level: WarningLevel.warning,
          warningMessage:
              'Bu üründe GLUTEN ve SÜT ürünleri bulunmaktadır. Profilinizdeki alerji kayıtlarınız ile doğrudan çakışmaktadır. Tüketilmesi önerilmez!',
          dietNote: 'Diyabet uyarısı: 100g ürün 38.2g şeker içerir.',
          disclaimer: 'Bu bilgi tıbbi tavsiye niteliği taşımaz.',
        );
        break;

      case 'caution':
      case 'yellow':
        product = const Product(
          barcode: '8690504112233',
          name: 'Süzme Yoğurt 500g',
          brand: 'Sütaş',
          ingredientsText: 'Pastörize inek sütü, yoğurt kültürü.',
          additives: [],
          allergensTags: ['en:milk'],
          nutriments: Nutriments(
            energyKcal100g: 120,
            sugars100g: 4.5,
            fat100g: 8.0,
            proteins100g: 7.5,
            salt100g: 0.8,
          ),
          nutriscore: 'b',
        );

        ruleEngineResult = const RuleEngineResult(
          matchedAllergens: [],
          hasConflict: false,
          veganCompatible: false,
          diabeticNote: 'Düşük şeker oranıyla uygundur.',
        );

        explanation = const Explanation(
          summary:
              'Bu ürün yüksek proteinli ve kalsiyum bakımından zengin bir süzme yoğurttur.',
          level: WarningLevel.caution,
          warningMessage:
              'Alerjen kısıtlaması tetiklenmedi ancak laktoz hassasiyetiniz varsa porsiyon miktarına dikkat ediniz.',
          dietNote: 'Yüksek protein desteği sağlar.',
          disclaimer: 'Bu bilgi tıbbi tavsiye niteliği taşımaz.',
        );
        break;

      case 'ok':
      case 'green':
      default:
        product = const Product(
          barcode: '8681234567890',
          name: 'Fındık & Kakao Meyve Barı',
          brand: 'Zuber',
          ingredientsText: 'Hurma, fındık (%20), kakao kitlesi (%10), deniz tuzu.',
          additives: [],
          allergensTags: ['en:nuts'],
          nutriments: Nutriments(
            energyKcal100g: 320,
            sugars100g: 18.0,
            fat100g: 12.0,
            proteins100g: 8.0,
            salt100g: 0.05,
          ),
          nutriscore: 'a',
        );

        ruleEngineResult = const RuleEngineResult(
          matchedAllergens: [],
          hasConflict: false,
          veganCompatible: true,
          diabeticNote: null,
        );

        explanation = const Explanation(
          summary:
              'İlave şekersiz, tamamen doğal meyve ve kuruyemişlerden üretilmiş bar.',
          level: WarningLevel.ok,
          warningMessage:
              'Tebrikler! Bu ürün kişisel profilinize, diyet tercihlerinize ve alerjen listenize tamamen uygundur.',
          dietNote: 'Glutensiz ve %100 Vegan dostu içerik.',
          disclaimer: 'Bu bilgi tıbbi tavsiye niteliği taşımaz.',
        );
        break;
    }

    status = ProductDetailStatus.found;
    notifyListeners();
  }

  Future<void> load({
    required Product product,
    required RuleEngineResult ruleEngineResult,
    required UserProfile userProfile,
  }) async {
    this.product = product;
    this.ruleEngineResult = ruleEngineResult;
    status = ProductDetailStatus.loading;
    notifyListeners();

    if (_explanationRepository != null) {
      explanation = await _explanationRepository.explainProduct(
        product: product,
        ruleEngineResult: ruleEngineResult,
        userProfile: userProfile,
      );
    } else {
      explanation = Explanation(
        summary: '${product.name} için ürün analizi tamamlandı.',
        level: ruleEngineResult.hasConflict
            ? WarningLevel.warning
            : WarningLevel.ok,
        warningMessage: ruleEngineResult.hasConflict
            ? 'Bu üründe riskli içerik veya alerjen tespit edildi.'
            : 'Bu ürün profilinize uygundur.',
        disclaimer: 'Bu bilgi tıbbi tavsiye niteliği taşımaz.',
      );
    }

    status = ProductDetailStatus.found;
    notifyListeners();
  }

  void setStatusFromFetch(String fetchStatus) {
    status = fetchStatus == 'not_found'
        ? ProductDetailStatus.notFound
        : ProductDetailStatus.partial;
    notifyListeners();
  }

  /// ScanView veya fetch-product API'sinden gelen gerçek sonucu ekrana yükler.
  void loadFromFetchResult(ProductFetchResult result) {
    if (result.status == 'not_found' || result.product == null) {
      status = ProductDetailStatus.notFound;
      product = null;
      ruleEngineResult = null;
      explanation = null;
      notifyListeners();
      return;
    }

    product = result.product;
    ruleEngineResult = result.ruleEngineResult;
    status = result.status == 'partial'
        ? ProductDetailStatus.partial
        : ProductDetailStatus.found;

    final ruleRes = result.ruleEngineResult;
    final hasConflict = ruleRes?.hasConflict ?? false;
    final matchedAllergens = ruleRes?.matchedAllergens ?? [];

    WarningLevel level;
    String warningMessage;

    if (hasConflict || matchedAllergens.isNotEmpty) {
      level = WarningLevel.warning;
      final allergenStr =
          matchedAllergens.map((e) => e.toUpperCase()).join(', ');
      warningMessage = matchedAllergens.isNotEmpty
          ? 'Bu üründe $allergenStr tespit edildi. Profilinizdeki alerji kayıtlarınız ile çakışmaktadır!'
          : 'Bu ürün diyet veya sağlık tercihlerinize kısıtlama getirmektedir.';
    } else if (ruleRes?.diabeticNote != null &&
        ruleRes!.diabeticNote!.isNotEmpty) {
      level = WarningLevel.caution;
      warningMessage =
          'Alerjen çakışması yok ancak diyet uyarısı mevcut: ${ruleRes.diabeticNote}';
    } else {
      level = WarningLevel.ok;
      warningMessage =
          'Tebrikler! Bu ürün kişisel profilinize ve diyet tercihlerinize tam uygundur.';
    }

    explanation = Explanation(
      summary:
          '${product!.name}${product!.brand != null ? " (${product!.brand})" : ""} ürün analizi.',
      level: level,
      warningMessage: warningMessage,
      dietNote: ruleRes?.diabeticNote,
      disclaimer: 'Bu bilgi tıbbi tavsiye niteliği taşımaz.',
    );

    notifyListeners();
  }
}
