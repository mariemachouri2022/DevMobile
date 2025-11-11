import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._();
  AppDatabase._();
  factory AppDatabase() => _instance;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'smartfit.db');
    final db = await openDatabase(path, version: 4, onCreate: _onCreate, onConfigure: _onConfigure, onUpgrade: _onUpgrade);
    // Ensure all tables exist even if database already exists
    await _ensureAllTablesExist(db);
    return db;
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table compatible with DatabaseService
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        firstName TEXT NOT NULL,
        age INTEGER NOT NULL,
        phone TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL, -- 'admin', 'coach', or 'client'
        coachId INTEGER,
        profileImagePath TEXT,
        lastModified TEXT DEFAULT CURRENT_TIMESTAMP,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        isActive INTEGER DEFAULT 1,
        goals TEXT,
        FOREIGN KEY (coachId) REFERENCES users (id) ON DELETE SET NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE memberships (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL, -- Standard, Student, Family, Premium
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        status TEXT NOT NULL, -- active, suspended, cancelled, expired
        qr_code TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        membership_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL, -- paid, pending
        method TEXT,
        FOREIGN KEY(membership_id) REFERENCES memberships(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE coaches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        bio TEXT,
        rating_avg REAL DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE class_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        coach_id INTEGER,
        title TEXT NOT NULL,
        intensity TEXT, -- low/medium/high
        objective TEXT, -- Cardio/Muscle/Fitness
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        capacity INTEGER,
        FOREIGN KEY(coach_id) REFERENCES coaches(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE ratings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        coach_id INTEGER,
        class_id INTEGER,
        stars INTEGER NOT NULL, -- 1-5
        comment TEXT,
        date TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(coach_id) REFERENCES coaches(id),
        FOREIGN KEY(class_id) REFERENCES class_sessions(id)
      );
    ''');
    // Prevent duplicate ratings per target
    await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS ux_ratings_user_class ON ratings(user_id, class_id) WHERE class_id IS NOT NULL;');
    await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS ux_ratings_user_coach ON ratings(user_id, coach_id) WHERE coach_id IS NOT NULL;');

    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        class_id INTEGER,
        date TEXT NOT NULL,
        via_qr INTEGER DEFAULT 0,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(class_id) REFERENCES class_sessions(id)
      );
    ''');

    // Gamification tables
    await db.execute('''
      CREATE TABLE user_points (
        user_id INTEGER PRIMARY KEY,
        points INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE badges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        threshold INTEGER NOT NULL -- points threshold to earn
      );
    ''');

    await db.execute('''
      CREATE TABLE user_badges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        badge_id INTEGER NOT NULL,
        awarded_at TEXT NOT NULL,
        UNIQUE(user_id, badge_id),
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(badge_id) REFERENCES badges(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS gamification_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        UNIQUE(user_id, type, date),
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    // Coach-Client association history table (from DatabaseService)
    await db.execute('''
      CREATE TABLE coach_client_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId INTEGER NOT NULL,
        coachId INTEGER NOT NULL,
        assignedAt TEXT DEFAULT CURRENT_TIMESTAMP,
        unassignedAt TEXT,
        isActive INTEGER DEFAULT 1,
        FOREIGN KEY (clientId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (coachId) REFERENCES users (id) ON DELETE CASCADE
      );
    ''');

    // Profile modifications history table (from DatabaseService)
    await db.execute('''
      CREATE TABLE profile_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        field TEXT NOT NULL,
        oldValue TEXT,
        newValue TEXT,
        modifiedAt TEXT DEFAULT CURRENT_TIMESTAMP,
        modifiedBy INTEGER,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (modifiedBy) REFERENCES users (id) ON DELETE SET NULL
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Ensure all tables exist - create them if they don't
    await _ensureAllTablesExist(db);
    
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_points (
          user_id INTEGER PRIMARY KEY,
          points INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS badges (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          code TEXT UNIQUE NOT NULL,
          name TEXT NOT NULL,
          threshold INTEGER NOT NULL
        );
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_badges (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          badge_id INTEGER NOT NULL,
          awarded_at TEXT NOT NULL,
          UNIQUE(user_id, badge_id),
          FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
          FOREIGN KEY(badge_id) REFERENCES badges(id) ON DELETE CASCADE
        );
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS ux_ratings_user_class ON ratings(user_id, class_id) WHERE class_id IS NOT NULL;');
      await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS ux_ratings_user_coach ON ratings(user_id, coach_id) WHERE coach_id IS NOT NULL;');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS gamification_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          type TEXT NOT NULL,
          date TEXT NOT NULL,
          UNIQUE(user_id, type, date),
          FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');
    }
    // Add history tables from DatabaseService
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS coach_client_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          clientId INTEGER NOT NULL,
          coachId INTEGER NOT NULL,
          assignedAt TEXT DEFAULT CURRENT_TIMESTAMP,
          unassignedAt TEXT,
          isActive INTEGER DEFAULT 1,
          FOREIGN KEY (clientId) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (coachId) REFERENCES users (id) ON DELETE CASCADE
        );
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS profile_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          field TEXT NOT NULL,
          oldValue TEXT,
          newValue TEXT,
          modifiedAt TEXT DEFAULT CURRENT_TIMESTAMP,
          modifiedBy INTEGER,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (modifiedBy) REFERENCES users (id) ON DELETE SET NULL
        );
      ''');

      // Add missing columns to users table if they don't exist
      try {
        await db.execute('ALTER TABLE users ADD COLUMN firstName TEXT DEFAULT "";');
      } catch (e) {
        // Column already exists
      }
      try {
        await db.execute('ALTER TABLE users ADD COLUMN phone TEXT DEFAULT "";');
      } catch (e) {
        // Column already exists
      }
      try {
        await db.execute('ALTER TABLE users ADD COLUMN coachId INTEGER;');
      } catch (e) {
        // Column already exists
      }
      try {
        await db.execute('ALTER TABLE users ADD COLUMN profileImagePath TEXT;');
      } catch (e) {
        // Column already exists
      }
      try {
        await db.execute('ALTER TABLE users ADD COLUMN lastModified TEXT DEFAULT CURRENT_TIMESTAMP;');
      } catch (e) {
        // Column already exists
      }
      try {
        await db.execute('ALTER TABLE users ADD COLUMN isActive INTEGER DEFAULT 1;');
      } catch (e) {
        // Column already exists
      }
    }
  }

  // Ensure all tables exist - useful for fixing missing tables
  Future<void> _ensureAllTablesExist(Database db) async {
    // Create all tables if they don't exist
    await db.execute('''
      CREATE TABLE IF NOT EXISTS memberships (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        status TEXT NOT NULL,
        qr_code TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        membership_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        method TEXT,
        FOREIGN KEY(membership_id) REFERENCES memberships(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS coaches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        bio TEXT,
        rating_avg REAL DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS class_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        coach_id INTEGER,
        title TEXT NOT NULL,
        intensity TEXT,
        objective TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        capacity INTEGER,
        FOREIGN KEY(coach_id) REFERENCES coaches(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ratings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        coach_id INTEGER,
        class_id INTEGER,
        stars INTEGER NOT NULL,
        comment TEXT,
        date TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(coach_id) REFERENCES coaches(id),
        FOREIGN KEY(class_id) REFERENCES class_sessions(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        class_id INTEGER,
        date TEXT NOT NULL,
        via_qr INTEGER DEFAULT 0,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(class_id) REFERENCES class_sessions(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_points (
        user_id INTEGER PRIMARY KEY,
        points INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS badges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        threshold INTEGER NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_badges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        badge_id INTEGER NOT NULL,
        awarded_at TEXT NOT NULL,
        UNIQUE(user_id, badge_id),
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(badge_id) REFERENCES badges(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS gamification_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        UNIQUE(user_id, type, date),
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS coach_client_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId INTEGER NOT NULL,
        coachId INTEGER NOT NULL,
        assignedAt TEXT DEFAULT CURRENT_TIMESTAMP,
        unassignedAt TEXT,
        isActive INTEGER DEFAULT 1,
        FOREIGN KEY (clientId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (coachId) REFERENCES users (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS profile_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        field TEXT NOT NULL,
        oldValue TEXT,
        newValue TEXT,
        modifiedAt TEXT DEFAULT CURRENT_TIMESTAMP,
        modifiedBy INTEGER,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (modifiedBy) REFERENCES users (id) ON DELETE SET NULL
      );
    ''');

    // Create indexes
    await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS ux_ratings_user_class ON ratings(user_id, class_id) WHERE class_id IS NOT NULL;');
    await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS ux_ratings_user_coach ON ratings(user_id, coach_id) WHERE coach_id IS NOT NULL;');
  }
}
