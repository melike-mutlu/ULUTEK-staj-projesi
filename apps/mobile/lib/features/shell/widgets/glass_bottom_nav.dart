import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../shell_viewmodel.dart';

/// Ekranın altında yüzen kapsül (pill) biçimli alt navigasyon barı.
///
/// Kenarlardan margin'li, tam yuvarlak, yarı saydam; arkasındaki içerik hafif
/// blur'lanır (glassmorphism). Aktif sekmenin arkasında soft pill highlight var.
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
  static const double barHeight = 62;

  /// Kapsülün ekran kenarlarından boşluğu.
  static const double horizontalMargin = 16;
  static const double bottomMargin = 12;

  /// Blur şiddeti — bilinçli olarak hafif tutuldu, arkadaki içerik seçilebilsin.
  static const double blurSigma = 12;

  /// Sekme ekranlarının altında bırakılması gereken boşluk: içerik barın
  /// arkasında kalmasın diye. Sistem güvenli alanı buna ayrıca eklenir.
  static const double reservedHeight = barHeight + bottomMargin;

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
                child: Row(
                  children: <Widget>[
                    for (final item in _items)
                      Expanded(
                        child: _NavButton(
                          item: item,
                          isSelected: item.tab == currentTab,
                          onTap: () => onTabSelected(item.tab),
                        ),
                      ),
                  ],
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

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? AppColors.navSelected : AppColors.navUnselected;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: InkResponse(
        onTap: onTap,
        radius: 48,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.navIndicator : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 22,
                  color: color,
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
          ),
        ),
      ),
    );
  }
}
