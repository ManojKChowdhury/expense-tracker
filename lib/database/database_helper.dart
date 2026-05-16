import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'expense_tracker.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        date INTEGER NOT NULL,
        notes TEXT,
        receiptPhotoUri TEXT
      )
    ''');

    // Create budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_transactions_date ON transactions(date)
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_type ON transactions(type)
    ''');

    await db.execute('''
      CREATE INDEX idx_budgets_month_year ON budgets(month, year)
    ''');

    // Call onUpgrade manually for version 1 to 2 creation during fresh install
    if (version >= 2) {
      await _createGamificationTables(db);
      await _seedGamificationData(db);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createGamificationTables(db);
      await _seedGamificationData(db);
    }
  }

  Future<void> _createGamificationTables(Database db) async {
    await db.execute('''
      CREATE TABLE gamification_stats (
        id INTEGER PRIMARY KEY CHECK (id = 1), -- Ensure only one row exists
        points INTEGER NOT NULL DEFAULT 0,
        current_streak INTEGER NOT NULL DEFAULT 0,
        best_streak INTEGER NOT NULL DEFAULT 0,
        last_log_date INTEGER,
        current_avatar TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user_badges (
        badge_id TEXT PRIMARY KEY,
        unlocked_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _seedGamificationData(Database db) async {
    await db.execute('''
      INSERT OR IGNORE INTO gamification_stats (id, points, current_streak, best_streak)
      VALUES (1, 0, 0, 0)
    ''');
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.execute('DELETE FROM transactions');
    await db.execute('DELETE FROM budgets');
    await db.execute('DELETE FROM user_badges');
    await db.execute('UPDATE gamification_stats SET points = 0, current_streak = 0, best_streak = 0, last_log_date = NULL, current_avatar = NULL WHERE id = 1');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
