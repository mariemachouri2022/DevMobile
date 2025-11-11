import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/nutritionix_config.dart';

class NutritionixService {
  // Edamam Food Database API for searching foods
  static const String _foodDatabaseUrl = 'https://api.edamam.com/api/food-database/v2/parser';
  // Edamam Nutrition Analysis API for getting nutrition details
  static const String _nutritionAnalysisUrl = 'https://api.edamam.com/api/nutrition-details';

  /// Check if API is configured
  static bool get isConfigured => NutritionixConfig.isConfigured;

  /// Search for foods using Edamam Food Database API
  /// Returns a list of food items with their nutritional information
  static Future<List<FoodItem>> searchFoods(String query) async {
    try {
      final uri = Uri.parse(_foodDatabaseUrl).replace(queryParameters: {
        'app_id': NutritionixConfig.appId,
        'app_key': NutritionixConfig.appKey,
        'ingr': query,
        'nutrition-type': 'cooking',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> hints = data['hints'] ?? [];
        final List<dynamic> parsed = data['parsed'] ?? [];

        final List<FoodItem> results = [];

        // Process parsed foods (exact matches)
        for (var item in parsed) {
          final food = item['food'];
          if (food != null) {
            final nutrients = food['nutrients'];
            results.add(FoodItem(
              name: food['label'] ?? '',
              id: food['foodId'] ?? '',
              brand: food['brand'],
              isCommon: true,
              calories: (nutrients?['ENERC_KCAL'] as num?)?.toDouble(),
              proteins: (nutrients?['PROCNT'] as num?)?.toDouble(),
              carbs: (nutrients?['CHOCDF'] as num?)?.toDouble(),
              fats: (nutrients?['FAT'] as num?)?.toDouble(),
            ));
          }
        }

        // Process hints (suggestions)
        for (var hint in hints) {
          final food = hint['food'];
          if (food != null) {
            final nutrients = food['nutrients'];
            results.add(FoodItem(
              name: food['label'] ?? '',
              id: food['foodId'] ?? '',
              brand: food['brand'],
              isCommon: true,
              calories: (nutrients?['ENERC_KCAL'] as num?)?.toDouble(),
              proteins: (nutrients?['PROCNT'] as num?)?.toDouble(),
              carbs: (nutrients?['CHOCDF'] as num?)?.toDouble(),
              fats: (nutrients?['FAT'] as num?)?.toDouble(),
            ));
          }
        }

        return results;
      } else {
        throw Exception('Failed to search foods: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching foods: $e');
    }
  }

  /// Get detailed nutritional information for a specific food item
  /// Note: Edamam uses food names, not IDs for nutrition analysis
  static Future<FoodNutrition> getFoodNutrition(String foodId, {bool isCommon = true}) async {
    // Edamam doesn't support lookup by ID, use getFoodNutritionByName instead
    throw Exception('Use getFoodNutritionByName for Edamam API');
  }

  /// Get nutritional information using natural language (for common foods)
  /// Uses Edamam Nutrition Analysis API
  static Future<FoodNutrition> getFoodNutritionByName(String foodName) async {
    try {
      final uri = Uri.parse(_nutritionAnalysisUrl).replace(queryParameters: {
        'app_id': NutritionixConfig.appId,
        'app_key': NutritionixConfig.appKey,
      });

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': foodName,
          'ingr': [foodName], // Single ingredient
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final totalNutrients = data['totalNutrients'] ?? {};
        final totalWeight = (data['totalWeight'] as num?)?.toDouble() ?? 100.0;

        // Extract nutrients
        final calories = (totalNutrients['ENERC_KCAL']?['quantity'] as num?)?.toDouble() ?? 0.0;
        final proteins = (totalNutrients['PROCNT']?['quantity'] as num?)?.toDouble() ?? 0.0;
        final carbs = (totalNutrients['CHOCDF']?['quantity'] as num?)?.toDouble() ?? 0.0;
        final fats = (totalNutrients['FAT']?['quantity'] as num?)?.toDouble() ?? 0.0;

        return FoodNutrition(
          name: foodName,
          calories: calories,
          proteins: proteins,
          carbs: carbs,
          fats: fats,
          servingWeight: totalWeight,
          servingUnit: 'g',
          servingQty: 1.0,
        );
      } else {
        final errorBody = response.body;
        throw Exception('Failed to get food nutrition: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      throw Exception('Error getting food nutrition: $e');
    }
  }
}

/// Model for food search results
class FoodItem {
  final String name;
  final String id;
  final String? brand;
  final bool isCommon;
  final double? calories;
  final double? proteins;
  final double? carbs;
  final double? fats;

  FoodItem({
    required this.name,
    required this.id,
    this.brand,
    required this.isCommon,
    this.calories,
    this.proteins,
    this.carbs,
    this.fats,
  });
}

/// Model for detailed food nutrition information
class FoodNutrition {
  final String name;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final double? servingWeight;
  final String? servingUnit;
  final double? servingQty;

  FoodNutrition({
    required this.name,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    this.servingWeight,
    this.servingUnit,
    this.servingQty,
  });
}

