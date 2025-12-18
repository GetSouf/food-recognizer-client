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
      if (mounted) {
        setState(() {
          _meals = meals;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $e')));
      }
    }
  }

  Future<void> _updateRating(int mealId, int rating) async {
    try {
      await ScanService.rateMeal(mealId, rating);
      await _loadMeals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не удалось оценить')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PullToRefresh(
      onRefresh: _loadMeals,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('История приёмов пищи'),
          centerTitle: true,
        ),
        body: _meals.isEmpty
            ? _buildEmptyState(isDark)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _meals.length,
                itemBuilder: (context, index) {
                  final meal = _meals[index];
                  return _buildMealCard(meal, theme, isDark);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Ещё нет записей',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Отсканируйте своё блюдо, чтобы начать отслеживать питание',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[500] : Colors.grey[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(Meal meal, ThemeData theme, bool isDark) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Название блюда
            Text(
              meal.dishName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // Нутриенты — без иконок, с цветовой семантикой
            _buildNutrientLine('Калории', '${meal.calories.toStringAsFixed(0)} ккал', Colors.orange),
            _buildNutrientLine('Белки', '${meal.proteins.toStringAsFixed(1)} г', Colors.green),
            _buildNutrientLine('Жиры', '${meal.fats.toStringAsFixed(1)} г', Colors.red),
            _buildNutrientLine('Углеводы', '${meal.carbs.toStringAsFixed(1)} г', Colors.blue),

            const SizedBox(height: 8),

            // Дата
            Text(
              _formatDate(meal.createdAt),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),

            const SizedBox(height: 12),

            // Рейтинг — звёзды без подписей
            Row(
              children: List.generate(5, (i) {
                final isActive = i < (meal.userRating ?? 0);
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.star,
                    color: isActive ? Colors.amber : (isDark ? Colors.grey[700] : Colors.grey[400]),
                    size: 24,
                  ),
                  onPressed: () => _updateRating(meal.id, i + 1),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientLine(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}