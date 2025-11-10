import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../theme/app_theme.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onFavoriteToggle;

  const MealCard({
    super.key,
    required this.meal,
    this.onEdit,
    this.onDelete,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconForMealType(meal.mealType), color: AppTheme.warningColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_titleForMealType(meal.mealType),
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(meal.name, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onFavoriteToggle,
                  icon: Icon(
                    meal.isFavorite ? Icons.star : Icons.star_border,
                    color: meal.isFavorite ? AppTheme.warningColor : AppTheme.textSecondary,
                  ),
                  tooltip: 'Favori',
                ),
                IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _macroTile(context, 'Calories', '${meal.calories.toStringAsFixed(0)} kcal'),
                const SizedBox(width: 12),
                _macroTile(context, 'Protéines', '${meal.proteins.toStringAsFixed(1)} g'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _macroTile(context, 'Glucides', '${meal.carbs.toStringAsFixed(1)} g'),
                const SizedBox(width: 12),
                _macroTile(context, 'Lipides', '${meal.fats.toStringAsFixed(1)} g'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroTile(BuildContext context, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  IconData _iconForMealType(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.wb_twighlight;
      case MealType.lunch:
        return Icons.sunny;
      case MealType.snack:
        return Icons.local_cafe_outlined;
      case MealType.dinner:
        return Icons.nightlight_round;
    }
  }

  String _titleForMealType(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Petit-déjeuner';
      case MealType.lunch:
        return 'Déjeuner';
      case MealType.snack:
        return 'Collation';
      case MealType.dinner:
        return 'Dîner';
    }
  }
}


