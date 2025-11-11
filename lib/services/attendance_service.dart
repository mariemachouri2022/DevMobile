
import 'package:smartfit/models/attendance.dart';
import 'package:smartfit/services/app_database.dart';

import 'gamification_service.dart';

class AttendanceService {
  AttendanceService._();
  static final AttendanceService instance = AttendanceService._();

  Future<Attendance> markAttendance({required int userId, int? classId, bool viaQr = true}) async {
    final db = await AppDatabase().database;
    final id = await db.insert('attendance', {
      'user_id': userId,
      'class_id': classId,
      'date': DateTime.now().toIso8601String(),
      'via_qr': viaQr ? 1 : 0,
    });
    await GamificationService.instance.onAttendance(userId);
    return Attendance(id: id, userId: userId, classId: classId, date: DateTime.now(), viaQr: viaQr);
  }

  Future<int> totalAttendanceCount() async {
    final db = await AppDatabase().database;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM attendance');
    return (result.first['c'] as int?) ?? 0;
  }
}
