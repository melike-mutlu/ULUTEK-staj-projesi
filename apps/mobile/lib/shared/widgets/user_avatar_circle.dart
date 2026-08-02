import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/akilli_sepet_colors.dart';

/// Circular user avatar: the photo when there is one, otherwise the first
/// letter of [name].
///
/// Shared by the dashboard header, the chatbot header and the profile header,
/// so the photo-and-initial fallback looks the same everywhere. [onTap] is
/// optional so the widget can also be used as a plain, non-interactive avatar.
class UserAvatarCircle extends StatelessWidget {
  const UserAvatarCircle({
    super.key,
    required this.name,
    this.avatarUrl,
    this.size = 48,
    this.onTap,
    this.isLoading = false,
    this.semanticLabel = 'Profil',
  });

  final String? name;

  /// Public URL of the profile photo; null or empty falls back to the initial.
  final String? avatarUrl;

  final double size;
  final VoidCallback? onTap;

  /// Dims the avatar and shows a spinner while a new photo is uploading.
  final bool isLoading;

  /// Announced by screen readers when [onTap] is set.
  final String semanticLabel;

  /// Shown when [name] is empty.
  static const String _fallbackInitial = 'U';

  String get _initial {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return _fallbackInitial;
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = avatarUrl != null && avatarUrl!.isNotEmpty;

    final Widget avatar = SizedBox(
      width: size,
      height: size,
      child: Material(
        color: AkilliSepetColors.primary,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            // Sits under the photo, so a slow or broken image degrades to the
            // initial rather than an empty circle.
            Center(
              // The letter is decorative; the semantic label describes the tap
              // target instead of reading a single character aloud.
              child: ExcludeSemantics(
                child: Text(
                  _initial,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size / 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (hasPhoto)
              Positioned.fill(
                child: Image.network(
                  avatarUrl!,
                  fit: BoxFit.cover,
                  // Falling back to the initial is the intended behaviour, but
                  // a broken URL should not look identical to "no photo set".
                  errorBuilder: (_, Object error, __) {
                    if (kDebugMode) {
                      debugPrint('UserAvatarCircle: $avatarUrl <- $error');
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            if (isLoading)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black26,
                  child: Center(
                    child: SizedBox(
                      width: size / 3,
                      height: size / 3,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            // Last, so the ripple paints above the photo.
            Positioned.fill(
              child: InkWell(onTap: onTap, customBorder: const CircleBorder()),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return avatar;
    return Semantics(button: true, label: semanticLabel, child: avatar);
  }
}
