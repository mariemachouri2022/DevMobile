enum MealType { breakfast, lunch, snack, dinner }

class Meal {
  final int? id;
  final int userId;
  final String day; // YYYY-MM-DD
  final MealType mealType;
  final String name;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final bool isFavorite;
  final bool isTemplate;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Meal({
    this.id,
    required this.userId,
    required this.day,
    required this.mealType,
    required this.name,
    this.calories = 0,
    this.proteins = 0,
    this.carbs = 0,
    this.fats = 0,
    this.isFavorite = false,
    this.isTemplate = false,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  Meal copyWith({
    int? id,
    int? userId,
    String? day,
    MealType? mealType,
    String? name,
    double? calories,
    double? proteins,
    double? carbs,
    double? fats,
    bool? isFavorite,
    bool? isTemplate,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Meal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      day: day ?? this.day,
      mealType: mealType ?? this.mealType,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      isFavorite: isFavorite ?? this.isFavorite,
      isTemplate: isTemplate ?? this.isTemplate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'day': day,
      'mealType': mealType.name,
      'name': name,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'isFavorite': isFavorite ? 1 : 0,
      'isTemplate': isTemplate ? 1 : 0,
      'note': note,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      day: map['day'] as String,
      mealType: MealType.values.firstWhere((e) => e.name == map['mealType']),
      name: map['name'] as String,
      calories: (map['calories'] as num).toDouble(),
      proteins: (map['proteins'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fats: (map['fats'] as num).toDouble(),
      isFavorite: (map['isFavorite'] as int) == 1,
      isTemplate: (map['isTemplate'] as int) == 1,
      note: map['note'] as String?,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}


