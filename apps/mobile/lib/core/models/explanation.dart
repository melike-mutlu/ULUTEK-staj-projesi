enum WarningLevel { ok, caution, warning }

WarningLevel _levelFromString(String value) {
  switch (value) {
    case 'warning':
      return WarningLevel.warning;
    case 'caution':
      return WarningLevel.caution;
    default:
      return WarningLevel.ok;
  }
}

/// docs/architecture.md — Sözleşme 2 (`explain-product`) yanıtı.
class Explanation {
  final String summary;
  final WarningLevel level;
  final String warningMessage;
  final String? dietNote;

  /// Legacy field kept only for backend/JSON compatibility; the UI now renders
  /// a localized disclaimer instead of this text (see WarningBanner).
  final String disclaimer;

  const Explanation({
    required this.summary,
    required this.level,
    required this.warningMessage,
    this.dietNote,
    this.disclaimer = '',
  });

  factory Explanation.fromJson(Map<String, dynamic> json) {
    final personalWarning =
        json['personal_warning'] as Map<String, dynamic>? ?? {};
    return Explanation(
      summary: json['summary'] as String? ?? '',
      level: _levelFromString(personalWarning['level'] as String? ?? 'ok'),
      warningMessage: personalWarning['message'] as String? ?? '',
      dietNote: json['diet_note'] as String?,
      disclaimer: json['disclaimer'] as String? ?? '',
    );
  }
}
