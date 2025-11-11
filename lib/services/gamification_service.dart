import 'package:smartfit/services/app_database.dart';
import 'package:sqflite/sqflite.dart';


class GamificationService {
  GamificationService._();
  static final GamificationService instance = GamificationService._();

  Future<void> _ensureUser(int userId) async {
    final db = await AppDatabase().database;
    final r = await db.query('user_points', where: 'user_id = ?', whereArgs: [userId], limit: 1);
    if (r.isEmpty) {
      await db.insert('user_points', {'user_id': userId, 'points': 0});
    }
  }

  Future<void> ensureDefaultBadges() async {
    final db = await AppDatabase().database;
    final r = await db.query('badges', limit: 1);
    if (r.isEmpty) {
      await db.insert('badges', {'code': 'starter', 'name': 'Starter', 'threshold': 10});
      await db.insert('badges', {'code': 'regular', 'name': 'Regular', 'threshold': 25});
      await db.insert('badges', {'code': 'pro', 'name': 'Pro', 'threshold': 50});
    }
  }

  Future<int> getPoints(int userId) async {
    await _ensureUser(userId);
    final db = await AppDatabase().database;
    final r = await db.query('user_points', where: 'user_id = ?', whereArgs: [userId], limit: 1);
    return (r.first['points'] as int?) ?? 0;
  }

  Future<void> addPoints(int userId, int delta) async {
    await _ensureUser(userId);
    final db = await AppDatabase().database;
    await db.rawUpdate('UPDATE user_points SET points = points + ? WHERE user_id = ?', [delta, userId]);
    await checkAndAwardBadges(userId);
  }

  Future<List<Map<String, Object?>>> listUserBadges(int userId) async {
    final db = await AppDatabase().database;
    return db.rawQuery('''
      SELECT b.id, b.code, b.name, b.threshold, ub.awarded_at
      FROM user_badges ub
      JOIN badges b ON b.id = ub.badge_id
      WHERE ub.user_id = ?
      ORDER BY b.threshold ASC
    ''', [userId]);
  }

  Future<void> checkAndAwardBadges(int userId) async {
    await ensureDefaultBadges();
    final db = await AppDatabase().database;
    final r = await db.query('user_points', where: 'user_id = ?', whereArgs: [userId], limit: 1);
    final points = (r.first['points'] as int?) ?? 0;
    final rows = await db.rawQuery('''
      SELECT id FROM badges WHERE threshold <= ? AND id NOT IN (
        SELECT badge_id FROM user_badges WHERE user_id = ?
      )
    ''', [points, userId]);
    final now = DateTime.now().toIso8601String();
    for (final row in rows) {
      final badgeId = row['id'] as int;
      await db.insert('user_badges', {
        'user_id': userId,
        'badge_id': badgeId,
        'awarded_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> onAttendance(int userId) async {
    await addPoints(userId, 5);
  }

  Future<bool> canClaimDaily(int userId) async {
    final db = await AppDatabase().database;
    final today = DateTime.now();
    final dateKey = DateTime(today.year, today.month, today.day).toIso8601String().split('T').first;
    final r = await db.query('gamification_log', where: 'user_id = ? AND type = ? AND date = ?', whereArgs: [userId, 'daily', dateKey], limit: 1);
    return r.isEmpty;
  }

  Future<bool> claimDailyChallenge(int userId, {int points = 10}) async {
    final db = await AppDatabase().database;
    final today = DateTime.now();
    final dateKey = DateTime(today.year, today.month, today.day).toIso8601String().split('T').first;
    try {
      await db.insert('gamification_log', {
        'user_id': userId,
        'type': 'daily',
        'date': dateKey,
      });
    } catch (_) {
      return false; // already claimed
    }
    await addPoints(userId, points);
    return true;
  }
}
