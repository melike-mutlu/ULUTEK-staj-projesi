import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Profile header: centered photo + name + email.
///
/// The email is real (from the Supabase session). Name and photo are UI-only
/// for now: the pencil icons are present but wired to nothing — deliberately
/// inert, not tappable buttons.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.email, this.name});

  /// Email from the session; a placeholder is shown when absent.
  final String? email;

  // TODO(backend): needs a display_name column on profiles. Once it exists
  // this can be fed from ProfileViewModel and become saveable.
  final String? name;

  static const double _avatarRadius = 44;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            const CircleAvatar(
              radius: _avatarRadius,
              backgroundColor: AppColors.surfaceMuted,
              child: Icon(
                Icons.person_rounded,
                size: 48,
                color: AppColors.textSecondary,
              ),
            ),
            // TODO(backend): needs an avatar_url column + a storage bucket.
            // Once both exist this badge opens the photo picker.
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Flexible: a long name must not push the pencil icon off-screen.
            Flexible(
              child: Text(
                name ?? 'Adını ekle',
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
