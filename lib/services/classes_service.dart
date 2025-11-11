import 'package:flutter/material.dart';
import 'package:smartfit/models/class_session.dart';
import 'package:smartfit/services/app_database.dart';


class ClassesService {
  ClassesService._();
  static final ClassesService instance = ClassesService._();

  Future<List<ClassSession>> list({String? intensity, String? objective, int? coachId, DateTime? from, DateTime? to}) async {
    final db = await AppDatabase().database;
    final where = <String>[];
    final args = <Object?>[];
    if (intensity != null) { where.add('intensity = ?'); args.add(intensity); }
    if (objective != null) { where.add('objective = ?'); args.add(objective); }
    if (coachId != null) { where.add('coach_id = ?'); args.add(coachId); }
    if (from != null) { where.add('start_time >= ?'); args.add(from.toIso8601String()); }
    if (to != null) { where.add('end_time <= ?'); args.add(to.toIso8601String()); }
    final rows = await db.query('class_sessions', where: where.isEmpty ? null : where.join(' AND '), whereArgs: args, orderBy: 'start_time ASC');
    return rows.map((e) => ClassSession.fromMap(e)).toList();
  }

  Future<int> add({int? coachId, required String title, String? intensity, String? objective, required DateTime startTime, required DateTime endTime, int? capacity}) async {
    final db = await AppDatabase().database;
    return await db.insert('class_sessions', {
      'coach_id': coachId,
      'title': title,
      'intensity': intensity,
      'objective': objective,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'capacity': capacity,
    });
  }

  Future<void> addBatchDates({int? coachId, required String title, String? intensity, String? objective, required DateTime startDate, required DateTime endDate, required TimeOfDay startTime, required TimeOfDay endTime, int? capacity}) async {
    final db = await AppDatabase().database;
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    for (DateTime d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      final st = DateTime(d.year, d.month, d.day, startTime.hour, startTime.minute);
      final et = DateTime(d.year, d.month, d.day, endTime.hour, endTime.minute);
      await db.insert('class_sessions', {
        'coach_id': coachId,
        'title': title,
        'intensity': intensity,
        'objective': objective,
        'start_time': st.toIso8601String(),
        'end_time': et.toIso8601String(),
        'capacity': capacity,
      });
    }
  }
}
