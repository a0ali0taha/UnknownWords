import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'lib/database_helper.dart';
 
void main() async {
  // Initialize FFI
  sqfliteFfiInit();
  
  final dbHelper = DatabaseHelper.instance;
  
  try {
    print('Starting database test...');
    
    // Test 1: Insert first achievement
    print('\nTest 1: Inserting first achievement');
    final id1 = await dbHelper.insertAchievement('Test Child', 1);
    print('First achievement inserted with ID: $id1');
    
    // Get today's achievements after first insert
    final achievements1 = await dbHelper.getTodayAchievements('Test Child');
    print('Achievements after first insert: $achievements1');
    
    // Test 2: Insert second achievement (should override first)
    print('\nTest 2: Inserting second achievement');
    final id2 = await dbHelper.insertAchievement('Test Child', 2);
    print('Second achievement inserted with ID: $id2');
    
    // Get today's achievements after second insert
    final achievements2 = await dbHelper.getTodayAchievements('Test Child');
    print('Achievements after second insert: $achievements2');
    
    print('\nTest completed successfully!');
  } catch (e) {
    print('Error during database test: $e');
  } finally {
    // Close the database
    await dbHelper.close();
  }
} 