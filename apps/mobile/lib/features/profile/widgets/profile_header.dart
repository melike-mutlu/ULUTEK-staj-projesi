import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/user_avatar_circle.dart';

/// Profile header: centered photo + name + email.
///
/// The photo and its initial fallback come from [UserAvatarCircle], the same
/// widget the dashboard and chatbot headers use, so all three stay consistent.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.isUploadingPhoto = false,
    this.onEditName,
    this.onEditPhoto,
  });

  /// Email from the session; a placeholder is shown when absent.
  final String? email;

  /// Already resolved upstream (chosen name, else email local-part). Empty
  /// only when neither exists, and then the invitation to add one is shown.
  final String name;

  final String? avatarUrl;
  final bool isUploadingPhoto;

  final VoidCallback? onEditName;
  final VoidCallback? onEditPhoto;

  static const double _avatarSize = 88;
  static const double _badgeIconSize = 16;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            UserAvatarCircle(
              name: name,
              avatarUrl: avatarUrl,
              size: _avatarSize,
              isLoading: isUploadingPhoto,
              onTap: onEditPhoto,
              semanticLabel: 'Profil fotoğrafını değiştir',
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: _EditBadge(
                onTap: onEditPhoto,
                tooltip: 'Profil fotoğrafını değiştir',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: onEditName,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    name.isEmpty ? 'Adını ekle' : name,
                    style: AppTextStyles.profileName.copyWith(color: textColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: secondaryTextColor,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email ?? 'E-posta bulunamadı',
          style: AppTextStyles.profileEmail.copyWith(color: secondaryTextColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Small circular pencil badge pinned to the avatar.
class _EditBadge extends StatelessWidget {
  const _EditBadge({required this.onTap, required this.tooltip});

  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Material(
      color: surfaceColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              Icons.edit_rounded,
              size: ProfileHeader._badgeIconSize,
              color: secondaryTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
