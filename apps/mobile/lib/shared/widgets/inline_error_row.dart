import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Inline save error with a retry action, shown above the primary button.
/// Replaces the previous SnackBar so the message stays visible until the save
/// succeeds or the user dismisses it.
class InlineErrorRow extends StatelessWidget {
  const InlineErrorRow({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: AppColors.warning,
          ),
          const SizedBox(width: 10),
          // Uzun mesaj sığmazsa buton yerine metin sarılsın.
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.warning),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.warning,
              textStyle: AppTextStyles.button,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Tekrar dene'),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppColors.warning,
            visualDensity: VisualDensity.compact,
            tooltip: 'Kapat',
          ),
        ],
      ),
    );
  }
}
