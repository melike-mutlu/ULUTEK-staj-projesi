import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
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
/// Göstergenin yeri [indicatorPosition] ile dışarıdan sürülür; kesirli
/// değerler kabul eder, böylece kullanıcı ekranı kaydırırken bar parmağı
/// anlık takip eder (bkz. `ShellView`).
///
/// Bar içeriğin ÜSTÜNDE yüzdüğü için sekme ekranlarının altında yer ayrılması
/// gerekir; bunu Scaffold `extendBody` ile kendisi yapıyor (bkz. `ShellView`).
class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    super.key,
    required this.currentTab,
    required this.indicatorPosition,
    required this.onTabSelected,
  });

  /// Kapsülün yüksekliği. Tam yuvarlak köşe için yarıçap bunun yarısı.
  static const double barHeight = 68;

  /// Kapsülün ekran kenarlarından boşluğu.
  static const double horizontalMargin = 16;

  /// Alt boşluk sistemin güvenli alanına EKLENİR. Negatif olması barın güvenli
  /// alanın içine doğru bu kadar sarkması demek; sonuç sıfırın altına inmez.
  static const double bottomMargin = -3;

  /// Blur şiddeti — bilinçli olarak hafif tutuldu, arkadaki içerik seçilebilsin.
  static const double blurSigma = 12;

  /// Göstergenin bardan HER YÖNDE eşit boşluğu.
  ///
  /// Eşit olması şart: bar tam kapsül (yarıçap = yükseklik / 2) olduğu için,
  /// her yönden eşit boşluklu bir iç kapsülün yarıçapı kendiliğinden
  /// `barYarıçapı - boşluk` çıkar; yani iki şekil eşmerkezli olur. Yatay ve
  /// dikey boşluk farklı olursa köşe eğrileri barınkiyle uyuşmaz.
  static const double _indicatorInset = 4;
  static const double _indicatorHeight = barHeight - _indicatorInset * 2;

  /// = barHeight / 2 - _indicatorInset (bkz. yukarıdaki not).
  static const double _indicatorRadius = _indicatorHeight / 2;

  /// Sekme ikonunun boyutu — bar yüksekliğiyle orantılı.
  static const double _iconSize = 26;

  final ShellTab currentTab;

  /// Göstergenin sekme cinsinden konumu (0 = ilk sekme). Kaydırma sırasında
  /// ara değerler alır, örneğin 1.4.
  final double indicatorPosition;

  final ValueChanged<ShellTab> onTabSelected;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(
      tab: ShellTab.home,
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _NavItem(
      tab: ShellTab.scan,
      icon: Icons.qr_code_scanner_outlined,
      activeIcon: Icons.qr_code_scanner_rounded,
    ),
    _NavItem(
      tab: ShellTab.chatbot,
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
    ),
    _NavItem(
      tab: ShellTab.profile,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  /// Localized label for a tab; kept next to [_items] so both stay in sync.
  static String _labelFor(AppLocalizations l10n, ShellTab tab) {
    switch (tab) {
      case ShellTab.home:
        return l10n.navHome;
      case ShellTab.scan:
        return l10n.scanButton;
      case ShellTab.chatbot:
        return l10n.navChatbot;
      case ShellTab.profile:
        return l10n.profileTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(barHeight / 2);
    final position = indicatorPosition.clamp(0.0, _items.length - 1.0);

    final glassSurface = isDark ? AppColors.darkGlassSurface : AppColors.glassSurface;
    final glassBorder = isDark ? AppColors.darkGlassBorder : AppColors.glassBorder;
    final navIndicator = isDark ? AppColors.brand.withOpacity(0.25) : AppColors.navIndicator;

    // SafeArea yerine elle hesap: bottomMargin negatif olabildiği için barın
    // güvenli alana bir miktar sarkmasına izin veriyoruz, ama ekranın dışına
    // taşmasına değil.
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final bottomInset = math.max(0.0, safeBottom + bottomMargin);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalMargin,
        0,
        horizontalMargin,
        bottomInset,
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
                color: glassSurface,
                borderRadius: borderRadius,
                border: Border.all(color: glassBorder),
              ),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final slotWidth = constraints.maxWidth / _items.length;
                  final indicatorWidth = slotWidth - _indicatorInset * 2;

                  return Stack(
                    children: <Widget>[
                      Positioned(
                        left: position * slotWidth + _indicatorInset,
                        top: (barHeight - _indicatorHeight) / 2,
                        width: indicatorWidth,
                        height: _indicatorHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: navIndicator,
                            borderRadius: BorderRadius.circular(
                              _indicatorRadius,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          for (int i = 0; i < _items.length; i++)
                            Expanded(
                              child: _NavButton(
                                item: _items[i],
                                label: _labelFor(l10n, _items[i].tab),
                                isSelected: _items[i].tab == currentTab,
                                selection:
                                    (1 - (position - i).abs()).clamp(0.0, 1.0),
                                iconSize: _iconSize,
                                onTap: () => onTabSelected(_items[i].tab),
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
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.tab,
    required this.icon,
    required this.activeIcon,
  });

  final ShellTab tab;
  final IconData icon;
  final IconData activeIcon;
}

/// Tek sekme. Kendi arka planını çizmez — highlight barın altında ayrı bir
/// katman olarak kayar. Burada ikon/etiket rengi ve ikonun dolu/boş hâli
/// [selection] değerine göre geçiş yapar.
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.label,
    required this.isSelected,
    required this.selection,
    required this.iconSize,
    required this.onTap,
  });

  final _NavItem item;
  final String label;

  /// Erişilebilirlik için kesin durum.
  final bool isSelected;

  /// 0 = tamamen seçili değil, 1 = tamamen seçili. Kaydırma sırasında ara
  /// değerler alır; renkler ve ikon geçişi bunu izler.
  final double selection;

  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor = isDark ? AppColors.darkTextSecondary : AppColors.navUnselected;
    final selectedColor = isDark ? AppColors.brand : AppColors.navSelected;

    final color = Color.lerp(
      unselectedColor,
      selectedColor,
      selection,
    )!;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Boş ve dolu ikon üst üste; seçim ilerledikçe çapraz geçiş.
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Opacity(
                    opacity: 1 - selection,
                    child: Icon(item.icon, size: iconSize, color: color),
                  ),
                  Opacity(
                    opacity: selection,
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
                label,
                style: AppTextStyles.navLabel.copyWith(color: color),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
