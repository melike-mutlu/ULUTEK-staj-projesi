import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Seçim ekranındaki soruyu beyaz kart içinde gösterir.
///
/// Referanstaki rakun maskotu ve konuşma balonu kuyruğu bilerek yok — düz,
/// tam genişlikte bir kart (bkz. docs/onboarding-plan.md §4b).
class OnboardingQuestionCard extends StatelessWidget {
  const OnboardingQuestionCard({super.key, required this.question});

  static const double _radius = 20;
  static const double _padding = 24;

  final String question;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: AppColors.onboardingSurface,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Text(question, style: AppTextStyles.onboardingQuestion),
    );
  }
}
