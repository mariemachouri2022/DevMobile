import 'package:flutter/foundation.dart';
import '../models/meal_model.dart';
import '../services/nutrition_database_service.dart';

class NutritionProvider with ChangeNotifier {
  // Service reference
  final _nutritionService = NutritionDatabaseService.instance;

  List<Meal> _meals = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _showFavoritesOnly = false;

  // Chart/cache data
  List<Map<String, dynamic>> _calories7d = [];
  List<Map<String, dynamic>> _macros7d = [];
  Map<String, num> _weeklyAverages = const {
    'avgCalories': 0,
    'avgProteins': 0,
    'avgCarbs': 0,
    'avgFats': 0,
  };

  List<Meal> get meals => _meals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get showFavoritesOnly => _showFavoritesOnly;
  List<Map<String, dynamic>> get calories7d => _calories7d;
  List<Map<String, dynamic>> get macros7d => _macros7d;
  Map<String, num> get weeklyAverages => _weeklyAverages;

  // Utility: compute ISO YYYY-MM-DD string from DateTime
  String _isoDate(DateTime d) =>
      DateTime(d.year, d.month, d.day).toIso8601String().substring(0, 10);

  String _weekStart(DateTime d) {
    final weekday = d.weekday; // 1 = Monday
    final monday =
        DateTime(d.year, d.month, d.day).subtract(Duration(days: weekday - 1));
    return _isoDate(monday);
  }

  Future<void> loadMealsForDay(int userId, DateTime date) async {
    _showFavoritesOnly = false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final day = _isoDate(date);
      _meals = await _nutritionService.getMealsByDay(userId, day);
    } catch (e) {
      _errorMessage = 'Erreur chargement repas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFavoriteMeals(int userId) async {
    _showFavoritesOnly = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _meals = await _nutritionService.getFavoriteMeals(userId);
    } catch (e) {
      _errorMessage = 'Erreur chargement favoris: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMeal(int userId, Meal meal) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _nutritionService.addMeal(meal);
      await _nutritionService.refreshDayCache(
        userId: userId,
        day: meal.day,
        weekStart: _weekStart(DateTime.parse(meal.day)),
      );
      await loadMealsForDay(userId, DateTime.parse(meal.day));
      return true;
    } catch (e) {
      _errorMessage = 'Erreur ajout repas: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMeal(Meal meal) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _nutritionService.updateMeal(meal);
      await _nutritionService.refreshDayCache(
        userId: meal.userId,
        day: meal.day,
        weekStart: _weekStart(DateTime.parse(meal.day)),
      );
      await loadMealsForDay(meal.userId, DateTime.parse(meal.day));
      return true;
    } catch (e) {
      _errorMessage = 'Erreur mise à jour: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMeal(int userId, int mealId, DateTime day) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _nutritionService.deleteMeal(mealId);
      final dayStr = _isoDate(day);
      await _nutritionService.refreshDayCache(
        userId: userId,
        day: dayStr,
        weekStart: _weekStart(day),
      );
      await loadMealsForDay(userId, day);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur suppression: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadChartsAndAverages(
      int userId, DateTime endDayInclusive) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final dayStr = _isoDate(endDayInclusive);
      _calories7d = await _nutritionService.getCalories7d(userId, dayStr);
      _macros7d = await _nutritionService.getMacros7d(userId, dayStr);
      _weeklyAverages = await _nutritionService.getWeeklyAverages(
          userId, _weekStart(endDayInclusive));
    } catch (e) {
      _errorMessage = 'Erreur statistiques: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}


