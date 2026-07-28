import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_text_styles.dart';
import '../onboarding_steps.dart' as onboarding_steps;

/// Karşılama adımı: SVG görsel + başlık + açıklama, `step.skipLabel` varsa
/// sağ üstte bir "Skip" linki.
///
/// Sabit ekran boyutu varsayılmaz: görsel `Expanded` + `FittedBox` ile
/// küçük ekranda küçülür, metin bloğu `Flexible` ile kırpılmaz.
class OnboardingWelcomeStep extends StatelessWidget {
  const OnboardingWelcomeStep({super.key, required this.step, this.onSkip});

  final onboarding_steps.OnboardingWelcomeStep step;

  /// `step.skipLabel` null değilse çağrılır.
  final VoidCallback? onSkip;

  /// Figma (node 0:3): görsel alt kenarı ile başlık üstü arası.
  static const double _imageTitleGap = 76;

  /// Figma (node 0:3 / 1:2): başlık alt kenarı ile açıklama üstü arası.
  static const double _titleBodyGap = 24;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: step.contentTopOffset),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Transform.translate(
                  offset: Offset(0, step.imageTopOffset),
                  child: ClipRect(
                    child: Transform.scale(
                      scale: step.imageScale,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SvgPicture.asset(step.assetPath),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: _imageTitleGap),
              Flexible(
                child: Transform.translate(
                  offset: Offset(0, step.textTopOffset),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        step.title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.onboardingWelcomeTitle,
                      ),
                      const SizedBox(height: _titleBodyGap),
                      Text(
                        step.body,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.onboardingWelcomeBody,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (step.skipLabel != null)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onSkip,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  step.skipLabel!,
                  style: AppTextStyles.onboardingSkipLabel,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
