import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// İki katmanlı yuvarlak ilerleme çubuğu: boş zemin + dolu kısım.
/// [progress] (0–1) değişince dolu kısım [AnimatedFractionallySizedBox] ile
/// 280ms'de kayar.
class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({super.key, required this.progress});

  static const double height = 6;
  static const Duration _duration = Duration(milliseconds: 280);

  /// 0–1 arası ilerleme oranı.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Container(
        height: height,
        color: AppColors.onboardingProgressTrack,
        alignment: Alignment.centerLeft,
        child: AnimatedFractionallySizedBox(
          duration: _duration,
          curve: Curves.easeOutCubic,
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          heightFactor: 1.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.onboardingProgressFill,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
      ),
    );
  }
}
