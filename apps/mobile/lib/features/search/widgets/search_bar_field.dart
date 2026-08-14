import 'package:flutter/material.dart';

import '../../../core/theme/akilli_sepet_colors.dart';
import '../../../l10n/app_localizations.dart';

/// iOS-style rounded search field: a light grey pill with a leading magnifier,
/// a hint, and a trailing clear button once text is entered.
///
/// Purely presentational and reusable — all state (text, debounce, results)
/// lives in the caller's view model.
class SearchBarField extends StatelessWidget {
  const SearchBarField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.hintText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  /// Falls back to the localized "search products" hint when not provided.
  final String? hintText;

  static const Color _fill = Color(0xFFE5E5EA);

  @override
  Widget build(BuildContext context) {
    final resolvedHint = hintText ?? AppLocalizations.of(context).searchProductHint;
    return Container(
      decoration: BoxDecoration(
        color: _fill,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontSize: 17,
          color: AkilliSepetColors.textPrimary,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          prefixIcon: const Icon(
            Icons.search,
            color: AkilliSepetColors.textSecondary,
            size: 22,
          ),
          // Show the clear button only when there is something to clear.
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(
                  Icons.cancel,
                  color: AkilliSepetColors.textSecondary,
                  size: 20,
                ),
                splashRadius: 20,
                onPressed: () {
                  controller.clear();
                  onClear?.call();
                },
              );
            },
          ),
          hintText: resolvedHint,
          hintStyle: const TextStyle(
            fontSize: 17,
            color: AkilliSepetColors.textSecondary,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}
