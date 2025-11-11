

import 'package:smartfit/models/coach.dart';
import 'package:smartfit/services/app_database.dart';

class CoachesService {
  CoachesService._();
  static final CoachesService instance = CoachesService._();

  Future<List<Coach>> list() async {
    final db = await AppDatabase().database;
    final rows = await db.query('coaches', orderBy: 'name ASC');
    return rows.map((e) => Coach.fromMap(e)).toList();
  }

  Future<int> add({required String name, String? bio}) async {
    final db = await AppDatabase().database;
    return await db.insert('coaches', {
      'name': name,
      'bio': bio,
      'rating_avg': 0,
    });
  }
}
