import 'package:flutter/material.dart';

import '../../../core/models/explanation.dart';
import '../../../core/models/product.dart';
import 'detail_section.dart';
import 'status_dot.dart';

typedef _ValueOf = double? Function(Nutriments nutriments);

double? _energy(Nutriments n) => n.energyKcal100g;
double? _sugars(Nutriments n) => n.sugars100g;
double? _fat(Nutriments n) => n.fat100g;
double? _carbohydrates(Nutriments n) => n.carbohydrates100g;
double? _proteins(Nutriments n) => n.proteins100g;

/// One nutrient row: where its value comes from and when it turns yellow/red.
/// Thresholds are per 100 g and live only here — adding a nutrient is one entry.
class _Nutrient {
  const _Nutrient({
    required this.label,
    required this.unit,
    required this.valueOf,
    required this.low,
    required this.high,
    this.decimals = 1,
    this.higherIsBetter = false,
  });

  final String label;
  final String unit;
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
    label: 'Enerji',
    unit: 'kcal',
    valueOf: _energy,
    low: 150,
    high: 350,
    decimals: 0,
  ),
  _Nutrient(label: 'Şeker', unit: 'g', valueOf: _sugars, low: 5, high: 22.5),
  _Nutrient(label: 'Yağ', unit: 'g', valueOf: _fat, low: 3, high: 17.5),
  _Nutrient(
    label: 'Karbonhidrat',
    unit: 'g',
    valueOf: _carbohydrates,
    low: 20,
    high: 50,
  ),
  _Nutrient(
    label: 'Protein',
    unit: 'g',
    valueOf: _proteins,
    low: 4,
    high: 8,
    higherIsBetter: true,
  ),
];

/// Nutrition facts as plain rows: name, value and a status dot.
class NutrimentsCard extends StatelessWidget {
  const NutrimentsCard({
    super.key,
    required this.nutriments,
    this.dietNote,
  });

  final Nutriments nutriments;

  /// Explanation.dietNote — shown only when it carries real information.
  final String? dietNote;

  @override
  Widget build(BuildContext context) {
    final note = dietNote?.trim();

    return DetailSection(
      title: 'Besin değerleri',
      subtitle: '100 g için',
      child: Column(
        children: [
          for (final nutrient in _nutrients)
            _NutrientRow(
              nutrient: nutrient,
              value: nutrient.valueOf(nutriments),
            ),
          if (note != null && note.isNotEmpty) _DietNoteRow(note: note),
        ],
      ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              nutrient.label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount == null ? '—' : nutrient.format(amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: amount == null
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF111827),
            ),
          ),
          const SizedBox(width: 10),
          // No dot without a value: an unknown nutrient is not a verdict.
          SizedBox(
            width: 10,
            child: amount == null
                ? null
                : StatusDot(level: nutrient.levelFor(amount)),
          ),
        ],
      ),
    );
  }
}

class _DietNoteRow extends StatelessWidget {
  const _DietNoteRow({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.eco_outlined, size: 16, color: Color(0xFF16A34A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
