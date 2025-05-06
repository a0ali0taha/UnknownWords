import 'package:hive/hive.dart';

part 'achievement.g.dart';

@HiveType(typeId: 0)
class Achievement extends HiveObject {
  @HiveField(0)
  String childName;

  @HiveField(1)
  int achievementNumber;

  @HiveField(2)
  DateTime date;

  Achievement({
    required this.childName,
    required this.achievementNumber,
    required this.date,
  });
} 