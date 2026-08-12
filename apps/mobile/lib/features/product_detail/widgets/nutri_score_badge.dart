import 'package:flutter/material.dart';

/// Nutri-Score letter badge (A–E) with the official grade colours.
///
/// Shared by the product header and the recommendation cards so the grade looks
/// identical everywhere. Renders nothing for an unknown or empty [grade].
class NutriScoreBadge extends StatelessWidget {
  const NutriScoreBadge({super.key, required this.grade});

  /// Nutri-Score letter, case-insensitive (e.g. "A", "e").
  final String grade;

  static const Color _fallback = Color(0xFF9CA3AF);
  static const Map<String, Color> _gradeColors = {
    'A': Color(0xFF038141),
    'B': Color(0xFF85BB2F),
    'C': Color(0xFFFECB02),
    'D': Color(0xFFEE8100),
    'E': Color(0xFFE63E11),
  };

  /// Grade colour for [grade], or a neutral grey when it is unknown.
  static Color colorFor(String grade) =>
      _gradeColors[grade.trim().toUpperCase()] ?? _fallback;

  @override
  Widget build(BuildContext context) {
    final normalized = grade.trim().toUpperCase();
    if (normalized.isEmpty) return const SizedBox.shrink();

    final color = colorFor(normalized);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(
        'Nutri-Score $normalized',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
