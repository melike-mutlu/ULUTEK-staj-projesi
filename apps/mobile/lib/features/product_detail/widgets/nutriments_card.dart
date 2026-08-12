import 'package:flutter/material.dart';

import '../../../core/models/explanation.dart';
import '../../../core/models/product.dart';
import '../../../core/theme/akilli_sepet_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'detail_row.dart';
import 'detail_section.dart';
import 'section_note.dart';

typedef _ValueOf = double? Function(Nutriments nutriments);

const String _iconDir = 'assets/nutritional_values';

/// Localized name for a nutrient by its stable [id].
String _nutrientLabel(AppLocalizations l10n, String id) => switch (id) {
      'energy' => l10n.nutrientEnergy,
      'sugar' => l10n.nutrientSugar,
      'fat' => l10n.nutrientFat,
      _ => l10n.nutrientProtein,
    };

/// Localized plain-language note for a nutrient at a given [level].
String _nutrientNote(AppLocalizations l10n, String id, WarningLevel level) =>
    switch (id) {
      'energy' => switch (level) {
          WarningLevel.ok => l10n.energyLow,
          WarningLevel.caution => l10n.energyMedium,
          WarningLevel.warning => l10n.energyHigh,
        },
      'sugar' => switch (level) {
          WarningLevel.ok => l10n.sugarLow,
          WarningLevel.caution => l10n.sugarMedium,
          WarningLevel.warning => l10n.sugarHigh,
        },
      'fat' => switch (level) {
          WarningLevel.ok => l10n.fatLow,
          WarningLevel.caution => l10n.fatMedium,
          WarningLevel.warning => l10n.fatHigh,
        },
      _ => switch (level) {
          WarningLevel.ok => l10n.proteinHigh,
          WarningLevel.caution => l10n.proteinMedium,
          WarningLevel.warning => l10n.proteinLow,
        },
    };

double? _energy(Nutriments n) => n.energyKcal100g;
double? _sugars(Nutriments n) => n.sugars100g;
double? _fat(Nutriments n) => n.fat100g;
double? _proteins(Nutriments n) => n.proteins100g;

/// One nutrient row: where the value comes from, when it turns yellow/red and
/// how that reads in plain Turkish. Thresholds are per 100 g and live only
/// here — adding a nutrient is a single entry.
class _Nutrient {
  const _Nutrient({
    required this.id,
    required this.unit,
    required this.asset,
    required this.iconSize,
    required this.valueOf,
    required this.low,
    required this.high,
    this.decimals = 1,
    this.higherIsBetter = false,
  });

  /// Stable id used to resolve the localized label and notes.
  final String id;
  final String unit;

  /// Icon file under assets/nutritional_values/ and its rendered size — the
  /// drawings have different paddings, so each one is tuned separately.
  final String asset;
  final double iconSize;
  final _ValueOf valueOf;

  /// At or below [low] the value is good; above [high] it is bad.
  final double low;
  final double high;
  final int decimals;

  /// Protein reads the other way round: more is better.
  final bool higherIsBetter;

  WarningLevel levelFor(double value) {
    if (higherIsBetter) {
      if (value >= high) return WarningLevel.ok;
      return value >= low ? WarningLevel.caution : WarningLevel.warning;
    }
    if (value <= low) return WarningLevel.ok;
    return value <= high ? WarningLevel.caution : WarningLevel.warning;
  }

  String format(double value) => '${value.toStringAsFixed(decimals)} $unit';
}

const List<_Nutrient> _nutrients = <_Nutrient>[
  _Nutrient(
    id: 'energy',
    unit: 'kcal',
    asset: '$_iconDir/energy.png',
    iconSize: 34,
    valueOf: _energy,
    low: 150,
    high: 350,
    decimals: 0,
  ),
  _Nutrient(
    id: 'sugar',
    unit: 'g',
    asset: '$_iconDir/sugar.png',
    iconSize: 37,
    valueOf: _sugars,
    low: 5,
    high: 22.5,
  ),
  _Nutrient(
    id: 'fat',
    unit: 'g',
    asset: '$_iconDir/oil.png',
    iconSize: 40,
    valueOf: _fat,
    low: 3,
    high: 17.5,
  ),
  _Nutrient(
    id: 'protein',
    unit: 'g',
    asset: '$_iconDir/protein.png',
    iconSize: 62,
    valueOf: _proteins,
    low: 4,
    high: 8,
    higherIsBetter: true,
  ),
];

/// Nutrition facts as plain rows: name, plain-language note, value and a dot.
class NutrimentsCard extends StatelessWidget {
  const NutrimentsCard({super.key, required this.nutriments, this.dietNote});

  final Nutriments nutriments;

  /// Explanation.dietNote — shown only when it carries real information.
  final String? dietNote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final note = dietNote?.trim();

    return DetailSection(
      title: l10n.nutrimentsTitle,
      meta: l10n.per100g,
      children: [
        for (final nutrient in _nutrients)
          _NutrientRow(nutrient: nutrient, value: nutrient.valueOf(nutriments)),
        if (note != null && note.isNotEmpty) SectionNote(text: note),
      ],
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow({required this.nutrient, required this.value});

  final _Nutrient nutrient;
  final double? value;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final amount = value;
    final level = amount == null ? null : nutrient.levelFor(amount);

    return DetailRow(
      leading: _NutrientIcon(asset: nutrient.asset, size: nutrient.iconSize),
      title: _nutrientLabel(l10n, nutrient.id),
      // Without a value there is nothing to judge, so no note and no dot.
      subtitle: level == null ? l10n.noInfo : _nutrientNote(l10n, nutrient.id, level),
      value: amount == null ? '—' : nutrient.format(amount),
      level: level,
    );
  }
}

class _NutrientIcon extends StatelessWidget {
  const _NutrientIcon({required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => Icon(
        Icons.restaurant_outlined,
        size: size,
        color: AkilliSepetColors.textSecondary,
      ),
    );
  }
}
