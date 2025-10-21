// lib/widgets/profile_widgets/profile_stats_section.dart
import 'package:flutter/material.dart';

import 'package:food_recognizer_client/models/dailygoal_model.dart';
import 'package:food_recognizer_client/models/meal_model.dart';
import 'package:food_recognizer_client/services/data_service.dart';

import 'package:food_recognizer_client/widgets/profle_widgets/progress_bar_widget.dart';

class ProfileStatsSection extends StatelessWidget {
  final List<Meal> meals;
  final DailyGoal? dailyGoal;

  const ProfileStatsSection({super.key, required this.meals, required this.dailyGoal});

  double _calculateTotal(String nutrient) {
    return meals.fold(0, (sum, meal) {
      switch (nutrient) {
        case 'calories':
          return sum + meal.calories;
        case 'proteins':
          return sum + meal.proteins;
        case 'fats':
          return sum + meal.fats;
        case 'carbs':
          return sum + meal.carbs;
        default:
          return sum;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayMeals = DataService.filterTodayMeals(meals);
    final totalCalories = _calculateTotal('calories');
    final totalProteins = _calculateTotal('proteins');
    final totalFats = _calculateTotal('fats');
    final totalCarbs = _calculateTotal('carbs');

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Статистика за сегодня',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ProgressBarWidget(
              label: 'Калории',
              currentValue: totalCalories,
              goalValue: dailyGoal?.calories,
              color: Colors.green,
            ),
            ProgressBarWidget(
              label: 'Белки',
              currentValue: totalProteins,
              goalValue: dailyGoal?.proteins,
              color: Colors.blue,
            ),
            ProgressBarWidget(
              label: 'Жиры',
              currentValue: totalFats,
              goalValue: dailyGoal?.fats,
              color: Colors.orange,
            ),
            ProgressBarWidget(
              label: 'Углеводы',
              currentValue: totalCarbs,
              goalValue: dailyGoal?.carbs,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}