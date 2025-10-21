// lib/screens/meals_screen.dart
import 'package:flutter/material.dart';
import 'package:food_recognizer_client/models/meal_model.dart';
import 'package:food_recognizer_client/widgets/global_widgets/pull_to_refresh_scaffold.dart';
import '../services/data_service.dart';
import '../services/scan_service.dart';

class MealsScreen extends StatefulWidget {
  final List<Meal> preloadedMeals;

  const MealsScreen({super.key, required this.preloadedMeals});

  @override
  _MealsScreenState createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  late List<Meal> _meals;

  @override
  void initState() {
    super.initState();
    _meals = List<Meal>.from(widget.preloadedMeals);
  }

  Future<void> _loadMeals() async {
    try {
      final meals = await DataService.getMeals();
      setState(() {
        _meals = meals;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  Future<void> _updateRating(int mealId, int rating) async {
    try {
      await ScanService.rateMeal(mealId, rating);
      await _loadMeals();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PullToRefresh(
      onRefresh: _loadMeals,
      child: Scaffold(
        appBar: AppBar(title: const Text('История сканирований')),
        body: _meals.isEmpty
            ? const Center(child: Text('Нет данных о сканированиях', style: TextStyle(fontSize: 18, color: Colors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _meals.length,
                itemBuilder: (context, index) {
                  final meal = _meals[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: const Icon(Icons.fastfood, color: Colors.green, size: 30),
                      title: Text(meal.dishName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildNutrientRow('Вес', '${meal.weightG.toStringAsFixed(1)} г'),
                          _buildNutrientRow('Калории', '${meal.calories.toStringAsFixed(0)} ккал'),
                          _buildNutrientRow('Белки', '${meal.proteins.toStringAsFixed(1)} г'),
                          _buildNutrientRow('Жиры', '${meal.fats.toStringAsFixed(1)} г'),
                          _buildNutrientRow('Углеводы', '${meal.carbs.toStringAsFixed(1)} г'),
                          Text(
                            'Дата: ${_formatDate(meal.createdAt)}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (starIndex) {
                          return GestureDetector(
                            onTap: () => _updateRating(meal.id, starIndex + 1),
                            child: Icon(
                              Icons.star,
                              color: starIndex < (meal.userRating ?? 0) ? Colors.amber : Colors.grey,
                              size: 20,
                            ),
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}