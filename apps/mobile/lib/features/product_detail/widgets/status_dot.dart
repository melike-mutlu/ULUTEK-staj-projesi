import 'package:flutter/material.dart';

import '../../../core/models/explanation.dart';
import '../../../core/theme/warning_level_style.dart';

/// Small coloured dot marking the status of a row. Uses the same level colours
/// as the verdict banner, so red always means the same thing on this screen.
class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.level, this.size = 10});

  final WarningLevel level;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: WarningLevelStyle.of(level).main,
        shape: BoxShape.circle,
      ),
    );
  }
}
