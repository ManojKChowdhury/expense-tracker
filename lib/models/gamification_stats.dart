class GamificationStats {
  final int points;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastLogDate;
  final String? currentAvatar;

  GamificationStats({
    required this.points,
    required this.currentStreak,
    required this.bestStreak,
    this.lastLogDate,
    this.currentAvatar,
  });

  factory GamificationStats.fromMap(Map<String, dynamic> map) {
    return GamificationStats(
      points: map['points'] as int,
      currentStreak: map['current_streak'] as int,
      bestStreak: map['best_streak'] as int,
      lastLogDate: map['last_log_date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['last_log_date'] as int)
          : null,
      currentAvatar: map['current_avatar'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'points': points,
      'current_streak': currentStreak,
      'best_streak': bestStreak,
      'last_log_date': lastLogDate?.millisecondsSinceEpoch,
      'current_avatar': currentAvatar,
    };
  }

  GamificationStats copyWith({
    int? points,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastLogDate,
    String? currentAvatar,
  }) {
    return GamificationStats(
      points: points ?? this.points,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastLogDate: lastLogDate ?? this.lastLogDate,
      currentAvatar: currentAvatar ?? this.currentAvatar,
    );
  }
}
