import 'profile_stats.dart';

/// Milestones a user can unlock. UI-free: the view maps each id to its icon and
/// localized label, keeping this layer testable and backend-independent.
enum AchievementId {
  firstScan,
  tenProducts,
  fiftyProducts,
  hundredProducts,
  weekStreak,
  monthMember,
}

/// A single milestone and whether the user has reached it.
class Achievement {
  const Achievement({required this.id, required this.unlocked});

  final AchievementId id;
  final bool unlocked;
}

/// Derives the milestone list from [stats], in display order. Each threshold
/// notes which [ProfileStats] field it reads so tests stay unambiguous.
List<Achievement> deriveAchievements(ProfileStats stats) {
  return <Achievement>[
    // distinctProducts >= 1
    Achievement(
      id: AchievementId.firstScan,
      unlocked: stats.distinctProducts >= 1,
    ),
    // distinctProducts >= 10
    Achievement(
      id: AchievementId.tenProducts,
      unlocked: stats.distinctProducts >= 10,
    ),
    // distinctProducts >= 50
    Achievement(
      id: AchievementId.fiftyProducts,
      unlocked: stats.distinctProducts >= 50,
    ),
    // distinctProducts >= 100
    Achievement(
      id: AchievementId.hundredProducts,
      unlocked: stats.distinctProducts >= 100,
    ),
    // currentStreak >= 7
    Achievement(
      id: AchievementId.weekStreak,
      unlocked: stats.currentStreak >= 7,
    ),
    // daysSinceSignup >= 30
    Achievement(
      id: AchievementId.monthMember,
      unlocked: stats.daysSinceSignup >= 30,
    ),
  ];
}
