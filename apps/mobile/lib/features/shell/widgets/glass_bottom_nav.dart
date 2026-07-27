import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../shell_viewmodel.dart';

/// Ekranın altında yüzen kapsül (pill) biçimli alt navigasyon barı.
///
/// Kenarlardan margin'li, tam yuvarlak, yarı saydam; arkasındaki içerik hafif
/// blur'lanır (glassmorphism).
///
/// Aktif sekme göstergesi tek bir highlight'tır: sekmeler arasında kayar,
/// boyutu her sekmede aynıdır (sekme genişliğine göre hesaplanır, etiket
/// uzunluğundan etkilenmez).
///
/// Bar içeriğin ÜSTÜNDE yüzdüğü için sekme ekranlarının altında yer ayrılması
/// gerekir — bunu [reservedHeight] üzerinden `ShellView` hallediyor.
class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  /// Kapsülün yüksekliği. Tam yuvarlak köşe için yarıçap bunun yarısı.
  static const double barHeight = 74;

  /// Kapsülün ekran kenarlarından boşluğu.
  static const double horizontalMargin = 16;
  static const double bottomMargin = 2;

  /// Blur şiddeti — bilinçli olarak hafif tutuldu, arkadaki içerik seçilebilsin.
  static const double blurSigma = 12;

  /// Sekme ekranlarının altında bırakılması gereken boşluk: içerik barın
  /// arkasında kalmasın diye. Sistem güvenli alanı buna ayrıca eklenir.
  static const double reservedHeight = barHeight + bottomMargin;

  /// Kayan highlight'ın ölçüleri. Genişliği sekme genişliğinden bu kadar dar.
  static const double _indicatorInset = 6;
  static const double _indicatorHeight = barHeight - 12;

  /// Sekme ikonunun boyutu — bar yüksekliğiyle orantılı.
  static const double _iconSize = 26;

  /// Highlight'ın kayma ve renklerin geçiş süresi.
  static const Duration _motionDuration = Duration(milliseconds: 320);

  final ShellTab currentTab;
  final ValueChanged<ShellTab> onTabSelected;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(
      tab: ShellTab.dashboard,
      label: 'Ana Sayfa',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _NavItem(
      tab: ShellTab.scan,
      label: 'Tara',
      icon: Icons.qr_code_scanner_outlined,
      activeIcon: Icons.qr_code_scanner_rounded,
    ),
    _NavItem(
      tab: ShellTab.home,
      label: 'Geçmiş',
      icon: Icons.history_outlined,
      activeIcon: Icons.history_rounded,
    ),
    _NavItem(
      tab: ShellTab.profile,
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(barHeight / 2);
    final selectedIndex =
        _items.indexWhere((_NavItem item) => item.tab == currentTab);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          horizontalMargin,
          0,
          horizontalMargin,
          bottomMargin,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: AppColors.glassShadow,
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(
                height: barHeight,
                decoration: BoxDecoration(
                  color: AppColors.glassSurface,
                  borderRadius: borderRadius,
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final slotWidth = constraints.maxWidth / _items.length;
                    final indicatorWidth = slotWidth - _indicatorInset * 2;

                    return Stack(
                      children: <Widget>[
                        // Tek highlight, sekmeler arasında kayar.
                        AnimatedPositioned(
                          duration: _motionDuration,
                          curve: Curves.easeOutCubic,
                          left: selectedIndex * slotWidth + _indicatorInset,
                          top: (barHeight - _indicatorHeight) / 2,
                          width: indicatorWidth,
                          height: _indicatorHeight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.navIndicator,
                              // Barla aynı yarıçap; gösterge bardan alçak
                              // olduğu için Flutter bunu tam kapsüle kırpar,
                              // yani barın yuvarlaklığıyla uyumlu durur.
                              borderRadius: borderRadius,
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            for (final _NavItem item in _items)
                              Expanded(
                                child: _NavButton(
                                  item: item,
                                  isSelected: item.tab == currentTab,
                                  duration: _motionDuration,
                                  iconSize: _iconSize,
                                  onTap: () => onTabSelected(item.tab),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.tab,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final ShellTab tab;
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Tek sekme. Kendi arka planını çizmez — highlight barın altında ayrı bir
/// katman olarak kayar. Burada sadece ikon/etiket rengi ve ikonun dolu/boş
/// hâli yumuşakça geçiş yapar.
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.duration,
    required this.iconSize,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final Duration duration;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: isSelected ? 1 : 0),
          duration: duration,
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, double t, Widget? child) {
            final color = Color.lerp(
              AppColors.navUnselected,
              AppColors.navSelected,
              t,
            )!;

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Boş ve dolu ikon üst üste; seçim ilerledikçe çapraz geçiş.
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Opacity(
                        opacity: 1 - t,
                        child: Icon(item.icon, size: iconSize, color: color),
                      ),
                      Opacity(
                        opacity: t,
                        child: Icon(
                          item.activeIcon,
                          size: iconSize,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: AppTextStyles.navLabel.copyWith(color: color),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
