import 'package:flutter/material.dart';

import '../models/explanation.dart';

/// Visual identity of a [WarningLevel]: colors, icon and short label.
///
/// Single source of truth — the product detail verdict, scan history and any
/// future list share it instead of repeating their own colour switches.
class WarningLevelStyle {
  const WarningLevelStyle({
    required this.main,
    required this.background,
    required this.border,
    required this.icon,
    required this.title,
  });

  /// Text, icon and accent colour.
  final Color main;
  final Color background;
  final Color border;
  final IconData icon;

  /// Short verdict shown to the user, e.g. "Uygun değil".
  final String title;

  static const WarningLevelStyle warning = WarningLevelStyle(
    main: Color(0xFFDC2626),
    background: Color(0xFFFEF2F2),
    border: Color(0xFFFCA5A5),
    icon: Icons.gpp_bad_rounded,
    title: 'Uygun değil',
  );

  static const WarningLevelStyle caution = WarningLevelStyle(
    main: Color(0xFFD97706),
    background: Color(0xFFFFFBEB),
    border: Color(0xFFFDE68A),
    icon: Icons.report_problem_rounded,
    title: 'Dikkatli ol',
  );

  static const WarningLevelStyle ok = WarningLevelStyle(
    main: Color(0xFF16A34A),
    background: Color(0xFFF0FDF4),
    border: Color(0xFF86EFAC),
    icon: Icons.verified_user_rounded,
    title: 'Sana uygun',
  );

  static WarningLevelStyle of(WarningLevel level) => switch (level) {
        WarningLevel.warning => warning,
        WarningLevel.caution => caution,
        WarningLevel.ok => ok,
      };
}
