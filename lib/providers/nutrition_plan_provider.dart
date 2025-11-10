import 'package:flutter/foundation.dart';
import '../models/nutrition_plan_model.dart';
import '../services/nutrition_database_service.dart';

class NutritionPlanProvider with ChangeNotifier {
  final _nutritionService = NutritionDatabaseService.instance;

  List<NutritionPlan> _plans = [];
  List<PlanMeal> _currentPlanMeals = [];
  NutritionPlan? _currentPlan;
  bool _isLoading = false;
  String? _errorMessage;

  List<NutritionPlan> get plans => _plans;
  List<PlanMeal> get currentPlanMeals => _currentPlanMeals;
  NutritionPlan? get currentPlan => _currentPlan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all plans for a coach
  Future<void> loadPlansByCoach(int coachId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _plans = await _nutritionService.getNutritionPlansByCoach(coachId);
    } catch (e) {
      _errorMessage = 'Erreur chargement plans: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load plans for a client
  Future<void> loadPlansByClient(int clientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _plans = await _nutritionService.getNutritionPlansByClient(clientId);
    } catch (e) {
      _errorMessage = 'Erreur chargement plans: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load template plans
  Future<void> loadTemplatePlans(int coachId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _plans = await _nutritionService.getTemplatePlans(coachId);
    } catch (e) {
      _errorMessage = 'Erreur chargement templates: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load a specific plan with its meals
  Future<void> loadPlanWithMeals(int planId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPlan = await _nutritionService.getNutritionPlanById(planId);
      if (_currentPlan != null) {
        _currentPlanMeals = await _nutritionService.getPlanMeals(planId);
      }
    } catch (e) {
      _errorMessage = 'Erreur chargement plan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new plan
  Future<int?> createPlan(NutritionPlan plan) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final planId = await _nutritionService.createNutritionPlan(plan);
      await loadPlansByCoach(plan.coachId);
      return planId;
    } catch (e) {
      _errorMessage = 'Erreur création plan: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update a plan
  Future<bool> updatePlan(NutritionPlan plan) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _nutritionService.updateNutritionPlan(plan);
      await loadPlansByCoach(plan.coachId);
      if (_currentPlan?.id == plan.id) {
        await loadPlanWithMeals(plan.id!);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Erreur mise à jour plan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a plan
  Future<bool> deletePlan(int planId, int coachId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _nutritionService.deleteNutritionPlan(planId);
      await loadPlansByCoach(coachId);
      if (_currentPlan?.id == planId) {
        _currentPlan = null;
        _currentPlanMeals = [];
      }
      return true;
    } catch (e) {
      _errorMessage = 'Erreur suppression plan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Add a meal to the current plan
  Future<bool> addPlanMeal(PlanMeal meal) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _nutritionService.addPlanMeal(meal);
      if (_currentPlan != null) {
        await loadPlanWithMeals(_currentPlan!.id!);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Erreur ajout repas: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update a plan meal
  Future<bool> updatePlanMeal(PlanMeal meal) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _nutritionService.updatePlanMeal(meal);
      if (_currentPlan != null) {
        await loadPlanWithMeals(_currentPlan!.id!);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Erreur mise à jour repas: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a plan meal
  Future<bool> deletePlanMeal(int mealId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _nutritionService.deletePlanMeal(mealId);
      if (_currentPlan != null) {
        await loadPlanWithMeals(_currentPlan!.id!);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Erreur suppression repas: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Assign plan to client
  Future<bool> assignPlanToClient(int planId, int clientId, DateTime startDate, DateTime? endDate) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _nutritionService.assignPlanToClient(planId, clientId, startDate, endDate);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur attribution plan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Apply plan to client (generate meals)
  Future<bool> applyPlanToClient(int planId, int clientId, DateTime startDate, int days) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _nutritionService.applyPlanToClient(planId, clientId, startDate, days);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur application plan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear current plan
  void clearCurrentPlan() {
    _currentPlan = null;
    _currentPlanMeals = [];
    notifyListeners();
  }
}

