import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/providers.dart';
import '../../core/theme/akilli_sepet_colors.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../l10n/app_localizations.dart';
import '../settings/read_aloud_viewmodel.dart';
import 'product_detail_viewmodel.dart';
import 'profile_checks.dart';
import 'read_aloud_script.dart';
import 'widgets/ingredients_section.dart';
import 'widgets/nutriments_card.dart';
import 'widgets/other_allergens_section.dart';
import 'widgets/personal_risks_section.dart';
import 'widgets/profile_check_section.dart';
import 'widgets/product_header_card.dart';
import 'widgets/recommendations_section.dart';
import 'widgets/warning_banner.dart';
import '../product_comparison/widgets/health_condition_info_card.dart';

class ProductDetailView extends ConsumerStatefulWidget {
  const ProductDetailView({super.key});

  @override
  ConsumerState<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends ConsumerState<ProductDetailView> {
  late final ProductDetailViewModel _viewModel;
  bool _isInitialLoaded = false;
  String? _scannedBarcode;

  /// Guards the auto read-aloud so it fires once per loaded product, not on
  /// every notify (votes and other updates also trigger the listener).
  bool _hasSpokenVerdict = false;

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(9, (_) => GlobalKey());
  int _activeSectionIndex = 0;

  static const List<Map<String, dynamic>> _sectionNavItems = [
    {'title': 'Uygunluk', 'icon': Icons.shield_outlined},
    {'title': 'Kimlik', 'icon': Icons.qr_code_rounded},
    {'title': 'Riskler', 'icon': Icons.warning_amber_rounded},
    {'title': 'Diyet', 'icon': Icons.eco_outlined},
    {'title': 'Sağlık', 'icon': Icons.favorite_outline_rounded},
    {'title': 'Besin Değerleri', 'icon': Icons.restaurant_outlined},
    {'title': 'Diğer Alerjenler', 'icon': Icons.bug_report_outlined},
    {'title': 'İçindekiler', 'icon': Icons.list_alt_rounded},
    {'title': 'Öneriler', 'icon': Icons.thumb_up_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = ProductDetailViewModel(
      ref.read(explanationRepositoryProvider),
    );
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialLoaded) {
      _isInitialLoaded = true;
      _loadFromRouteArguments();
    }
  }

  void _scrollToSection(int index) {
    setState(() {
      _activeSectionIndex = index;
    });

    final targetContext = _sectionKeys[index].currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.05,
      );
    }
  }

  Widget _buildSectionNavBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _sectionNavItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = _sectionNavItems[index];
          final isActive = _activeSectionIndex == index;

          return InkWell(
            onTap: () => _scrollToSection(index),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF26B384)
                    : (isDark ? Colors.white10 : const Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 14,
                    color: isActive
                        ? Colors.white
                        : (isDark ? Colors.grey.shade300 : AkilliSepetColors.textSecondary),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item['title'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive
                          ? Colors.white
                          : (isDark ? Colors.grey.shade300 : AkilliSepetColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Loads the screen from the route argument, which is either a ready
  /// [ProductFetchResult] or a barcode to fetch. "Tekrar Dene" reuses this.
  void _loadFromRouteArguments() {
    _hasSpokenVerdict = false;
    final args = ModalRoute.of(context)?.settings.arguments;
    final profileRepo = ref.read(profileRepositoryProvider);

    if (args is ProductFetchResult) {
      _scannedBarcode = args.product?.barcode;
      _viewModel.loadFromFetchResult(args, profileRepo);
    } else if (args is String) {
      _scannedBarcode = args;
      _viewModel.loadFromBarcode(
        args,
        ref.read(productRepositoryProvider),
        profileRepo,
      );
    } else {
      // No barcode or result to work with: show "not found" instead of fake data.
      _scannedBarcode = null;
      _viewModel.setStatusFromFetch('not_found');
    }
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    setState(() {});
    _maybeSpeakVerdict();
  }

  /// Reads the verdict aloud once the product is loaded, if the accessibility
  /// toggle is on. Pending/safe/conflict ordering lives in [buildVerdictSpeech].
  void _maybeSpeakVerdict() {
    if (_hasSpokenVerdict) return;
    if (_viewModel.status != ProductDetailStatus.found) return;
    if (!ref.read(readAloudViewModelProvider).isEnabled) return;

    final product = _viewModel.product;
    final explanation = _viewModel.explanation;
    if (product == null || explanation == null) return;

    _hasSpokenVerdict = true;
    final segments = buildVerdictSpeech(
      l10n: AppLocalizations.of(context),
      product: product,
      explanation: explanation,
      rule: _viewModel.ruleEngineResult,
      profile: _viewModel.userProfile,
    );
    _speakSegments(segments);
  }

  /// Speaks the ingredients list on demand ("Read Details" button).
  void _speakIngredients() {
    final product = _viewModel.product;
    if (product == null) return;
    final text = buildIngredientsSpeech(
      l10n: AppLocalizations.of(context),
      product: product,
      localeName: _localeName(),
    );
    _speakSegments([text]);
  }

  Future<void> _speakSegments(List<String> segments) async {
    final tts = ref.read(ttsServiceProvider);
    final localeName = _localeName();
    await tts.stop();
    for (final segment in segments) {
      await tts.speak(segment, localeName: localeName);
    }
  }

  String _localeName() => Localizations.localeOf(context).languageCode;

  @override
  void dispose() {
    ref.read(ttsServiceProvider).stop();
    _scrollController.dispose();
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AkilliSepetColors.background,
      appBar: AppBar(
        backgroundColor: AkilliSepetColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.productDetailTitle),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (_viewModel.status) {
      case ProductDetailStatus.loading:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AkilliSepetColors.primary),
              const SizedBox(height: 16),
              Text(
                l10n.loadingProductAnalysis,
                style: const TextStyle(color: AkilliSepetColors.textSecondary),
              ),
            ],
          ),
        );

      case ProductDetailStatus.error:
        return _buildErrorState(context);

      case ProductDetailStatus.notFound:
        return _buildNotFoundState(context);

      case ProductDetailStatus.found:
      case ProductDetailStatus.partial:
        final product = _viewModel.product;
        final explanation = _viewModel.explanation;

        if (product == null || explanation == null) {
          return _buildNotFoundState(context);
        }

        final insufficient =
            _viewModel.ruleEngineResult?.hasSufficientData == false;

        return Column(
          children: [
            // Sticky Quick Section Navigation Bar
            _buildSectionNavBar(),

            // Main single scroll content with 9 sequential sections
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. UYGUNLUK (Warning / Verdict Banner)
                    KeyedSubtree(
                      key: _sectionKeys[0],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WarningBanner(
                            explanation: explanation,
                            insufficientData: insufficient,
                            reason: personalReasonSpans(
                              l10n: l10n,
                              explanation: explanation,
                              rule: _viewModel.ruleEngineResult,
                              profile: _viewModel.userProfile,
                            ),
                            reasonLines: personalReasonLines(
                              l10n: l10n,
                              rule: _viewModel.ruleEngineResult,
                              profile: _viewModel.userProfile,
                            ),
                          ),
                          if (insufficient) ...[
                            const SizedBox(height: 16),
                            _buildReportButton(context, product.barcode),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. KİMLİK (Product Identity & Verification Voting)
                    KeyedSubtree(
                      key: _sectionKeys[1],
                      child: ProductHeaderCard(
                        product: product,
                        upvotes: _viewModel.upvotesCount,
                        downvotes: _viewModel.downvotesCount,
                        userVote: _viewModel.userVote,
                        onVoteApprove: _viewModel.voteApprove,
                        onVoteReject: _viewModel.voteReject,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. RİSKLER (Personal Risks Section)
                    KeyedSubtree(
                      key: _sectionKeys[2],
                      child: PersonalRisksSection(
                        ruleEngineResult: _viewModel.ruleEngineResult,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. DİYET (Diet Preference Checks)
                    KeyedSubtree(
                      key: _sectionKeys[3],
                      child: ProfileCheckSection(
                        title: l10n.dietType,
                        icon: Icons.eco_outlined,
                        checks: dietChecks(
                          l10n,
                          _viewModel.userProfile,
                          _viewModel.ruleEngineResult,
                        ),
                        emptyMessage: l10n.noDietPreference,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 5. SAĞLIK (Health Conditions Checks + kural motorunun
                    // tanımadığı özel durumlar için genel bilgi kartı)
                    Builder(builder: (context) {
                      final checks = healthChecks(
                        l10n,
                        _viewModel.userProfile,
                        _viewModel.ruleEngineResult,
                      );
                      // level == null: kural motorunun sözlüğünde olmayan,
                      // dolayısıyla "değerlendirilemedi" dönen özel durumlar.
                      // Sadece bunlar için genel bilgi kartı gösteriyoruz —
                      // kural motorunun gerçek karar verdiği durumlar zaten
                      // ProfileCheckSection'da net biçimde görünüyor.
                      final unrecognized =
                          checks.where((c) => c.level == null).toList();

                      return KeyedSubtree(
                        key: _sectionKeys[4],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProfileCheckSection(
                              title: l10n.healthConditionTitle,
                              icon: Icons.favorite_outline_rounded,
                              checks: checks,
                              emptyMessage: l10n.noHealthCondition,
                            ),
                            for (final check in unrecognized) ...[
                              const SizedBox(height: 12),
                              HealthConditionInfoCard(
                                conditionName: check.label,
                                infoText:
                                    '"${check.label}" durumu için kural motorumuzda henüz özel bir eşik tanımlı değil, bu yüzden bu ürünü bu duruma göre değerlendiremiyoruz. Tüketmeden önce ambalaj etiketini kontrol et ve doktoruna danış.',
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    // 6. BESİN DEĞERLERİ (Nutritional Values Card)
                    KeyedSubtree(
                      key: _sectionKeys[5],
                      child: NutrimentsCard(
                        nutriments: product.nutriments,
                        dietNote: explanation.dietNote,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 7. DİĞER ALERJENLER (Other Allergens Section)
                    KeyedSubtree(
                      key: _sectionKeys[6],
                      child: OtherAllergensSection(
                        product: product,
                        ruleEngineResult: _viewModel.ruleEngineResult,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 8. İÇİNDEKİLER (Ingredients & Additives)
                    KeyedSubtree(
                      key: _sectionKeys[7],
                      child: IngredientsSection(
                        product: product,
                        additivesDetails: _viewModel.additivesDetails,
                      ),
                    ),
                    if (ref.watch(readAloudViewModelProvider).isEnabled) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          // Detail screen stays light in both themes; force a
                          // dark foreground so the label is not invisible in
                          // dark mode over the light background.
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AkilliSepetColors.textPrimary,
                          ),
                          onPressed: _speakIngredients,
                          icon: const Icon(Icons.volume_up_rounded),
                          label: Text(l10n.readAloudDetailsButton),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // 9. ÖNERİLER (Recommendations)
                    KeyedSubtree(
                      key: _sectionKeys[8],
                      child: RecommendationsSection(
                        alternatives: _viewModel.alternatives,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Ürün Karşılaştırma Aksiyon Butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref
                              .read(productComparisonViewModelProvider)
                              .initializeWithProducts([product]);
                          Navigator.pushNamed(
                            context,
                            AppRoutes.productComparison,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AkilliSepetColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.compare_arrows_rounded),
                        label: const Text(
                          'Bu Ürünü Başka Bir Ürünle Karşılaştır',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
    }
  }

  /// Same destination as the "not found" flow: lets the user report a product
  /// whose data is missing so it can be completed.
  Widget _buildReportButton(BuildContext context, String barcode) {
    // The app theme forces buttons to full width (Size.fromHeight = infinite
    // width). Override it here so the button hugs its label: one line, centred,
    // and safe at any screen size — no fixed fraction that could clip.
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.pendingProduct,
          arguments: barcode,
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.add_a_photo_outlined, size: 18),
        label: Text(AppLocalizations.of(context).reportToUs, maxLines: 1),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 52,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).errorOccurred,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AkilliSepetColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).productDetailServerError,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AkilliSepetColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context).goBack),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _loadFromRouteArguments,
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context).tryAgain),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final barcodeText = _scannedBarcode ?? '—';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF0F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: Color(0xFFFFB84D),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.barcodeLabel(barcodeText),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.productNotFoundTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AkilliSepetColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.productNotFoundBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AkilliSepetColors.textSecondary,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () => _showManualBarcodeDialog(context),
                child: Text(l10n.enterBarcodeManually),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.pendingProduct,
                    arguments: barcodeText,
                  );
                },
                child: Text(l10n.reportToUs),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  _viewModel.loadMockState('pending');
                },
                child: Text(l10n.sampleProductDemo),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showManualBarcodeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.enterBarcode),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: l10n.barcodeHintExample,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.loadMockState('green');
            },
            child: Text(l10n.searchAction),
          ),
        ],
      ),
    );
  }
}
