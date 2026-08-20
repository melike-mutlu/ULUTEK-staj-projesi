import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../profile_stats_viewmodel.dart';
import 'stat_tile.dart';

/// A small three-tile dashboard on the profile screen: distinct products,
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
          child: StatTile(
            icon: Icons.qr_code_scanner_rounded,
            value: stats.distinctProducts,
            label: l10n.statDistinctProducts,
          ),
        ),
        const SizedBox(width: _tileGap),
        Expanded(
          child: StatTile(
            icon: Icons.verified_user_outlined,
            value: stats.avoidedAllergens,
            label: l10n.statAvoidedAllergens,
          ),
        ),
        const SizedBox(width: _tileGap),
        Expanded(
          child: StatTile(
            icon: Icons.calendar_today_rounded,
            value: stats.daysSinceSignup,
            label: l10n.statMemberDays,
          ),
        ),
      ],
    );
  }
}
