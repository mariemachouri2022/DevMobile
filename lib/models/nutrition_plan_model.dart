import 'meal_model.dart';

class NutritionPlan {
  final int? id;
  final int coachId; // Coach who created the plan
  final int? clientId; // Client assigned to (null if template)
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isTemplate; // If true, can be reused for multiple clients
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NutritionPlan({
    this.id,
    required this.coachId,
    this.clientId,
    required this.name,
    this.description,
    required this.startDate,
    this.endDate,
    this.isTemplate = false,
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  NutritionPlan copyWith({
    int? id,
    int? coachId,
    int? clientId,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    bool? isTemplate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NutritionPlan(
      id: id ?? this.id,
      coachId: coachId ?? this.coachId,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isTemplate: isTemplate ?? this.isTemplate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'coachId': coachId,
      'clientId': clientId,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isTemplate': isTemplate ? 1 : 0,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory NutritionPlan.fromMap(Map<String, dynamic> map) {
    return NutritionPlan(
      id: map['id'] as int?,
      coachId: map['coachId'] as int,
      clientId: map['clientId'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'] as String)
          : null,
      isTemplate: (map['isTemplate'] as int) == 1,
      isActive: (map['isActive'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }
}

class PlanMeal {
  final int? id;
  final int planId;
  final String dayOfWeek; // 'monday', 'tuesday', etc. or 'daily' for all days
  final MealType mealType;
  final String name;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final String? note;
  final int orderIndex; // For ordering meals within the same day/type

  PlanMeal({
    this.id,
    required this.planId,
    required this.dayOfWeek,
    required this.mealType,
    required this.name,
    this.calories = 0,
    this.proteins = 0,
    this.carbs = 0,
    this.fats = 0,
    this.note,
    this.orderIndex = 0,
  });

  PlanMeal copyWith({
    int? id,
    int? planId,
    String? dayOfWeek,
    MealType? mealType,
    String? name,
    double? calories,
    double? proteins,
    double? carbs,
    double? fats,
    String? note,
    int? orderIndex,
  }) {
    return PlanMeal(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      mealType: mealType ?? this.mealType,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      note: note ?? this.note,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'planId': planId,
      'dayOfWeek': dayOfWeek,
      'mealType': mealType.name,
      'name': name,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'note': note,
      'orderIndex': orderIndex,
    };
  }

  factory PlanMeal.fromMap(Map<String, dynamic> map) {
    return PlanMeal(
      id: map['id'] as int?,
      planId: map['planId'] as int,
      dayOfWeek: map['dayOfWeek'] as String,
      mealType: MealType.values.firstWhere(
        (e) => e.name == map['mealType'],
      ),
      name: map['name'] as String,
      calories: (map['calories'] as num).toDouble(),
      proteins: (map['proteins'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fats: (map['fats'] as num).toDouble(),
      note: map['note'] as String?,
      orderIndex: map['orderIndex'] as int? ?? 0,
    );
  }
}

