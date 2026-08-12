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
            // The badge repeats the avatar's own action: it is the affordance
            // that says the photo is editable at all.
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
                // Flexible: a long name must not push the pencil icon off-screen.
                Flexible(
                  child: Text(
                    name.isEmpty ? 'Adını ekle' : name,
                    style: AppTextStyles.profileName,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email ?? 'E-posta bulunamadı',
          style: AppTextStyles.profileEmail,
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
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(
              Icons.edit_rounded,
              size: ProfileHeader._badgeIconSize,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
