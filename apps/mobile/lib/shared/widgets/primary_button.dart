import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Uygulamanın tek alt buton bileşeni — onboarding karşılama/seçim
/// ekranlarında ve profil formunda aynı widget kullanılır.
///
/// Figma "Onboarding" dosyasındaki buton component'inin (node 1:3) gerçek
/// değerleriyle yazıldı: siyah pill, içeriğe göre genişlik (tam genişlik
/// değil), Nunito Bold 20/22. Tek dosya değiştiği için bu stil hem karşılama
/// hem seçim ekranlarına otomatik yansır.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.iconAtEnd = false,
    this.isLoading = false,
    required this.onPressed,
  });

  final String label;
  final IconData? icon;
  final bool iconAtEnd;
  final bool isLoading;
  final VoidCallback? onPressed;

  /// Figma: `rounded-[100px]` — yükseklikten büyük bir değer verilerek tam
  /// pill/stadyum şekli garanti edilir.
  static const double _radius = 999;

  /// Figma: `px-[32px] py-[16px]`.
  static const EdgeInsets _padding =
      EdgeInsets.symmetric(horizontal: 32, vertical: 16);

  @override
  Widget build(BuildContext context) {
    // isLoading'de buton siyah kalir (spinner tasiyor); asil pasif hal
    // onPressed null oldugunda olusur ve gri gorunur.
    final bool isDisabled = onPressed == null && !isLoading;

    return Center(
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? AppColors.buttonDisabled
              : AppColors.onboardingButtonBackground,
          foregroundColor: AppColors.onboardingButtonText,
          disabledBackgroundColor: isDisabled
              ? AppColors.buttonDisabled
              : AppColors.onboardingButtonBackground,
          disabledForegroundColor: AppColors.onboardingButtonText,
          elevation: 0,
          padding: _padding,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: AppTextStyles.onboardingButtonLabel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.onboardingButtonText,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (icon != null && !iconAtEnd) ...<Widget>[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                  if (icon != null && iconAtEnd) ...<Widget>[
                    const SizedBox(width: 8),
                    Icon(icon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}
