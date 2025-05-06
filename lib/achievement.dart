class Achievement {
  final int? id;
  final String childName;
  final int achievementNumber;
  final String date;

  Achievement({
    this.id,
    required this.childName,
    required this.achievementNumber,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'child_name': childName,
      'achievement_number': achievementNumber,
      'date': date,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      childName: map['child_name'],
      achievementNumber: map['achievement_number'],
      date: map['date'],
    );
  }
} 