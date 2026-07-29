import 'package:flutter/material.dart';
import '../../../core/models/product.dart';

/// 100g için besin değerlerini (Kalori, Şeker, Yağ, Protein, Tuz) gösteren kart.
class NutrimentsCard extends StatelessWidget {
  const NutrimentsCard({super.key, required this.nutriments});

  final Nutriments nutriments;

  Widget _buildNutrientItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required double? amount,
    required double maxRef,
  }) {
    final double percentage = amount != null ? (amount / maxRef).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: const Color(0xFFE5E7EB),
              color: color,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kcal = nutriments.energyKcal100g;
    final sugars = nutriments.sugars100g;
    final fat = nutriments.fat100g;
    final proteins = nutriments.proteins100g;
    final salt = nutriments.salt100g;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_outline_rounded, color: Color(0xFF26B384)),
              SizedBox(width: 8),
              Text(
                'Besin Değerleri (100g için)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildNutrientItem(
                label: 'Enerji / Kalori',
                value: kcal != null ? '${kcal.toStringAsFixed(0)} kcal' : '-',
                icon: Icons.local_fire_department_rounded,
                color: const Color(0xFFEF4444),
                amount: kcal,
                maxRef: 800,
              ),
              _buildNutrientItem(
                label: 'Şeker',
                value: sugars != null ? '${sugars.toStringAsFixed(1)} g' : '-',
                icon: Icons.cookie_rounded,
                color: const Color(0xFFF59E0B),
                amount: sugars,
                maxRef: 50,
              ),
              _buildNutrientItem(
                label: 'Yağ',
                value: fat != null ? '${fat.toStringAsFixed(1)} g' : '-',
                icon: Icons.water_drop_rounded,
                color: const Color(0xFF3B82F6),
                amount: fat,
                maxRef: 40,
              ),
              _buildNutrientItem(
                label: 'Protein',
                value: proteins != null ? '${proteins.toStringAsFixed(1)} g' : '-',
                icon: Icons.fitness_center_rounded,
                color: const Color(0xFF10B981),
                amount: proteins,
                maxRef: 30,
              ),
            ],
          ),
          if (salt != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.grain_rounded, size: 16, color: Color(0xFF6B7280)),
                      SizedBox(width: 6),
                      Text(
                        'Tuz İçeriği',
                        style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                      ),
                    ],
                  ),
                  Text(
                    '${salt.toStringAsFixed(2)} g',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
