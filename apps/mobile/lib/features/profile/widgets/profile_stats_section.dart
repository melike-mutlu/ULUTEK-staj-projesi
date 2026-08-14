import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../profile_stats_viewmodel.dart';

/// A small three-tile dashboard on the profile screen: scanned products,
/// avoided allergens, and days since signup. Self-contained — drop it in and it
/// loads its own data.
class ProfileStatsSection extends ConsumerStatefulWidget {
  const ProfileStatsSection({super.key});

  @override
  ConsumerState<ProfileStatsSection> createState() =>
      _ProfileStatsSectionState();
}

class _ProfileStatsSectionState extends ConsumerState<ProfileStatsSection> {
  static const double _tileGap = 12;

  @override
  void initState() {
    super.initState();
    // Deferred to the next frame: load() notifies synchronously and that must
    // not land mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(profileStatsViewModelProvider).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(profileStatsViewModelProvider);
    final stats = viewModel.stats;
    final l10n = AppLocalizations.of(context);

    // Non-critical section: while nothing has loaded yet, and if loading fails,
    // it takes no space.
    if (stats == null) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: _StatTile(
            icon: Icons.qr_code_scanner_rounded,
            value: stats.scannedProducts,
            label: l10n.statScannedProducts,
          ),
        ),
        const SizedBox(width: _tileGap),
        Expanded(
          child: _StatTile(
            icon: Icons.verified_user_outlined,
            value: stats.avoidedAllergens,
            label: l10n.statAvoidedAllergens,
          ),
        ),
        const SizedBox(width: _tileGap),
        Expanded(
          child: _StatTile(
            icon: Icons.calendar_today_rounded,
            value: stats.daysSinceSignup,
            label: l10n.statMemberDays,
          ),
        ),
      ],
    );
  }
}

/// One metric tile: icon, value, and a wrapping label.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 22, color: AppColors.brand),
          const SizedBox(height: 8),
          Text('$value', style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
