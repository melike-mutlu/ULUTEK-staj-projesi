import 'package:flutter/material.dart';

import '../../../core/models/explanation.dart';
import '../../../core/theme/akilli_sepet_colors.dart';
import '../../../core/theme/warning_level_style.dart';
import '../../../l10n/app_localizations.dart';
import '../explanation_fallbacks.dart';
import '../profile_checks.dart';

/// Verdict — the anchor of the screen: the level on the left, the short verdict
/// and the personal reason on the right. No box: the colour alone carries it.
class WarningBanner extends StatelessWidget {
  const WarningBanner({
    super.key,
    required this.explanation,
    this.reason,
    this.reasonLines,
    this.insufficientData = false,
  });

  final Explanation explanation;

  /// Personal warning composed from the profile; falls back to the backend
  /// explanation when the caller has none.
  final List<ReasonSpan>? reason;

  /// One bullet per conflicting category. When non-empty the reason is shown as
  /// a bulleted list instead of the flat [reason] paragraph.
  final List<List<ReasonSpan>>? reasonLines;

  /// When true the product has no allergen/ingredient data, so the verdict is
  /// "Yetersiz veri" instead of a green/red claim.
  final bool insufficientData;

  /// Sits next to the verdict when the product is suitable.
  static const String _starIcon = 'assets/other/star.png';
  static const double _starSize = 52;

  /// The illustration spans the title and the reason standing next to it.
  static const double _iconSize = 130;

  /// How far the illustration reaches past the text's left edge.
  static const double _iconInset = 12;

  bool get _isSuitable =>
      !insufficientData && explanation.level == WarningLevel.ok;

  List<ReasonSpan> _reasonSpans(AppLocalizations l10n) {
    final personal = reason;
    if (personal != null && personal.isNotEmpty) return personal;
    final text = explanation.warningMessage.isNotEmpty
        ? explanation.warningMessage
        : explanation.summary;
    return [
      ReasonSpan(localizeExplanationFallback(l10n, text)),
    ];
  }

  /// Localized verdict title for a [WarningLevel].
  String _verdictTitle(AppLocalizations l10n, WarningLevel level) =>
      switch (level) {
        WarningLevel.warning => l10n.verdictUnsuitable,
        WarningLevel.caution => l10n.verdictCaution,
        WarningLevel.ok => l10n.verdictSuitable,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (insufficientData) return _buildInsufficient(l10n);

    final style = WarningLevelStyle.of(explanation.level);

    return Row(
      // Top aligned: the verdict starts level with the top of the illustration
      // and every line of text stays to its right, never underneath it.
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (style.asset != null)
          Transform.translate(
            // The png carries transparent padding, so it needs a nudge to sit
            // flush with the screen's left edge.
            offset: const Offset(-_iconInset, 0),
            child: Image.asset(
              style.asset!,
              width: _iconSize,
              height: _iconSize,
              errorBuilder: (_, __, ___) => _Dot(color: style.main),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 13),
            child: _Dot(color: style.main),
          ),
        const SizedBox(width: 2),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _verdictTitle(l10n, explanation.level),
                        style: TextStyle(
                          color: style.main,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    if (_isSuitable) ...[
                      Image.asset(
                        _starIcon,
                        width: _starSize,
                        height: _starSize,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                if (reasonLines != null && reasonLines!.isNotEmpty)
                  for (final line in reasonLines!) _bullet(line, style.main)
                else
                  _reasonText(_reasonSpans(l10n), style.main),
                // Fixed legal notice, always shown under a real verdict.
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 13,
                      color: AkilliSepetColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        l10n.medicalDisclaimerShort,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AkilliSepetColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static const TextStyle _reasonStyle = TextStyle(
    color: AkilliSepetColors.textSecondary,
    fontSize: 16,
    height: 1.4,
  );

  TextSpan _spans(List<ReasonSpan> spans, Color highlight) {
    return TextSpan(
      children: [
        for (final span in spans)
          TextSpan(
            text: span.text,
            // Words taken from the user's own profile stand out.
            style: span.highlight
                ? TextStyle(color: highlight, fontWeight: FontWeight.w600)
                : null,
          ),
      ],
    );
  }

  Widget _reasonText(List<ReasonSpan> spans, Color highlight) {
    return Text.rich(_spans(spans, highlight), style: _reasonStyle);
  }

  /// A single "• …" line; the bullet stays clear of the wrapped text.
  Widget _bullet(List<ReasonSpan> spans, Color highlight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: _reasonStyle),
          Expanded(child: _reasonText(spans, highlight)),
        ],
      ),
    );
  }

  /// No dot, no illustration, no disclaimer — a plain left-aligned notice.
  Widget _buildInsufficient(AppLocalizations l10n) {
    const style = WarningLevelStyle.insufficient;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.verdictInsufficient,
          style: TextStyle(
            color: style.main,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.insufficientContentInfo,
          style: const TextStyle(
            color: AkilliSepetColors.textSecondary,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
