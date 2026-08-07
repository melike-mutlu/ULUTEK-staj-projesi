import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Inline, dismissible positive suggestion — the friendly twin of
/// [InlineErrorRow]. Same layout (message + action + close "X") but a neutral,
/// brand-toned surface instead of the error red. Shown above a primary button.
class SuggestionRow extends StatelessWidget {
  const SuggestionRow({
    super.key,
    required this.message,
    required this.onAction,
    required this.onDismiss,
    this.actionLabel = 'Danış',
    this.icon = Icons.chat_bubble_outline_rounded,
  });

  final String message;
  final VoidCallback onAction;
  final VoidCallback onDismiss;
  final String actionLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.brandSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: AppColors.brandDark),
          const SizedBox(width: 10),
          // Uzun mesaj sığmazsa buton yerine metin sarılsın.
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.brandDark),
            ),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brandDark,
              textStyle: AppTextStyles.button,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppColors.brandDark,
            visualDensity: VisualDensity.compact,
            tooltip: 'Kapat',
          ),
        ],
      ),
    );
  }
}
