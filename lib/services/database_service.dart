import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smartfit.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4, // Incremented to force re-migration
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // Migration system - handles database upgrades
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for advanced features
      // Note: SQLite doesn't allow DEFAULT CURRENT_TIMESTAMP in ALTER TABLE
      // So we use a fixed default value instead
      await db.execute(
        'ALTER TABLE users ADD COLUMN lastModified TEXT DEFAULT NULL',
      );
      await db.execute(
        'ALTER TABLE users ADD COLUMN createdAt TEXT DEFAULT NULL',
      );
      await db.execute(
        'ALTER TABLE users ADD COLUMN isActive INTEGER DEFAULT 1',
      );

      // Update existing rows with current timestamp
      final now = DateTime.now().toIso8601String();
      await db.execute('''
        UPDATE users 
        SET lastModified = '$now', createdAt = '$now'
        WHERE lastModified IS NULL
      ''');
    }

    if (oldVersion < 3) {
      // Create history tables if they don't exist
      const textType = 'TEXT NOT NULL';
      const textTypeNull = 'TEXT';
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';

      // Coach-Client association history table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS coach_client_history (
          id $idType,
          clientId INTEGER NOT NULL,
          coachId INTEGER NOT NULL,
          assignedAt $textTypeNull,
          unassignedAt $textTypeNull,
          isActive INTEGER DEFAULT 1,
          FOREIGN KEY (clientId) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (coachId) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      // Profile modifications history table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS profile_history (
          id $idType,
          userId INTEGER NOT NULL,
          field $textType,
          oldValue $textTypeNull,
          newValue $textTypeNull,
          modifiedAt $textTypeNull,
          modifiedBy INTEGER,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (modifiedBy) REFERENCES users (id) ON DELETE SET NULL
        )
      ''');
    }

    if (oldVersion < 4) {
      // Add profileImagePath column
      await db.execute(
        'ALTER TABLE users ADD COLUMN profileImagePath TEXT DEFAULT NULL',
      );
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const textTypeNull = 'TEXT';

    // Users table with advanced fields
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        firstName $textType,
        age $intType,
        phone $textType,
        email $textType UNIQUE,
        password $textType,
        role $textType,
        coachId INTEGER,
        profileImagePath $textTypeNull,
        lastModified $textTypeNull DEFAULT CURRENT_TIMESTAMP,
        createdAt $textTypeNull DEFAULT CURRENT_TIMESTAMP,
        isActive INTEGER DEFAULT 1,
        FOREIGN KEY (coachId) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

    // Coach-Client association history table
    await db.execute('''
      CREATE TABLE coach_client_history (
        id $idType,
        clientId INTEGER NOT NULL,
        coachId INTEGER NOT NULL,
        assignedAt $textTypeNull DEFAULT CURRENT_TIMESTAMP,
        unassignedAt $textTypeNull,
        isActive INTEGER DEFAULT 1,
        FOREIGN KEY (clientId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (coachId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Profile modifications history table
    await db.execute('''
      CREATE TABLE profile_history (
        id $idType,
        userId INTEGER NOT NULL,
        field $textType,
        oldValue $textTypeNull,
        newValue $textTypeNull,
        modifiedAt $textTypeNull DEFAULT CURRENT_TIMESTAMP,
        modifiedBy INTEGER,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (modifiedBy) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

    // Create default admin user
    await db.insert('users', {
      'name': 'Admin',
      'firstName': 'Super',
      'age': 30,
      'phone': '0000000000',
      'email': 'admin@smartfit.com',
      'password': 'admin123',
      'role': 'admin',
      'coachId': null,
      'createdAt': DateTime.now().toIso8601String(),
      'lastModified': DateTime.now().toIso8601String(),
      'isActive': 1,
    });
  }

  // CRUD Operations for Users

  Future<int> createUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users', orderBy: 'name ASC');
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [role.toString().split('.').last],
      orderBy: 'name ASC',
    );
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<List<UserModel>> getClientsByCoach(int coachId) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'coachId = ? AND role = ?',
      whereArgs: [coachId, 'client'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;

    // Get old user data for history tracking
    final oldUser = await getUserById(user.id!);
    if (oldUser != null) {
      // Track changes
      if (oldUser.name != user.name) {
        await recordProfileChange(
          user.id!,
          'name',
          oldUser.name,
          user.name,
          null,
        );
      }
      if (oldUser.firstName != user.firstName) {
        await recordProfileChange(
          user.id!,
          'firstName',
          oldUser.firstName,
          user.firstName,
          null,
        );
      }
      if (oldUser.age != user.age) {
        await recordProfileChange(
          user.id!,
          'age',
          oldUser.age.toString(),
          user.age.toString(),
          null,
        );
      }
      if (oldUser.phone != user.phone) {
        await recordProfileChange(
          user.id!,
          'phone',
          oldUser.phone,
          user.phone,
          null,
        );
      }
      if (oldUser.role != user.role) {
        await recordProfileChange(
          user.id!,
          'role',
          oldUser.role.toString(),
          user.role.toString(),
          null,
        );
      }
    }

    // Update with lastModified timestamp
    final updatedUser = user.copyWith(lastModified: DateTime.now());

    return await db.update(
      'users',
      updatedUser.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    // Soft delete - mark as inactive instead of actual deletion
    return await db.update(
      'users',
      {'isActive': 0, 'lastModified': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Hard delete (for admin only)
  Future<int> permanentlyDeleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Restore deleted user
  Future<int> restoreUser(int id) async {
    final db = await database;
    return await db.update(
      'users',
      {'isActive': 1, 'lastModified': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Promote user role (client to coach)
  Future<int> promoteUserRole(int userId, UserRole newRole) async {
    final db = await database;

    final user = await getUserById(userId);
    if (user != null) {
      await recordProfileChange(
        userId,
        'role',
        user.role.toString().split('.').last,
        newRole.toString().split('.').last,
        null,
      );
    }

    return await db.update(
      'users',
      {
        'role': newRole.toString().split('.').last,
        'lastModified': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> assignCoachToClient(int clientId, int coachId) async {
    final db = await database;

    // Record in history
    await recordCoachAssignment(clientId, coachId);

    // Update user
    return await db.update(
      'users',
      {'coachId': coachId, 'lastModified': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [clientId],
    );
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'name LIKE ? OR firstName LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  // Advanced SQL queries with JOIN
  Future<List<Map<String, dynamic>>> getCoachesWithClientCount() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        u.id,
        u.name,
        u.firstName,
        u.email,
        u.phone,
        COUNT(c.id) as clientCount
      FROM users u
      LEFT JOIN users c ON u.id = c.coachId
      WHERE u.role = 'coach' AND u.isActive = 1
      GROUP BY u.id
      ORDER BY clientCount DESC, u.name ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> getClientStatistics() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        AVG(age) as averageAge,
        MIN(age) as minAge,
        MAX(age) as maxAge,
        COUNT(*) as totalClients
      FROM users
      WHERE role = 'client' AND isActive = 1
    ''');
  }

  Future<List<Map<String, dynamic>>> getCoachClientRelationships() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        c.id as clientId,
        c.firstName || ' ' || c.name as clientName,
        c.email as clientEmail,
        co.id as coachId,
        co.firstName || ' ' || co.name as coachName,
        co.email as coachEmail,
        cch.assignedAt
      FROM users c
      INNER JOIN users co ON c.coachId = co.id
      LEFT JOIN coach_client_history cch ON c.id = cch.clientId AND co.id = cch.coachId AND cch.isActive = 1
      WHERE c.role = 'client' AND c.isActive = 1
      ORDER BY co.name ASC, c.name ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> getRecentlyModifiedUsers(int limit) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT *
      FROM users
      WHERE isActive = 1
      ORDER BY lastModified DESC
      LIMIT ?
    ''',
      [limit],
    );
  }

  Future<List<Map<String, dynamic>>> getUsersByAgeRange(
    int minAge,
    int maxAge,
  ) async {
    final db = await database;
    return await db.query(
      'users',
      where: 'age BETWEEN ? AND ? AND isActive = 1',
      whereArgs: [minAge, maxAge],
      orderBy: 'age ASC',
    );
  }

  // Profile history tracking
  Future<void> recordProfileChange(
      int userId,
      String field,
      String? oldValue,
      String? newValue,
      int? modifiedBy,
      ) async {
    final db = await database;
    await db.insert('profile_history', {
      'userId': userId,
      'field': field,
      'oldValue': oldValue,
      'newValue': newValue,
      'modifiedAt': DateTime.now().toIso8601String(),
      'modifiedBy': modifiedBy,
    });
  }

  Future<List<Map<String, dynamic>>> getProfileHistory(int userId) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT 
        ph.*,
        u.firstName || ' ' || u.name as modifiedByName
      FROM profile_history ph
      LEFT JOIN users u ON ph.modifiedBy = u.id
      WHERE ph.userId = ?
      ORDER BY ph.modifiedAt DESC
    ''',
      [userId],
    );
  }

  // Coach-client history tracking
  Future<void> recordCoachAssignment(int clientId, int coachId) async {
    final db = await database;

    // Deactivate previous assignments
    await db.update(
      'coach_client_history',
      {'isActive': 0, 'unassignedAt': DateTime.now().toIso8601String()},
      where: 'clientId = ? AND isActive = 1',
      whereArgs: [clientId],
    );

    // Create new assignment
    await db.insert('coach_client_history', {
      'clientId': clientId,
      'coachId': coachId,
      'assignedAt': DateTime.now().toIso8601String(),
      'isActive': 1,
    });
  }

  Future<List<Map<String, dynamic>>> getCoachAssignmentHistory(
    int clientId,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT 
        cch.*,
        u.firstName || ' ' || u.name as coachName,
        u.email as coachEmail
      FROM coach_client_history cch
      INNER JOIN users u ON cch.coachId = u.id
      WHERE cch.clientId = ?
      ORDER BY cch.assignedAt DESC
    ''',
      [clientId],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}