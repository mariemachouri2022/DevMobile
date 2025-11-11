

import 'package:smartfit/models/rating.dart';
import 'package:smartfit/services/app_database.dart';

class RatingsService {
  RatingsService._();
  static final RatingsService instance = RatingsService._();

  Future<Rating> addRating({required int userId, int? coachId, int? classId, required int stars, String? comment}) async {
    final db = await AppDatabase().database;
    int id;
    try {
      id = await db.insert('ratings', {
        'user_id': userId,
        'coach_id': coachId,
        'class_id': classId,
        'stars': stars,
        'comment': comment,
        'date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Likely uniqueness violation (already rated)
      throw Exception('Already rated');
    }

    if (coachId != null) {
      await db.execute('''
        UPDATE coaches SET rating_avg = (
          SELECT AVG(stars) FROM ratings WHERE coach_id = ?
        ) WHERE id = ?
      ''', [coachId, coachId]);
    }

    return Rating(id: id, userId: userId, coachId: coachId, classId: classId, stars: stars, comment: comment, date: DateTime.now());
  }

  Future<bool> hasRatedClass(int userId, int classId) async {
    final db = await AppDatabase().database;
    final r = await db.query('ratings', where: 'user_id = ? AND class_id = ?', whereArgs: [userId, classId], limit: 1);
    return r.isNotEmpty;
  }

  Future<bool> hasRatedCoach(int userId, int coachId) async {
    final db = await AppDatabase().database;
    final r = await db.query('ratings', where: 'user_id = ? AND coach_id = ?', whereArgs: [userId, coachId], limit: 1);
    return r.isNotEmpty;
  }

  Future<Set<int>> listRatedClassIds(int userId) async {
    final db = await AppDatabase().database;
    final rows = await db.rawQuery('SELECT class_id FROM ratings WHERE user_id = ? AND class_id IS NOT NULL', [userId]);
    return rows.map((e) => (e['class_id'] as int)).toSet();
  }

  Future<Set<int>> listRatedCoachIds(int userId) async {
    final db = await AppDatabase().database;
    final rows = await db.rawQuery('SELECT coach_id FROM ratings WHERE user_id = ? AND coach_id IS NOT NULL', [userId]);
    return rows.map((e) => (e['coach_id'] as int)).toSet();
  }
}
