import 'package:flutter/material.dart';

import '../profile_checks.dart';
import 'detail_row.dart';
import 'detail_section.dart';
import 'section_note.dart';

/// Renders one profile category ("Diyet türü", "Sağlık durumu") as rows.
/// When the user has nothing saved in that category, a single quiet line
/// explains why the section is empty instead of leaving a blank block.
class ProfileCheckSection extends StatelessWidget {
  const ProfileCheckSection({
    super.key,
    required this.title,
    required this.icon,
    required this.checks,
    required this.emptyMessage,
  });

  final String title;
  final IconData icon;
  final List<ProfileCheck> checks;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return DetailSection(
      title: title,
      children: checks.isEmpty
          ? [SectionNote(text: emptyMessage)]
          : [
              for (final check in checks)
                DetailRow(
                  leading: Icon(icon, size: 34, color: const Color(0xFF6B7280)),
                  title: check.label,
                  subtitle: check.note,
                  level: check.level,
                ),
            ],
    );
  }
}
