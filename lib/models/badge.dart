class UserBadge {
  final String badgeId;
  final DateTime unlockedAt;

  UserBadge({
    required this.badgeId,
    required this.unlockedAt,
  });

  factory UserBadge.fromMap(Map<String, dynamic> map) {
    return UserBadge(
      badgeId: map['badge_id'] as String,
      unlockedAt: DateTime.fromMillisecondsSinceEpoch(map['unlocked_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'badge_id': badgeId,
      'unlocked_at': unlockedAt.millisecondsSinceEpoch,
    };
  }
}

class BadgeDefinition {
  final String id;
  final String title;
  final String description;
  final String iconPath; // For simple usage, can be emoji or asset path

  const BadgeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
  });
}

// Pre-defined badges
const List<BadgeDefinition> availableBadges = [
  BadgeDefinition(
    id: 'first_expense',
    title: 'First Step',
    description: 'Logged your very first expense.',
    iconPath: '🌱',
  ),
  BadgeDefinition(
    id: 'three_day_streak',
    title: 'On a Roll',
    description: 'Logged expenses for 3 consecutive days.',
    iconPath: '🔥',
  ),
  BadgeDefinition(
    id: 'seven_day_streak',
    title: 'Habit Builder',
    description: 'Logged expenses for 7 consecutive days.',
    iconPath: '🗓️',
  ),
  BadgeDefinition(
    id: 'saver',
    title: 'Saver',
    description: 'Added your first budget.',
    iconPath: '💰',
  ),
  BadgeDefinition(
    id: 'spender_100',
    title: 'Big Spender',
    description: 'Spent over 100 in a single transaction.',
    iconPath: '💸',
  ),
];
