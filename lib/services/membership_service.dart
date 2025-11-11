import 'package:uuid/uuid.dart';
import 'package:smartfit/models/membership.dart';
import 'package:smartfit/services/app_database.dart';

class MembershipService {
  MembershipService._();
  static final MembershipService instance = MembershipService._();
  final _uuid = const Uuid();

  Future<Membership?> getActiveMembership(int userId) async {
    final db = await AppDatabase().database;
    final nowIso = DateTime.now().toIso8601String();
    final rows = await db.query(
      'memberships',
      where: 'user_id = ? AND status = ? AND end_date > ?',
      whereArgs: [userId, 'active', nowIso],
      orderBy: 'end_date DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Membership.fromMap(rows.first);
  }

  Future<Membership> createMembership({
    required int userId,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await AppDatabase().database;
    final qr = _uuid.v4();
    final id = await db.insert('memberships', {
      'user_id': userId,
      'type': type,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': 'active',
      'qr_code': qr,
    });
    return Membership(
      id: id,
      userId: userId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      status: 'active',
      qrCode: qr,
    );
  }

  Future<void> updateStatus(int membershipId, String status) async {
    final db = await AppDatabase().database;
    await db.update(
      'memberships',
      {'status': status},
      where: 'id = ?',
      whereArgs: [membershipId],
    );
  }

  Future<List<Membership>> historyForUser(int userId) async {
    final db = await AppDatabase().database;
    final rows = await db.query(
      'memberships',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_date DESC',
    );
    return rows.map((e) => Membership.fromMap(e)).toList();
  }

  Future<bool> isExpiringSoon(Membership m, {int days = 7}) async {
    final threshold = DateTime.now().add(Duration(days: days));
    return m.endDate.isBefore(threshold) && m.endDate.isAfter(DateTime.now());
  }

  Future<Membership?> getByQr(String qr) async {
    final db = await AppDatabase().database;
    final rows = await db.query(
      'memberships',
      where: 'qr_code = ?',
      whereArgs: [qr],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Membership.fromMap(rows.first);
  }

  Future<void> renew({
    required int membershipId,
    required DateTime newEndDate,
  }) async {
    final db = await AppDatabase().database;
    await db.update(
      'memberships',
      {'end_date': newEndDate.toIso8601String(), 'status': 'active'},
      where: 'id = ?',
      whereArgs: [membershipId],
    );
  }

  Future<void> suspend(int membershipId) =>
      updateStatus(membershipId, 'suspended');
  Future<void> cancel(int membershipId) =>
      updateStatus(membershipId, 'cancelled');

  // Get all memberships for admin view
  Future<List<Membership>> getAllMemberships() async {
    final db = await AppDatabase().database;
    final rows = await db.query(
      'memberships',
      orderBy: 'start_date DESC',
    );
    return rows.map((e) => Membership.fromMap(e)).toList();
  }

  // Get memberships by status
  Future<List<Membership>> getMembershipsByStatus(String status) async {
    final db = await AppDatabase().database;
    final rows = await db.query(
      'memberships',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'start_date DESC',
    );
    return rows.map((e) => Membership.fromMap(e)).toList();
  }
}
