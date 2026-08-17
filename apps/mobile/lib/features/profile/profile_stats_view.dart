import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/achievement.dart';
import '../../core/models/profile_stats.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/error_state_view.dart';
import 'profile_stats_viewmodel.dart';
import 'widgets/achievement_badge.dart';
import 'widgets/stat_tile.dart';
import 'widgets/weekly_breakdown_chart.dart';

/// Full stats screen opened from the profile header. Reuses
/// [profileStatsViewModelProvider] so the numbers match the profile tiles, and
/// adds the weekly breakdown and achievements the compact section omits.
class ProfileStatsView extends ConsumerStatefulWidget {
  const ProfileStatsView({super.key});

  @override
  ConsumerState<ProfileStatsView> createState() => _ProfileStatsViewState();
}

class _ProfileStatsViewState extends ConsumerState<ProfileStatsView> {
  static const double _horizontalPadding = 16;
  static const double _contentMaxWidth = 520;
  static const double _sectionGap = 24;
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          l10n.statsTitle,
          style: AppTextStyles.heading2.copyWith(color: textColor),
        ),
      ),
      body: SafeArea(child: _buildBody(viewModel, l10n, textColor)),
    );
  }

  Widget _buildBody(
    ProfileStatsViewModel viewModel,
    AppLocalizations l10n,
    Color textColor,
  ) {
    if (viewModel.loadFailed) {
      return ErrorStateView(
        message: l10n.profileLoadFailed,
        retryLabel: l10n.tryAgain,
        onRetry: viewModel.load,
      );
    }
    if (viewModel.stats == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildContent(viewModel.stats!, l10n, textColor);
  }

  Widget _buildContent(
    ProfileStats stats,
    AppLocalizations l10n,
    Color textColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        8,
        _horizontalPadding,
        24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTiles(stats, l10n),
              const SizedBox(height: _sectionGap),
              _SectionTitle(l10n.statsWeeklyTitle, color: textColor),
              const SizedBox(height: 12),
              _buildWeekly(stats, l10n),
              const SizedBox(height: _sectionGap),
              _SectionTitle(l10n.achievementsTitle, color: textColor),
              const SizedBox(height: 16),
              _buildAchievements(stats, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTiles(ProfileStats stats, AppLocalizations l10n) {
    final tiles = <Widget>[
      StatTile(
        icon: Icons.qr_code_scanner_rounded,
        value: stats.totalScans,
        label: l10n.statTotalScans,
      ),
      StatTile(
        icon: Icons.inventory_2_outlined,
        value: stats.distinctProducts,
        label: l10n.statDistinctProducts,
      ),
      StatTile(
        icon: Icons.local_fire_department_outlined,
        value: stats.currentStreak,
        label: l10n.statStreak,
      ),
      StatTile(
        icon: Icons.verified_user_outlined,
        value: stats.avoidedAllergens,
        label: l10n.statAvoidedAllergens,
      ),
      StatTile(
        icon: Icons.calendar_today_rounded,
        value: stats.daysSinceSignup,
        label: l10n.statMemberDays,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Two columns on phones, three once there is room, so tiles never
        // squeeze below a comfortable width.
        final columns = constraints.maxWidth >= 420 ? 3 : 2;
        final tileWidth =
            (constraints.maxWidth - _tileGap * (columns - 1)) / columns;
        return Wrap(
          spacing: _tileGap,
          runSpacing: _tileGap,
          children: <Widget>[
            for (final tile in tiles)
              SizedBox(width: tileWidth, child: tile),
          ],
        );
      },
    );
  }

  Widget _buildWeekly(ProfileStats stats, AppLocalizations l10n) {
    final hasAny = stats.weeklyBreakdown.any((d) => d.count > 0);
    if (!hasAny) {
      return Text(l10n.statsWeeklyEmpty, style: AppTextStyles.bodyMuted);
    }
    return WeeklyBreakdownChart(days: stats.weeklyBreakdown);
  }

  Widget _buildAchievements(ProfileStats stats, AppLocalizations l10n) {
    final achievements = deriveAchievements(stats);
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 3;
        const gap = 12.0;
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: 20,
          children: <Widget>[
            for (final achievement in achievements)
              AchievementBadge(
                icon: _achievementIcon(achievement.id),
                label: _achievementLabel(l10n, achievement.id),
                unlocked: achievement.unlocked,
                width: itemWidth,
              ),
          ],
        );
      },
    );
  }

  IconData _achievementIcon(AchievementId id) => switch (id) {
        AchievementId.firstScan => Icons.qr_code_scanner_rounded,
        AchievementId.tenProducts => Icons.inventory_2_outlined,
        AchievementId.fiftyProducts => Icons.workspace_premium_outlined,
        AchievementId.hundredProducts => Icons.emoji_events_outlined,
        AchievementId.weekStreak => Icons.local_fire_department_outlined,
        AchievementId.monthMember => Icons.calendar_month_outlined,
      };

  String _achievementLabel(AppLocalizations l10n, AchievementId id) =>
      switch (id) {
        AchievementId.firstScan => l10n.achievementFirstScan,
        AchievementId.tenProducts => l10n.achievementTenProducts,
        AchievementId.fiftyProducts => l10n.achievementFiftyProducts,
        AchievementId.hundredProducts => l10n.achievementHundredProducts,
        AchievementId.weekStreak => l10n.achievementWeekStreak,
        AchievementId.monthMember => l10n.achievementMonthMember,
      };
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.title.copyWith(color: color));
  }
}
