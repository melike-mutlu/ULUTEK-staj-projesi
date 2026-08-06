import 'package:flutter/foundation.dart';

import '../../core/models/explanation.dart';
import '../../core/models/product.dart';
import '../../core/models/rule_engine_result.dart';
import '../../core/models/user_profile.dart';
import '../../data/repositories/explanation_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/profile_repository.dart';

enum ProductDetailStatus { loading, found, notFound, partial, error }

class ProductDetailViewModel extends ChangeNotifier {
  ProductDetailViewModel([this._explanationRepository]);

  final ExplanationRepository? _explanationRepository;

  ProductDetailStatus status = ProductDetailStatus.found;
  Product? product;
  RuleEngineResult? ruleEngineResult;
  Explanation? explanation;

  /// Diyet/sağlık kategorilerini beslemek için tutulur.
  UserProfile? userProfile;

  String? errorMessage;

  ProductDetailViewModel.withMock({String mockState = 'warning'})
      : _explanationRepository = null {
    loadMockState(mockState);
  }

  /// Fetches the barcode from the backend and hands the result to
  /// [loadFromFetchResult]. Used when the screen is opened with a barcode
  /// only (e.g. from scan history).
  Future<void> loadFromBarcode(
    String barcode,
    ProductRepository productRepository,
    ProfileRepository profileRepository,
  ) async {
    status = ProductDetailStatus.loading;
    errorMessage = null;
    product = null;
    ruleEngineResult = null;
    explanation = null;
    notifyListeners();

    final fetchResult = await productRepository.fetchProduct(barcode);
    await loadFromFetchResult(fetchResult, profileRepository);
  }

  /// Barkod arama sonucunu (ProductFetchResult) ve gerçek kullanıcı profilini (profileRepository) alıp işler.
  Future<void> loadFromFetchResult(
    ProductFetchResult fetchResult,
    ProfileRepository profileRepository,
  ) async {
    status = ProductDetailStatus.loading;
    errorMessage = null;
    notifyListeners();

    if (fetchResult.status == 'error') {
      status = ProductDetailStatus.error;
      errorMessage = fetchResult.errorMessage ??
          'Ürün bilgileri alınırken bir hata oluştu.';
      notifyListeners();
      return;
    }

    if (fetchResult.status == 'not_found' || fetchResult.product == null) {
      status = ProductDetailStatus.notFound;
      notifyListeners();
      return;
    }

    final product = fetchResult.product!;
    final ruleEngineResult = fetchResult.ruleEngineResult ??
        const RuleEngineResult(
          matchedAllergens: [],
          hasConflict: false,
          veganCompatible: true,
        );

    // profileRepositoryProvider üzerinden gerçek kullanıcı profilini çek
    UserProfile? userProfile;
    final userId = profileRepository.currentUserId;
    if (userId != null) {
      try {
        userProfile = await profileRepository.getProfile(userId);
      } catch (e) {
        debugPrint('[ProductDetailViewModel] Profile load warning: $e');
      }
    }

    // Profil veritabanında henüz oluşturulmadıysa varsayılan profil
    userProfile ??= UserProfile(
      userId: userId ?? 'guest',
      allergies: const [],
      dietPreferences: const [],
      healthConditions: const [],
    );

    await load(
      product: product,
      ruleEngineResult: ruleEngineResult,
      userProfile: userProfile,
    );
  }

  void loadMockState(String state) {
    status = ProductDetailStatus.loading;
    notifyListeners();

    switch (state) {
      case 'pending':
      case 'unverified':
        product = const Product(
          barcode: '9998887776655',
          name: 'Organik Ev Yapımı Granola',
          brand: 'Topluluk Katkısı',
          ingredientsText: 'Yulaf ezmesi, bal, ceviz, tarçın.',
          additives: [],
          allergensTags: ['en:nuts'],
          nutriments: Nutriments(
            energyKcal100g: 380,
            sugars100g: 14.0,
            fat100g: 15.0,
            proteins100g: 9.0,
            salt100g: 0.02,
          ),
          nutriscore: 'b',
          isPending: true,
        );

        ruleEngineResult = const RuleEngineResult(
          matchedAllergens: [],
          hasConflict: false,
          veganCompatible: false,
          diabeticNote: null,
        );

        explanation = const Explanation(
          summary: 'Topluluk tarafından eklenen granola tarifi.',
          level: WarningLevel.caution,
          warningMessage:
              'Bu ürün henüz yetkililerce doğrulanmadı. Tüketmeden önce içerik ve alerjen etiketini dikkatle kontrol ediniz. (Doğrulanmadı, dikkatli ol)',
          dietNote: 'Topluluk verisidir.',
          disclaimer: 'Bu bilgi tıbbi tavsiye niteliği taşımaz.',
        );
        break;

      case 'warning':
      case 'red':
        product = const Product(
          barcode: '8690504041502',
          name: 'Çikolatalı Gofret',
          brand: 'Ülker',
          imageUrl:
              'https://images.openfoodfacts.org/images/products/869/050/404/1502/front_tr.3.400.jpg',
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
          imageUrl:
              'https://images.openfoodfacts.org/images/products/869/050/411/2233/front_tr.3.400.jpg',
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
          ingredientsText:
              'Hurma, fındık (%20), kakao kitlesi (%10), deniz tuzu.',
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

    _applyPendingProductRule();
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
    this.userProfile = userProfile;
    status = ProductDetailStatus.loading;
    notifyListeners();

    final repo = _explanationRepository;
    if (repo != null) {
      try {
        final llm = await repo.explainProduct(
          product: product,
          ruleEngineResult: ruleEngineResult,
          userProfile: userProfile,
        );
        // The rule engine owns the verdict: keep the LLM text but never let its
        // level fall below the deterministic floor.
        explanation = _clampToRuleEngine(llm, ruleEngineResult);
      } catch (e) {
        debugPrint('[ProductDetailViewModel] explain-product failed: $e');
        explanation = _deterministicExplanation(product, ruleEngineResult);
      }
    } else {
      explanation = _deterministicExplanation(product, ruleEngineResult);
    }

    _applyPendingProductRule();
    status = ProductDetailStatus.found;
    notifyListeners();
  }

  /// The verdict when the LLM is unavailable: comes purely from the rule engine.
  Explanation _deterministicExplanation(
    Product product,
    RuleEngineResult rule,
  ) {
    return Explanation(
      summary: '${product.name} için ürün analizi tamamlandı.',
      level: rule.hasConflict ? WarningLevel.warning : WarningLevel.ok,
      warningMessage: rule.hasConflict
          ? 'Bu üründe riskli içerik veya alerjen tespit edildi.'
          : 'Bu ürün profilinize uygundur.',
      disclaimer: 'Bu bilgi tıbbi tavsiye niteliği taşımaz.',
    );
  }

  /// Client-side guard mirroring the backend clamp: the LLM may raise severity
  /// but can never lower the verdict below the rule engine floor.
  Explanation _clampToRuleEngine(Explanation llm, RuleEngineResult rule) {
    final floor = rule.hasConflict ? WarningLevel.warning : WarningLevel.ok;
    final level = llm.level.index >= floor.index ? llm.level : floor;
    if (level == llm.level) return llm;
    return Explanation(
      summary: llm.summary,
      level: level,
      warningMessage: llm.warningMessage,
      dietNote: llm.dietNote,
      disclaimer: llm.disclaimer,
    );
  }

  /// Eğer ürün PENDING ise (topluluk tarafından eklenmiş, doğrulanmamış),
  /// kural motoru sonucu ne olursa olsun asla yeşil/güvenli gösterilmez.
  /// Seviye en az WarningLevel.caution (nötr/dikkat) yapılır.
  void _applyPendingProductRule() {
    final prod = product;
    final exp = explanation;
    if (prod != null && prod.isPending && exp != null) {
      final newLevel =
          exp.level == WarningLevel.ok ? WarningLevel.caution : exp.level;
      explanation = Explanation(
        summary: exp.summary,
        level: newLevel,
        warningMessage: exp.level == WarningLevel.ok
            ? 'Bu ürün topluluk tarafından eklendi, henüz doğrulanmadı. Bilgiler resmi onay beklemektedir.'
            : exp.warningMessage,
        // Pending is shown by the "Doğrulanmadı" badge only; injecting it here
        // as well repeated the same warning three times on one screen.
        dietNote: exp.dietNote,
        disclaimer: exp.disclaimer,
      );
    }
  }

  void setStatusFromFetch(String fetchStatus) {
    status = fetchStatus == 'not_found'
        ? ProductDetailStatus.notFound
        : ProductDetailStatus.partial;
    notifyListeners();
  }
}
