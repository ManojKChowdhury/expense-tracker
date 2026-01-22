import 'package:sqflite/sqflite.dart';
import 'package:expense_tracker_flutter/database/database_helper.dart';
import 'package:expense_tracker_flutter/models/transaction.dart';
import 'package:expense_tracker_flutter/models/budget.dart';
import 'package:expense_tracker_flutter/models/aggregates.dart';

class ExpenseRepository {
  final DatabaseHelper _databaseHelper;

  ExpenseRepository(this._databaseHelper);

  // Transaction operations
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await _databaseHelper.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<List<Transaction>> getRecentTransactions({int limit = 10}) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<double> getTotalByType(
    TransactionType type,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseHelper.database;
    final typeString = type == TransactionType.income ? 'INCOME' : 'EXPENSE';
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ? AND date >= ? AND date <= ?',
      [typeString, startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<List<CategoryTotal>> getCategoryTotals(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT category, SUM(amount) as total 
         FROM transactions 
         WHERE type = 'EXPENSE' AND date >= ? AND date <= ? 
         GROUP BY category 
         ORDER BY total DESC''',
      [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
    );
    return List.generate(maps.length, (i) => CategoryTotal.fromMap(maps[i]));
  }

  Future<List<DailyTotal>> getDailyTotals(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''SELECT date, SUM(amount) as total 
         FROM transactions 
         WHERE type = 'EXPENSE' AND date >= ? AND date <= ? 
         GROUP BY date 
         ORDER BY date ASC''',
      [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
    );
    return List.generate(maps.length, (i) => DailyTotal.fromMap(maps[i]));
  }

  // Budget operations
  Future<int> insertBudget(Budget budget) async {
    final db = await _databaseHelper.database;
    return await db.insert('budgets', budget.toMap());
  }

  Future<int> updateBudget(Budget budget) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<Budget?> getBudget(String category, int month, int year) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'category = ? AND month = ? AND year = ?',
      whereArgs: [category, month, year],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Budget.fromMap(maps.first);
  }

  Future<List<Budget>> getAllBudgetsForMonth(int month, int year) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  // Helper functions for date ranges
  DateRange getCurrentMonthRange() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return DateRange(startOfMonth, endOfMonth);
  }

  DateRange getTodayRange() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return DateRange(startOfDay, endOfDay);
  }

  DateRange getThisWeekRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    return DateRange(start, end);
  }

  DateRange getLastMonthRange() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final startOfLastMonth = DateTime(lastMonth.year, lastMonth.month, 1);
    final endOfLastMonth = DateTime(lastMonth.year, lastMonth.month + 1, 0, 23, 59, 59);
    return DateRange(startOfLastMonth, endOfLastMonth);
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange(this.start, this.end);
}
