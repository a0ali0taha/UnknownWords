import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('achievements.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE achievements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_name TEXT NOT NULL,
        achievement_number INTEGER NOT NULL,
        points INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertAchievement(String childName, int achievementNumber, int points) async {
    final db = await database;
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Check if child has already reached 5 achievements today
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM achievements WHERE child_name = ? AND date = ?',
      [childName, date]
    )) ?? 0;
    
    if (count >= 5) {
      throw Exception('Maximum 5 achievements per day reached for $childName');
    }

    return await db.insert('achievements', {
      'child_name': childName,
      'achievement_number': achievementNumber,
      'points': points,
      'date': date,
    });
  }

  Future<int> getTotalPoints(String childName) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(points) as total FROM achievements WHERE child_name = ?',
      [childName]
    );
    return result.first['total'] as int? ?? 0;
  }

  Future<List<Map<String, dynamic>>> getTodayAchievements(String childName) async {
    final db = await database;
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return await db.query(
      'achievements',
      where: 'child_name = ? AND date = ?',
      whereArgs: [childName, date],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
} 