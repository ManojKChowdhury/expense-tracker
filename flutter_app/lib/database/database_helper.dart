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
      version: 1,
      onCreate: _onCreate,
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
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
