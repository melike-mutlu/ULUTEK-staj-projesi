import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/providers.dart';
import '../../core/theme/akilli_sepet_colors.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/profile_repository.dart';
import 'product_detail_viewmodel.dart';
import 'profile_checks.dart';
import 'widgets/ingredients_section.dart';
import 'widgets/nutriments_card.dart';
import 'widgets/other_allergens_section.dart';
import 'widgets/personal_risks_section.dart';
import 'widgets/profile_check_section.dart';
import 'widgets/product_header_card.dart';
import 'widgets/warning_banner.dart';

class ProductDetailView extends ConsumerStatefulWidget {
  const ProductDetailView({super.key});

  @override
  ConsumerState<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends ConsumerState<ProductDetailView> {
  late final ProductDetailViewModel _viewModel;
  bool _isInitialLoaded = false;
  String? _scannedBarcode;

  @override
  void initState() {
    super.initState();
    _viewModel = ProductDetailViewModel(ref.read(explanationRepositoryProvider));
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

  /// Loads the screen from the route argument, which is either a ready
  /// [ProductFetchResult] or a barcode to fetch. "Tekrar Dene" reuses this.
  void _loadFromRouteArguments() {
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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AkilliSepetColors.background,
      appBar: AppBar(
        backgroundColor: AkilliSepetColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ürün Detayı'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_viewModel.status) {
      case ProductDetailStatus.loading:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AkilliSepetColors.primary),
              SizedBox(height: 16),
              Text(
                'Ürün bilgileri ve AI analizi getiriliyor...',
                style: TextStyle(color: AkilliSepetColors.textSecondary),
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
        final nutrimentsCard = NutrimentsCard(
          nutriments: product.nutriments,
          dietNote: explanation.dietNote,
        );
        // Only worth surfacing early if there is actually something to show.
        final showNutrimentsFirst = insufficient && product.nutriments.hasAny;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Uygunluk sonucu — ekranın görsel çıpası
              WarningBanner(
                explanation: explanation,
                insufficientData: insufficient,
                reason: personalReasonSpans(
                  explanation: explanation,
                  rule: _viewModel.ruleEngineResult,
                  profile: _viewModel.userProfile,
                ),
                reasonLines: personalReasonLines(
                  rule: _viewModel.ruleEngineResult,
                  profile: _viewModel.userProfile,
                ),
              ),
              // Veri eksikse kullanıcı ürünü bize bildirerek katkı yapabilir.
              if (insufficient) ...[
                const SizedBox(height: 16),
                _buildReportButton(context, product.barcode),
              ],
              const SizedBox(height: 14),

              // 2. Ürün kimliği (görsel + ad + marka)
              ProductHeaderCard(product: product),
              const SizedBox(height: 32),

              // Veri eksik ama besin değerleri varsa, kullanıcı hiç değilse
              // onları görsün diye kimliğin hemen altına alınır.
              if (showNutrimentsFirst) nutrimentsCard,

              // 3-6. Profil kategorileri: alerji, diyet, sağlık
              PersonalRisksSection(
                ruleEngineResult: _viewModel.ruleEngineResult,
              ),
              ProfileCheckSection(
                title: 'Diyet türü',
                icon: Icons.eco_outlined,
                checks: dietChecks(
                  _viewModel.userProfile,
                  _viewModel.ruleEngineResult,
                ),
                emptyMessage: 'Kayıtlı bir diyet tercihin yok.',
              ),
              ProfileCheckSection(
                title: 'Sağlık durumu',
                icon: Icons.favorite_outline_rounded,
                checks: healthChecks(
                  _viewModel.userProfile,
                  _viewModel.ruleEngineResult,
                ),
                emptyMessage: 'Kayıtlı bir sağlık durumun yok.',
              ),
              if (!showNutrimentsFirst) nutrimentsCard,

              // 7-8. Ürünün kendi bilgileri
              OtherAllergensSection(
                product: product,
                ruleEngineResult: _viewModel.ruleEngineResult,
              ),
              IngredientsSection(product: product),
              const SizedBox(height: 24),
            ],
          ),
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
        label: const Text('Ürünü Bize Bildir', maxLines: 1),
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
              'Bir Hata Oluştu',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AkilliSepetColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _viewModel.errorMessage ??
                  'Ürün detayları yüklenirken sunucu ile iletişim kurulamadı.',
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
                  child: const Text('Geri Dön'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _loadFromRouteArguments,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
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
                    'Barkod: $barcodeText',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bu ürünü veritabanımızda\nbulamadık',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AkilliSepetColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Yanlış bilgi vermektense dürüst olmayı tercih ederiz. Barkodu elle girebilir ya da ürünü bize bildirerek yardımcı olabilirsin.',
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
                child: const Text('Barkodu Elle Gir'),
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
                child: const Text('Ürünü Bize Bildir'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  _viewModel.loadMockState('green');
                },
                child: const Text('Örnek Ürünü Göster (Demo)'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showManualBarcodeDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Barkodu Girin'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Örn: 8690504112233',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.loadMockState('green');
            },
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }
}
