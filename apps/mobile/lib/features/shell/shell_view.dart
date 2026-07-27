import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../dashboard/dashboard_view.dart';
import '../home/home_view.dart';
import '../profile/profile_view.dart';
import '../scan/scan_view.dart';
import 'shell_viewmodel.dart';
import 'widgets/glass_bottom_nav.dart';

/// Uygulamanın alt navigasyon kabuğu: 4 sekmeyi barındırır ve yüzen kapsül
/// barı çizer. Onboarding tamamlandıktan sonra girilen ana ekran budur.
///
/// Sekmeler arasında hem bardaki sekmeye dokunarak hem de ekranı yatay
/// kaydırarak geçilir. Sayfalar canlı tutulur ([_KeepAlivePage]); sekme
/// değişince ekranlar yeniden kurulmaz, kendi state'lerini (scroll konumu,
/// form girdisi vb.) korur.
class ShellView extends ConsumerStatefulWidget {
  const ShellView({super.key});

  @override
  ConsumerState<ShellView> createState() => _ShellViewState();
}

class _ShellViewState extends ConsumerState<ShellView> {
  late final PageController _pageController;

  /// Bara dokunulduğunda sayfanın kayma süresi. Gösterge sayfayı takip ettiği
  /// için barın animasyon süresi de fiilen budur.
  static const Duration _pageTransition = Duration(milliseconds: 320);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: ref.read(shellViewModelProvider).currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Bardaki sekmeye dokunuldu.
  void _onTabSelected(ShellTab tab) {
    ref.read(shellViewModelProvider).selectTab(tab);
    _pageController.animateToPage(
      tab.index,
      duration: _pageTransition,
      curve: Curves.easeOutCubic,
    );
  }

  /// Kaydırma sonucu sayfa değişti.
  void _onPageChanged(int index) {
    ref.read(shellViewModelProvider).selectTab(ShellTab.values[index]);
  }

  /// Göstergenin duracağı yer: sayfa kaydıkça kesirli ilerler, böylece bar
  /// parmağı anlık takip eder. Sayfa henüz bağlanmadıysa açılış sekmesi.
  double get _indicatorPosition {
    if (_pageController.hasClients && _pageController.position.hasPixels) {
      return _pageController.page ?? _pageController.initialPage.toDouble();
    }
    return _pageController.initialPage.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(shellViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      // Bar içeriğin üstünde yüzsün diye gövde bar alanına kadar uzatılır.
      extendBody: true,
      body: _TabContentInset(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: const <Widget>[
            _KeepAlivePage(child: DashboardView()),
            _KeepAlivePage(child: ScanView()),
            _KeepAlivePage(child: HomeView()),
            _KeepAlivePage(child: ProfileView()),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _pageController,
        builder: (BuildContext context, Widget? child) {
          return GlassBottomNav(
            currentTab: viewModel.currentTab,
            indicatorPosition: _indicatorPosition,
            onTabSelected: _onTabSelected,
          );
        },
      ),
    );
  }
}

/// Sekme ekranını canlı tutar: [PageView] varsayılan olarak görünmeyen
/// sayfaları atar, biz `IndexedStack`'teki gibi state'in korunmasını istiyoruz.
class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({required this.child});

  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Sekme ekranlarına, yüzen barın kapladığı kadar alt boşluk tanıtır.
///
/// Boşluğu ekranlara tek tek `Padding` olarak dağıtmak yerine [MediaQuery]'nin
/// alt güvenli alanına eklenir: sekme ekranları içeriğini `SafeArea` ile ya da
/// `MediaQuery.of(context).padding.bottom` okuyarak sarmaladığında (liste
/// `padding`'i, son buton vb.) içerik barın arkasında kalmaz.
class _TabContentInset extends StatelessWidget {
  const _TabContentInset({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    const extra = GlassBottomNav.reservedHeight;

    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: mediaQuery.padding.copyWith(
          bottom: mediaQuery.padding.bottom + extra,
        ),
        viewPadding: mediaQuery.viewPadding.copyWith(
          bottom: mediaQuery.viewPadding.bottom + extra,
        ),
      ),
      child: child,
    );
  }
}
