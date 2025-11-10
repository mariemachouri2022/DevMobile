import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/nutritionix_config.dart';

class NutritionixService {
  static const String _baseUrl = 'https://trackapi.nutritionix.com/v2';

  /// Check if API is configured
  static bool get isConfigured => NutritionixConfig.isConfigured;

  /// Search for foods using Nutritionix API
  /// Returns a list of food items with their nutritional information
  static Future<List<FoodItem>> searchFoods(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/instant').replace(queryParameters: {
          'query': query,
        }),
        headers: {
          'x-app-id': NutritionixConfig.appId,
          'x-app-key': NutritionixConfig.appKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> common = data['common'] ?? [];
        final List<dynamic> branded = data['branded'] ?? [];

        final List<FoodItem> results = [];

        // Process common foods
        for (var item in common) {
          results.add(FoodItem(
            name: item['food_name'] ?? '',
            id: item['tag_id']?.toString() ?? '',
            isCommon: true,
          ));
        }

        // Process branded foods
        for (var item in branded) {
          results.add(FoodItem(
            name: item['food_name'] ?? '',
            id: item['nix_item_id']?.toString() ?? '',
            brand: item['brand_name'],
            isCommon: false,
            calories: (item['nf_calories'] as num?)?.toDouble(),
            proteins: (item['nf_protein'] as num?)?.toDouble(),
            carbs: (item['nf_total_carbohydrate'] as num?)?.toDouble(),
            fats: (item['nf_total_fat'] as num?)?.toDouble(),
          ));
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
  static Future<FoodNutrition> getFoodNutrition(String foodId, {bool isCommon = true}) async {
    try {
      final endpoint = isCommon
          ? '$_baseUrl/natural/nutrients'
          : '$_baseUrl/search/item?nix_item_id=$foodId';

      if (isCommon) {
        // For common foods, we need to use natural language processing
        // This requires the food name, not just the ID
        throw Exception('Use getFoodNutritionByName for common foods');
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'x-app-id': NutritionixConfig.appId,
          'x-app-key': NutritionixConfig.appKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final foods = data['foods'] as List?;
        if (foods != null && foods.isNotEmpty) {
          final food = foods.first;
          return FoodNutrition(
            name: food['food_name'] ?? '',
            calories: (food['nf_calories'] as num?)?.toDouble() ?? 0,
            proteins: (food['nf_protein'] as num?)?.toDouble() ?? 0,
            carbs: (food['nf_total_carbohydrate'] as num?)?.toDouble() ?? 0,
            fats: (food['nf_total_fat'] as num?)?.toDouble() ?? 0,
            servingWeight: (food['serving_weight_grams'] as num?)?.toDouble(),
            servingUnit: food['serving_unit'],
            servingQty: (food['serving_qty'] as num?)?.toDouble(),
          );
        }
      }
      throw Exception('Failed to get food nutrition: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error getting food nutrition: $e');
    }
  }

  /// Get nutritional information using natural language (for common foods)
  static Future<FoodNutrition> getFoodNutritionByName(String foodName) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/natural/nutrients'),
        headers: {
          'Content-Type': 'application/json',
          'x-app-id': NutritionixConfig.appId,
          'x-app-key': NutritionixConfig.appKey,
        },
        body: jsonEncode({
          'query': foodName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final foods = data['foods'] as List?;
        if (foods != null && foods.isNotEmpty) {
          final food = foods.first;
          return FoodNutrition(
            name: food['food_name'] ?? '',
            calories: (food['nf_calories'] as num?)?.toDouble() ?? 0,
            proteins: (food['nf_protein'] as num?)?.toDouble() ?? 0,
            carbs: (food['nf_total_carbohydrate'] as num?)?.toDouble() ?? 0,
            fats: (food['nf_total_fat'] as num?)?.toDouble() ?? 0,
            servingWeight: (food['serving_weight_grams'] as num?)?.toDouble(),
            servingUnit: food['serving_unit'],
            servingQty: (food['serving_qty'] as num?)?.toDouble(),
          );
        }
      }
      throw Exception('Failed to get food nutrition: ${response.statusCode}');
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

