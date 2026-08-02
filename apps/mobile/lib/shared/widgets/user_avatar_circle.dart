import 'package:flutter/material.dart';

import '../../core/theme/akilli_sepet_colors.dart';

/// Circular user avatar showing the first letter of [name].
///
/// Shared by the dashboard and chatbot headers. [onTap] is optional so the
/// widget can also be used as a plain, non-interactive avatar.
class UserAvatarCircle extends StatelessWidget {
  const UserAvatarCircle({
    super.key,
    required this.name,
    this.size = 48,
    this.onTap,
    this.semanticLabel = 'Profil',
  });

  final String? name;
  final double size;
  final VoidCallback? onTap;

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
    final Widget avatar = Material(
      color: AkilliSepetColors.primary,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
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
        ),
      ),
    );

    if (onTap == null) return avatar;
    return Semantics(button: true, label: semanticLabel, child: avatar);
  }
}
