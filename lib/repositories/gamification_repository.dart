import 'package:sqflite/sqflite.dart';
import 'package:expense_tracker_flutter/database/database_helper.dart';
import 'package:expense_tracker_flutter/models/gamification_stats.dart';
import 'package:expense_tracker_flutter/models/badge.dart';

class GamificationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<GamificationStats> getStats() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('gamification_stats', where: 'id = ?', whereArgs: [1]);
    
    if (maps.isNotEmpty) {
      return GamificationStats.fromMap(maps.first);
    } else {
      // Default fallback if not seeded
      final stats = GamificationStats(points: 0, currentStreak: 0, bestStreak: 0);
      await db.insert('gamification_stats', stats.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      return stats;
    }
  }

  Future<void> updateStats(GamificationStats stats) async {
    final db = await _dbHelper.database;
    await db.update(
      'gamification_stats',
      stats.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<List<UserBadge>> getUnlockedBadges() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('user_badges');
    return maps.map((map) => UserBadge.fromMap(map)).toList();
  }

  Future<void> unlockBadge(String badgeId) async {
    final db = await _dbHelper.database;
    final badge = UserBadge(badgeId: badgeId, unlockedAt: DateTime.now());
    await db.insert('user_badges', badge.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }
}
