import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/question_card.dart';
import '../onboarding_steps.dart' as onboarding_steps;

/// Popular country recommendations for quick selection.
const List<String> _popularCountries = <String>[
  'Türkiye',
  'Almanya',
  'İngiltere',
  'ABD',
  'Hollanda',
  'Fransa',
];

/// Onboarding ülke-seçimi adımı widget'ı (isim adımıyla aynı desende).
class OnboardingCountryStep extends StatefulWidget {
  const OnboardingCountryStep({
    super.key,
    required this.step,
    required this.country,
    required this.onCountryChanged,
    this.questionLeftInset = 0,
  });

  final onboarding_steps.OnboardingCountryStep step;
  final String country;
  final ValueChanged<String> onCountryChanged;
  final double questionLeftInset;

  @override
  State<OnboardingCountryStep> createState() => _OnboardingCountryStepState();
}

class _OnboardingCountryStepState extends State<OnboardingCountryStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.country);
  }

  @override
  void didUpdateWidget(covariant OnboardingCountryStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.country != _controller.text) {
      _controller.text = widget.country;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectCountry(String name) {
    _controller.text = name;
    widget.onCountryChanged(name);
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
                    onChanged: widget.onCountryChanged,
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
                        Icons.public_rounded,
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
                                widget.onCountryChanged('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Popüler Seçenekler',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _popularCountries.map((countryName) {
                    final isSelected =
                        _controller.text.trim().toLowerCase() ==
                            countryName.toLowerCase();
                    return ChoiceChip(
                      label: Text(countryName),
                      selected: isSelected,
                      onSelected: (_) => _selectCountry(countryName),
                      selectedColor: AppColors.brandSoft,
                      backgroundColor: AppColors.onboardingSurface,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.brand
                            : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.brand
                              : AppColors.border,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
