import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/question_card.dart';
import '../onboarding_steps.dart' as onboarding_steps;

/// Onboarding isim-girişi adımı widget'ı.
class OnboardingNameStep extends StatefulWidget {
  const OnboardingNameStep({
    super.key,
    required this.step,
    required this.displayName,
    required this.onNameChanged,
    this.questionLeftInset = 0,
  });

  final onboarding_steps.OnboardingNameStep step;
  final String displayName;
  final ValueChanged<String> onNameChanged;
  final double questionLeftInset;

  @override
  State<OnboardingNameStep> createState() => _OnboardingNameStepState();
}

class _OnboardingNameStepState extends State<OnboardingNameStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.displayName);
  }

  @override
  void didUpdateWidget(covariant OnboardingNameStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.displayName != _controller.text) {
      _controller.text = widget.displayName;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: widget.questionLeftInset),
                  child: QuestionCard(question: widget.step.title),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    widget.step.subtitle,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.onboardingSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _controller,
                    onChanged: widget.onNameChanged,
                    textCapitalization: TextCapitalization.words,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.step.placeholder,
                      hintStyle: AppTextStyles.title.copyWith(
                        color: AppColors.textSecondary.withAlpha(120),
                      ),
                      border: InputBorder.none,
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.brand,
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                _controller.clear();
                                widget.onNameChanged('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
