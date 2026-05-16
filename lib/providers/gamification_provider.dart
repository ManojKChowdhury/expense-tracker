import 'package:flutter/foundation.dart';
import 'package:expense_tracker_flutter/models/gamification_stats.dart';
import 'package:expense_tracker_flutter/models/badge.dart';
import 'package:expense_tracker_flutter/repositories/gamification_repository.dart';
import 'package:expense_tracker_flutter/repositories/notification_service.dart';

class GamificationProvider with ChangeNotifier {
  final GamificationRepository _repository = GamificationRepository();

  GamificationStats _stats = GamificationStats(points: 0, currentStreak: 0, bestStreak: 0);
  List<UserBadge> _unlockedBadges = [];
  
  // For showing the achievement dialog
  UserBadge? newlyUnlockedBadge;

  GamificationStats get stats => _stats;
  List<UserBadge> get unlockedBadges => _unlockedBadges;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  GamificationProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    _stats = await _repository.getStats();
    _unlockedBadges = await _repository.getUnlockedBadges();

    // Check streak reset on init
    _checkStreak();

    _isLoading = false;
    notifyListeners();
  }

  void _checkStreak() {
    if (_stats.lastLogDate == null) return;
    
    final now = DateTime.now();
    final lastDate = _stats.lastLogDate!;
    
    final difference = DateTime(now.year, now.month, now.day).difference(DateTime(lastDate.year, lastDate.month, lastDate.day)).inDays;

    if (difference > 1) {
      // Streak broken
      _stats = _stats.copyWith(currentStreak: 0);
      _repository.updateStats(_stats);
    }
  }

  Future<void> logExpenseAction(double amount) async {
    // 1. Add points (e.g., 10 points per logged expense)
    int pointsEarned = 10;
    
    // 2. Evaluate streak
    final now = DateTime.now();
    int newStreak = _stats.currentStreak;
    int newBestStreak = _stats.bestStreak;
    
    if (_stats.lastLogDate != null) {
      final lastDate = _stats.lastLogDate!;
      final difference = DateTime(now.year, now.month, now.day).difference(DateTime(lastDate.year, lastDate.month, lastDate.day)).inDays;
      
      if (difference == 1) {
        newStreak++;
      } else if (difference > 1) {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    if (newStreak > newBestStreak) {
      newBestStreak = newStreak;
    }

    _stats = _stats.copyWith(
      points: _stats.points + pointsEarned,
      currentStreak: newStreak,
      bestStreak: newBestStreak,
      lastLogDate: now,
    );

    await _repository.updateStats(_stats);

    // 3. Check for badge unlocks
    await _checkBadgesOnExpense(amount, newStreak);
    
    // 4. Schedule Streak Reminder
    if (newStreak > 0) {
      NotificationService().scheduleDailyReminder(
        20, 0, // 8:00 PM
        title: 'Keep your streak alive! 🔥',
        body: 'You are on a $newStreak-day streak. Log an expense today!',
      );
    }
    
    notifyListeners();
  }

  Future<void> _checkBadgesOnExpense(double amount, int currentStreak) async {
    // First Step
    await _evaluateBadge('first_expense', () => true); // If they log, they get it
    
    // Streaks
    if (currentStreak >= 3) await _evaluateBadge('three_day_streak', () => true);
    if (currentStreak >= 7) await _evaluateBadge('seven_day_streak', () => true);
    
    // Spender
    if (amount >= 100) await _evaluateBadge('spender_100', () => true);
  }

  Future<void> evaluateBadgeExternal(String badgeId) async {
    await _evaluateBadge(badgeId, () => true);
    notifyListeners();
  }

  Future<void> _evaluateBadge(String badgeId, bool Function() condition) async {
    if (_unlockedBadges.any((b) => b.badgeId == badgeId)) return; // Already unlocked

    if (condition()) {
      await _repository.unlockBadge(badgeId);
      final newBadge = UserBadge(badgeId: badgeId, unlockedAt: DateTime.now());
      _unlockedBadges.add(newBadge);
      newlyUnlockedBadge = newBadge;
    }
  }

  void clearNewlyUnlockedBadge() {
    newlyUnlockedBadge = null;
    notifyListeners();
  }

  Future<bool> buyAvatar(String avatarPath, int cost) async {
    if (_stats.points >= cost) {
      _stats = _stats.copyWith(
        points: _stats.points - cost,
        currentAvatar: avatarPath,
      );
      await _repository.updateStats(_stats);
      notifyListeners();
      return true;
    }
    return false;
  }
}
