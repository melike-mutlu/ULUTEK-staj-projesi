import 'package:flutter/material.dart';

import '../../../core/models/profile_stats.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// A compact 7-day bar chart of scans per day. Bars scale to the busiest day so
/// the shape stays readable at any volume. Height is driven by [AspectRatio], so
/// it flexes with the available width instead of a fixed pixel height.
class WeeklyBreakdownChart extends StatelessWidget {
  const WeeklyBreakdownChart({super.key, required this.days});

  final List<DailyScanCount> days;

  static const double _chartAspectRatio = 1.9;
  static const double _barWidthFactor = 0.5;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor =
        isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted;
    final labelColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final narrowWeekdays = MaterialLocalizations.of(context).narrowWeekdays;
    final maxCount = days.fold<int>(0, (max, d) => d.count > max ? d.count : max);

    return AspectRatio(
      aspectRatio: _chartAspectRatio,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          for (final day in days)
            Expanded(
              child: _Bar(
                // Sunday=0 .. Saturday=6, indexed by DateTime.weekday.
                label: narrowWeekdays[day.day.weekday % 7],
                fraction: maxCount == 0 ? 0 : day.count / maxCount,
                hasScans: day.count > 0,
                trackColor: trackColor,
                labelColor: labelColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.fraction,
    required this.hasScans,
    required this.trackColor,
    required this.labelColor,
  });

  final String label;
  final double fraction;
  final bool hasScans;
  final Color trackColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(6);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: <Widget>[
          Expanded(
            child: FractionallySizedBox(
              widthFactor: WeeklyBreakdownChart._barWidthFactor,
              child: DecoratedBox(
                decoration: BoxDecoration(color: trackColor, borderRadius: radius),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: fraction.clamp(0.0, 1.0),
                    child: hasScans
                        ? DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.brand,
                              borderRadius: radius,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.caption.copyWith(color: labelColor)),
        ],
      ),
    );
  }
}
