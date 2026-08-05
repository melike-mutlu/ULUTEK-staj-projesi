import 'package:flutter/material.dart';

import '../../../core/models/explanation.dart';
import '../../../core/theme/akilli_sepet_colors.dart';
import '../../../core/theme/warning_level_style.dart';
import '../profile_checks.dart';
import 'status_dot.dart';

/// Verdict — the anchor of the screen: the level on the left, the short verdict
/// and the personal reason on the right. No box: the colour alone carries it.
class WarningBanner extends StatelessWidget {
  const WarningBanner({super.key, required this.explanation, this.reason});

  final Explanation explanation;

  /// Personal warning composed from the profile; falls back to the backend
  /// explanation when the caller has none.
  final List<ReasonSpan>? reason;

  /// Sits next to the verdict when the product is suitable.
  static const String _starIcon = 'assets/other/star.png';
  static const double _starSize = 52;

  /// The illustration spans the title and the reason standing next to it.
  static const double _iconSize = 130;

  /// How far the illustration reaches past the text's left edge.
  static const double _iconInset = 12;

  bool get _isSuitable => explanation.level == WarningLevel.ok;

  List<ReasonSpan> get _reason {
    final personal = reason;
    if (personal != null && personal.isNotEmpty) return personal;
    return [
      ReasonSpan(explanation.warningMessage.isNotEmpty
          ? explanation.warningMessage
          : explanation.summary),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
              errorBuilder: (_, __, ___) =>
                  StatusDot(level: explanation.level, size: 20),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 13),
            child: StatusDot(level: explanation.level, size: 20),
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
                        style.title,
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
                Text.rich(
                  TextSpan(
                    children: [
                      for (final span in _reason)
                        TextSpan(
                          text: span.text,
                          // Words taken from the user's own profile stand out.
                          style: span.highlight
                              ? TextStyle(
                                  color: style.main,
                                  fontWeight: FontWeight.w600,
                                )
                              : null,
                        ),
                    ],
                  ),
                  style: const TextStyle(
                    color: AkilliSepetColors.textSecondary,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                if (explanation.disclaimer.isNotEmpty) ...[
                  // One blank line, then the disclaimer right under the reason.
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
                          explanation.disclaimer,
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
