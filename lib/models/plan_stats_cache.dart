class PlanStatsCache {
  final int? id;
  final int userId;
  final String day; // YYYY-MM-DD
  final String weekStart; // Monday of the week YYYY-MM-DD
  final double totalCalories;
  final double totalProteins;
  final double totalCarbs;
  final double totalFats;
  final DateTime computedAt;
  final int ttlSeconds;

  PlanStatsCache({
    this.id,
    required this.userId,
    required this.day,
    required this.weekStart,
    this.totalCalories = 0,
    this.totalProteins = 0,
    this.totalCarbs = 0,
    this.totalFats = 0,
    DateTime? computedAt,
    this.ttlSeconds = 86400,
  }) : computedAt = computedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'day': day,
      'weekStart': weekStart,
      'totalCalories': totalCalories,
      'totalProteins': totalProteins,
      'totalCarbs': totalCarbs,
      'totalFats': totalFats,
      'computedAt': computedAt.toIso8601String(),
      'ttlSeconds': ttlSeconds,
    };
  }

  factory PlanStatsCache.fromMap(Map<String, dynamic> map) {
    return PlanStatsCache(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      day: map['day'] as String,
      weekStart: map['weekStart'] as String,
      totalCalories: (map['totalCalories'] as num).toDouble(),
      totalProteins: (map['totalProteins'] as num).toDouble(),
      totalCarbs: (map['totalCarbs'] as num).toDouble(),
      totalFats: (map['totalFats'] as num).toDouble(),
      computedAt: DateTime.parse(map['computedAt'] as String),
      ttlSeconds: map['ttlSeconds'] as int,
    );
  }
}


