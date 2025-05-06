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
        date TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertAchievement(String childName, int achievementNumber) async {
    final db = await database;
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // First, delete any existing achievement for today
    await db.delete(
      'achievements',
      where: 'child_name = ? AND date = ?',
      whereArgs: [childName, date],
    );

    // Then insert the new achievement
    return await db.insert('achievements', {
      'child_name': childName,
      'achievement_number': achievementNumber,
      'date': date,
    });
  }
// get total of achievements.achievement_number for a child     
  Future<int> getTotalAchievements(String childName) async {
    final db = await database;
    final results = await db.query(
      'achievements',
      where: 'child_name = ?',  
      whereArgs: [childName],
    );
    return results.fold<int>(0, (sum, row) => sum + (row['achievement_number'] as int));
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