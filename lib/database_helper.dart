import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'models/achievement.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Box<Achievement>? _achievementsBox;

  DatabaseHelper._init();

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AchievementAdapter());
    _achievementsBox = await Hive.openBox<Achievement>('achievements');
  }

  Future<void> insertAchievement(String childName, int achievementNumber) async {
    final date = DateTime.now();
    
    // First, delete any existing achievement for today
    final today = DateFormat('yyyy-MM-dd').format(date);
    final existingAchievements = _achievementsBox!.values.where((achievement) =>
        achievement.childName == childName &&
        DateFormat('yyyy-MM-dd').format(achievement.date) == today);
    
    for (var achievement in existingAchievements) {
      await achievement.delete();
    }

    // Then insert the new achievement
    await _achievementsBox!.add(Achievement(
      childName: childName,
      achievementNumber: achievementNumber,
      date: date,
    ));
  }

  Future<int> getTotalAchievements(String childName) async {
    final achievements = _achievementsBox!.values
        .where((achievement) => achievement.childName == childName);
    return achievements.fold<int>(0, (sum, achievement) => sum + achievement.achievementNumber);
  }

  Future<List<Achievement>> getTodayAchievements(String childName) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _achievementsBox!.values
        .where((achievement) =>
            achievement.childName == childName &&
            DateFormat('yyyy-MM-dd').format(achievement.date) == today)
        .toList();
  }

  Future<void> close() async {
    await _achievementsBox?.close();
  }
} 