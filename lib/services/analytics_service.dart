
import 'package:smartfit/services/app_database.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  Future<int> activeSubscribers() async {
    final db = await AppDatabase().database;
    final now = DateTime.now().toIso8601String();
    final r = await db.rawQuery("SELECT COUNT(DISTINCT user_id) as c FROM memberships WHERE status='active' AND end_date > ?", [now]);
    return (r.first['c'] as int?) ?? 0;
    }

  Future<double> totalRevenue() async {
    final db = await AppDatabase().database;
    final r = await db.rawQuery("SELECT SUM(amount) as s FROM payments WHERE status='paid'");
    final v = r.first['s'];
    if (v == null) return 0.0;
    if (v is int) return v.toDouble();
    return v as double;
  }

  Future<int> totalAttendance() async {
    final db = await AppDatabase().database;
    final r = await db.rawQuery("SELECT COUNT(*) as c FROM attendance");
    return (r.first['c'] as int?) ?? 0;
  }

  Future<List<Map<String, Object?>>> topRatedCoaches({int limit = 5}) async {
    final db = await AppDatabase().database;
    return db.rawQuery("SELECT id, name, rating_avg FROM coaches ORDER BY rating_avg DESC LIMIT $limit");
  }

  Future<double> averageClassRating() async {
    final db = await AppDatabase().database;
    final r = await db.rawQuery("SELECT AVG(stars) as avg FROM ratings WHERE class_id IS NOT NULL");
    final v = r.first['avg'];
    if (v == null) return 0.0;
    if (v is int) return v.toDouble();
    return v as double;
  }

  Future<List<Map<String, Object?>>> recentClassRatings({int limit = 10}) async {
    final db = await AppDatabase().database;
    return db.rawQuery('''
      SELECT r.stars, r.comment, r.date, cs.title as class_title
      FROM ratings r
      LEFT JOIN class_sessions cs ON cs.id = r.class_id
      WHERE r.class_id IS NOT NULL
      ORDER BY r.date DESC
      LIMIT $limit
    ''');
  }
}
