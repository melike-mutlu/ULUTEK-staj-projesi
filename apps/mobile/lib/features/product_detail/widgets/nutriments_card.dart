import 'package:flutter/material.dart';

import '../../../core/models/explanation.dart';
import '../../../core/models/product.dart';
import '../../../core/theme/akilli_sepet_colors.dart';
import 'detail_row.dart';
import 'detail_section.dart';
import 'section_note.dart';

typedef _ValueOf = double? Function(Nutriments nutriments);
typedef _Notes = ({String ok, String caution, String warning});

const String _iconDir = 'assets/nutritional_values';

double? _energy(Nutriments n) => n.energyKcal100g;
double? _sugars(Nutriments n) => n.sugars100g;
double? _fat(Nutriments n) => n.fat100g;
double? _proteins(Nutriments n) => n.proteins100g;

/// One nutrient row: where the value comes from, when it turns yellow/red and
/// how that reads in plain Turkish. Thresholds are per 100 g and live only
/// here — adding a nutrient is a single entry.
class _Nutrient {
  const _Nutrient({
    required this.label,
    required this.unit,
    required this.asset,
    required this.iconSize,
    required this.valueOf,
    required this.low,
    required this.high,
    required this.notes,
    this.decimals = 1,
    this.higherIsBetter = false,
  });

  final String label;
  final String unit;

  /// Icon file under assets/nutritional_values/ and its rendered size — the
  /// drawings have different paddings, so each one is tuned separately.
  final String asset;
  final double iconSize;
  final _ValueOf valueOf;

  /// At or below [low] the value is good; above [high] it is bad.
  final double low;
  final double high;
  final _Notes notes;
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

  String noteFor(WarningLevel level) => switch (level) {
        WarningLevel.ok => notes.ok,
        WarningLevel.caution => notes.caution,
        WarningLevel.warning => notes.warning,
      };

  String format(double value) => '${value.toStringAsFixed(decimals)} $unit';
}

const List<_Nutrient> _nutrients = <_Nutrient>[
  _Nutrient(
    label: 'Enerji',
    unit: 'kcal',
    asset: '$_iconDir/energy.png',
    iconSize: 34,
    valueOf: _energy,
    low: 150,
    high: 350,
    decimals: 0,
    notes: (
      ok: 'Düşük kalorili',
      caution: 'Orta kalorili',
      warning: 'Yüksek kalorili'
    ),
  ),
  _Nutrient(
    label: 'Şeker',
    unit: 'g',
    asset: '$_iconDir/sugar.png',
    iconSize: 37,
    valueOf: _sugars,
    low: 5,
    high: 22.5,
    notes: (
      ok: 'Az şekerli',
      caution: 'Orta düzeyde şekerli',
      warning: 'Çok şekerli'
    ),
  ),
  _Nutrient(
    label: 'Yağ',
    unit: 'g',
    asset: '$_iconDir/oil.png',
    iconSize: 40,
    valueOf: _fat,
    low: 3,
    high: 17.5,
    notes: (
      ok: 'Az yağlı',
      caution: 'Orta düzeyde yağlı',
      warning: 'Çok yağlı'
    ),
  ),
  _Nutrient(
    label: 'Protein',
    unit: 'g',
    asset: '$_iconDir/protein.png',
    iconSize: 62,
    valueOf: _proteins,
    low: 4,
    high: 8,
    higherIsBetter: true,
    notes: (
      ok: 'Protein açısından zengin',
      caution: 'Bir miktar protein',
      warning: 'Çok az protein'
    ),
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
    final note = dietNote?.trim();

    return DetailSection(
      title: 'Besin değerleri',
      meta: '100 g için',
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
    final amount = value;
    final level = amount == null ? null : nutrient.levelFor(amount);

    return DetailRow(
      leading: _NutrientIcon(asset: nutrient.asset, size: nutrient.iconSize),
      title: nutrient.label,
      // Without a value there is nothing to judge, so no note and no dot.
      subtitle: level == null ? 'Bilgi yok' : nutrient.noteFor(level),
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
