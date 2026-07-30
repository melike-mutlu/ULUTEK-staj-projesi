import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import 'onboarding_steps.dart' as onboarding_steps;
import 'onboarding_viewmodel.dart';
import 'widgets/onboarding_primary_button.dart';
import 'widgets/onboarding_progress_bar.dart';
import 'widgets/onboarding_selection_step.dart';
import 'widgets/onboarding_welcome_step.dart';

/// Onboarding akışının kabuğu: 2 karşılama + 3 seçim ekranı.
///
/// İki farklı navigasyon bilinçli olarak ayrılmıştır:
///  - **Karşılama ekranları** (0-1) kendi controller'ı olan izole bir
///    [_WelcomePager] içinde yaşar → parmak-takipli doğal kaydırma. Bu
///    PageView yalnızca 2 sayfa içerdiği için "2. ekrandan ileri kaydırma
///    yok, geri kaydırma var" kuralı doğal sınır olarak bedava gelir.
///  - **Seçim ekranları** (2-4) yalnızca butonla/geri okuyla gezilir.
///
/// Gövde her zaman `ViewModel.currentIndex`'ten türetilir; PageController ile
/// programatik `animateToPage` karışımı (state ↔ ekran ayrışmasına yol açan
/// eski hata) hiçbir yerde yoktur. Karşılama ve seçim blokları arası geçiş
/// [AnimatedSwitcher] slide'ı ile yapılır.
class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  /// Onboarding tamamlandığında çağrılır: alt navigasyon kabuğuna geçilir.
  /// `pushReplacement` çünkü kullanıcı geri tuşuyla onboarding'e dönmemeli.
  static void completeOnboarding(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.shell);
  }

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  static const double _horizontalPadding = 20;
  static const double _backArrowSize = 22;
  static const double _backArrowGap = 16;
  static const double _contentMaxWidth = 520;
  static const Duration _pageTransition = Duration(milliseconds: 280);

  /// Seçim ekranlarında progress bar satırının üstten kaydırması.
  static const double _progressBarTopInset = 10;

  /// Progress bar ile alttaki soru kutusu arası boşluk.
  static const double _progressToQuestionGap = 20;

  /// Soru kutusunun sol kenarını progress bar'ın sol kenarıyla hizalamak için
  /// eklenen inset. Progress bar, satırdaki geri oku ([_backArrowSize]) ve
  /// aradaki boşluk ([_backArrowGap]) kadar içeriden başlar; soru kutusuna da
  /// aynı miktar sol boşluk verilir.
  static const double _questionLeftInset = _backArrowSize + _backArrowGap;

  /// En son çizilen adım — karşılama↔seçim geçiş animasyonunun yönünü
  /// belirlemek için tutulur.
  int _lastIndex = 0;

  /// true → yeni blok sağdan girer (ileri), false → soldan girer (geri).
  bool _slideForward = true;

  @override
  void initState() {
    super.initState();
    _lastIndex = ref.read(onboardingViewModelProvider).currentIndex;
  }

  Future<void> _handlePrimaryPressed(OnboardingViewModel viewModel) async {
    if (!viewModel.isLastStep) {
      viewModel.goNext();
      return;
    }

    final success = await viewModel.submit();
    if (!mounted) return;
    if (success) {
      OnboardingView.completeOnboarding(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Profil kaydedilemedi.'),
        ),
      );
    }
  }

  /// Seçim ekranının gövdesi (soru kartı + çipler).
  Widget _buildSelectionBody(
    OnboardingViewModel viewModel,
    onboarding_steps.OnboardingSelectionStep step,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: OnboardingSelectionStep(
            step: step,
            options: viewModel.optionsFor(step.field),
            selections: viewModel.selectionsFor(step.field),
            questionLeftInset: _questionLeftInset,
            onToggle: (String option) =>
                viewModel.toggleOption(step.field, option),
            onAddCustom: (String option) =>
                viewModel.addCustomOption(step.field, option),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(onboardingViewModelProvider);

    final int currentIndex = viewModel.currentIndex;
    _slideForward = currentIndex >= _lastIndex;
    _lastIndex = currentIndex;

    final currentStep = viewModel.currentStep;
    final bool isSelectionStep =
        currentStep is onboarding_steps.OnboardingSelectionStep;
    final bool isWelcomeStep =
        currentStep is onboarding_steps.OnboardingWelcomeStep;
    final bool hasSelection = currentStep is onboarding_steps.OnboardingSelectionStep &&
        viewModel.selectionsFor(currentStep.field).isNotEmpty;
    final bool showSkipIcon = isSelectionStep && !hasSelection;

    final welcomeSteps = onboarding_steps.onboardingSteps
        .whereType<onboarding_steps.OnboardingWelcomeStep>()
        .toList();

    // Gövde: karşılama bloğu (izole PageView, tek kimlik) ya da seçim ekranı
    // (adım başına ayrı kimlik). Aynı kimlik boyunca AnimatedSwitcher geçiş
    // yapmaz — karşılama ekranları arası kaydırmayı içerideki PageView yönetir.
    final Widget body;
    final Key bodyKey;
    if (isWelcomeStep) {
      bodyKey = const ValueKey<String>('welcome');
      body = _WelcomePager(
        steps: welcomeSteps,
        initialIndex: welcomeSteps.indexOf(currentStep),
        horizontalPadding: _horizontalPadding,
        contentMaxWidth: _contentMaxWidth,
        onWelcomeIndexChanged: viewModel.goToStep,
        onSkip: viewModel.skipWelcome,
        onPrimaryPressed: () => _handlePrimaryPressed(viewModel),
      );
    } else {
      bodyKey = ValueKey<int>(currentIndex);
      body = _buildSelectionBody(
        viewModel,
        currentStep as onboarding_steps.OnboardingSelectionStep,
      );
    }

    return PopScope(
      canPop: !viewModel.canGoBack,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) viewModel.goBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.onboardingBackground,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              if (isSelectionStep)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    _horizontalPadding,
                    _progressBarTopInset,
                    _horizontalPadding,
                    _progressToQuestionGap,
                  ),
                  child: Row(
                    children: <Widget>[
                      if (viewModel.canGoBack)
                        GestureDetector(
                          onTap: viewModel.goBack,
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: _backArrowSize,
                            color: AppColors.textPrimary,
                          ),
                        )
                      else
                        const SizedBox(
                          width: _backArrowSize,
                          height: _backArrowSize,
                        ),
                      const SizedBox(width: _backArrowGap),
                      Expanded(
                        child: OnboardingProgressBar(
                          progress: viewModel.selectionProgress,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: _pageTransition,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    final Tween<Offset> offset = Tween<Offset>(
                      begin: Offset(_slideForward ? 1 : -1, 0),
                      end: Offset.zero,
                    );
                    return SlideTransition(
                      position: animation.drive(offset),
                      child: child,
                    );
                  },
                  child: KeyedSubtree(key: bodyKey, child: body),
                ),
              ),
              // Karşılama ekranlarının butonu artık adımın kendi içeriğinde
              // (bkz. OnboardingWelcomeStep) — sayfayla birlikte kayar. Burada
              // yalnızca seçim ekranlarının alt butonu çizilir.
              if (isSelectionStep)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    _horizontalPadding,
                    0,
                    _horizontalPadding,
                    _horizontalPadding,
                  ),
                  child: OnboardingPrimaryButton(
                    label: viewModel.primaryActionLabel,
                    icon: showSkipIcon
                        ? Icons.check_rounded
                        : Icons.chevron_right_rounded,
                    iconAtEnd: !showSkipIcon,
                    isLoading: viewModel.isSaving,
                    onPressed: () => _handlePrimaryPressed(viewModel),
                  ),
                ),
              if (isWelcomeStep)
                Padding(
                  padding: const EdgeInsets.only(bottom: _horizontalPadding),
                  child: Center(
                    child: _WelcomeDots(
                      count: welcomeSteps.length,
                      activeIndex: welcomeSteps.indexOf(currentStep),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Karşılama ekranlarının izole, parmak-takipli kaydırıcısı.
///
/// Kendi [PageController]'ını tutar; yalnızca [steps] kadar sayfa içerdiği için
/// son karşılama ekranından ileri kaydırılamaz (doğal sınır). Sayfa değişince
/// [onWelcomeIndexChanged] ile dışarıdaki state (dots + "Başlayalım" butonu)
/// senkronlanır. State [OnboardingView] tarafında 'welcome' kimliğiyle
/// korunduğu için 0↔1 kaydırmalarında bu widget yeniden kurulmaz, controller
/// parmağın bıraktığı yerde kalır.
class _WelcomePager extends StatefulWidget {
  const _WelcomePager({
    required this.steps,
    required this.initialIndex,
    required this.horizontalPadding,
    required this.contentMaxWidth,
    required this.onWelcomeIndexChanged,
    required this.onSkip,
    required this.onPrimaryPressed,
  });

  final List<onboarding_steps.OnboardingWelcomeStep> steps;
  final int initialIndex;
  final double horizontalPadding;
  final double contentMaxWidth;
  final ValueChanged<int> onWelcomeIndexChanged;
  final VoidCallback onSkip;
  final VoidCallback onPrimaryPressed;

  @override
  State<_WelcomePager> createState() => _WelcomePagerState();
}

class _WelcomePagerState extends State<_WelcomePager> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      onPageChanged: widget.onWelcomeIndexChanged,
      children: <Widget>[
        for (final onboarding_steps.OnboardingWelcomeStep step in widget.steps)
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: widget.contentMaxWidth),
                child: OnboardingWelcomeStep(
                  step: step,
                  onSkip: widget.onSkip,
                  onPrimaryPressed: widget.onPrimaryPressed,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Karşılama ekranlarının altındaki sayfa göstergesi (Figma: "ProgressDots",
/// 2 nokta — dolu nokta aktif ekranı gösterir, boş nokta sadece kenarlıklı).
class _WelcomeDots extends StatelessWidget {
  const _WelcomeDots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  /// Figma: `r="4.5"` → çap 9.
  static const double _diameter = 9;

  /// Figma: nokta merkezleri arası 18, çap 9 → kenar boşluğu 9.
  static const double _gap = 9;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < count; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: _gap),
          Container(
            width: _diameter,
            height: _diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == activeIndex
                  ? AppColors.onboardingTextPrimary
                  : Colors.transparent,
              border: Border.all(color: AppColors.onboardingTextPrimary),
            ),
          ),
        ],
      ],
    );
  }
}
