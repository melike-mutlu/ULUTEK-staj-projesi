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
/// Sekmeler [IndexedStack] içinde tutulur; sekme değiştirince ekranlar
/// yeniden kurulmaz, kendi state'lerini (scroll konumu, form girdisi vb.) korur.
class ShellView extends ConsumerWidget {
  const ShellView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(shellViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      // Bar içeriğin üstünde yüzsün diye gövde bar alanına kadar uzatılır.
      extendBody: true,
      body: _TabContentInset(
        child: IndexedStack(
          index: viewModel.currentIndex,
          children: const <Widget>[
            DashboardView(),
            ScanView(),
            HomeView(),
            ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: GlassBottomNav(
        currentTab: viewModel.currentTab,
        onTabSelected: viewModel.selectTab,
      ),
    );
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
