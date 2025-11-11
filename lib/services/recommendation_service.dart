
import 'package:smartfit/models/class_session.dart';
import 'package:smartfit/models/user_model.dart';
import 'package:smartfit/services/app_database.dart';

import 'ai_service.dart';

class RecommendationService {
  RecommendationService._();
  static final RecommendationService instance = RecommendationService._();

  Future<List<ClassSession>> recommendFor(UserModel user, {int limit = 3}) async {
    final db = await AppDatabase().database;
    // Try AI to infer filters first
    Map<String, String>? ai;
    try { ai = await AIService.instance.recommendFilters(age: user.age, goals: ''); } catch (_) { ai = null; }
    String? objective = ai?['objective'];
    String? intensity = ai?['intensity'];
    // Fallback heuristic if AI not available
    if (objective == null || intensity == null) {
      if (objective == null) {
        objective = 'Fitness'; // Default objective
      }
      if (intensity == null) {
        final age = user.age;
        if (age < 30) intensity = 'high';
        else if (age <= 45) intensity = 'medium';
        else intensity = 'low';
      }
    }

    final nowIso = DateTime.now().toIso8601String();
    final where = <String>["start_time >= ?"];
    final args = <Object?>[nowIso];
    where.add('objective = ?');
    args.add(objective);
    where.add('intensity = ?');
    args.add(intensity);

    final rows = await db.query('class_sessions',
      where: where.join(' AND '), whereArgs: args, orderBy: 'start_time ASC', limit: limit);
    return rows.map((e) => ClassSession.fromMap(e)).toList();
  }
}
