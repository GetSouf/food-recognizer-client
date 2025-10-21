// lib/models/daily_goal_model.dart
class DailyGoal {
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;

  DailyGoal({
    this.calories = 0.0,
    this.proteins = 0.0,
    this.fats = 0.0,
    this.carbs = 0.0,
  });

  factory DailyGoal.fromJson(Map<String, dynamic> json) {
    return DailyGoal(
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      proteins: (json['proteins'] as num?)?.toDouble() ?? 0.0,
      fats: (json['fats'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'proteins': proteins,
    'fats': fats,
    'carbs': carbs,
  };
}