// lib/models/meal.dart
class Meal {
  final int id;
  final String dishName;
  final double weightG;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  final int? userRating;
  final DateTime createdAt;

  Meal({
    required this.id,
    required this.dishName,
    required this.weightG,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
    this.userRating,
    required this.createdAt,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as int,
      dishName: json['dish_name'] as String,
      weightG: (json['weight_g'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      proteins: (json['proteins'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      userRating: json['user_rating'] != null ? json['user_rating'] as int : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dish_name': dishName,
      'weight_g': weightG,
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'carbs': carbs,
      'user_rating': userRating,
      'created_at': createdAt.toIso8601String(),
    };
  }
}