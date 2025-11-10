import 'package:sqflite/sqflite.dart';
import '../models/meal_model.dart';
import '../models/plan_stats_cache.dart';
import 'database_service.dart';

class NutritionDatabaseService {
  static final NutritionDatabaseService instance =
      NutritionDatabaseService._init();
  static Database? _database;

  NutritionDatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await DatabaseService.instance.database;
    return _database!;
  }

  // Initialize nutrition tables (called from main database service)
  static Future<void> initializeTables(Database db) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const intType = 'INTEGER NOT NULL';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';
    const realType = 'REAL NOT NULL DEFAULT 0';

    // Create meals table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS meals (
        id $idType,
        userId $intType,
        day $textType,
        mealType $textType,
        name $textType,
        calories $realType,
        proteins $realType,
        carbs $realType,
        fats $realType,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        isTemplate INTEGER NOT NULL DEFAULT 0,
        note $textTypeNull,
        createdAt $textTypeNull DEFAULT CURRENT_TIMESTAMP,
        updatedAt $textTypeNull DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_meals_user_day ON meals(userId, day)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_meals_day ON meals(day)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_meals_fav ON meals(isFavorite)');

    // Create plan_stats_cache table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS plan_stats_cache (
        id $idType,
        userId $intType,
        day $textType,
        totalCalories $realType,
        totalProteins $realType,
        totalCarbs $realType,
        totalFats $realType,
        computedAt $textTypeNull DEFAULT CURRENT_TIMESTAMP,
        weekStart $textType,
        ttlSeconds INTEGER NOT NULL DEFAULT 86400,
        UNIQUE(userId, day),
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_psc_user_day ON plan_stats_cache(userId, day)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_psc_user_week ON plan_stats_cache(userId, weekStart)');
  }

  // Migration for nutrition tables
  static Future<void> migrateNutritionTables(
      Database db, int oldVersion) async {
    if (oldVersion < 4) {
      // Nutrition: meals + plan_stats_cache
      await db.execute('''
        CREATE TABLE IF NOT EXISTS meals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          day TEXT NOT NULL,
          mealType TEXT NOT NULL,
          name TEXT NOT NULL,
          calories REAL NOT NULL DEFAULT 0,
          proteins REAL NOT NULL DEFAULT 0,
          carbs REAL NOT NULL DEFAULT 0,
          fats REAL NOT NULL DEFAULT 0,
          isFavorite INTEGER NOT NULL DEFAULT 0,
          isTemplate INTEGER NOT NULL DEFAULT 0,
          note TEXT,
          createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
          updatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_meals_user_day ON meals(userId, day)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_meals_day ON meals(day)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_meals_fav ON meals(isFavorite)');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS plan_stats_cache (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          day TEXT NOT NULL,
          totalCalories REAL NOT NULL DEFAULT 0,
          totalProteins REAL NOT NULL DEFAULT 0,
          totalCarbs REAL NOT NULL DEFAULT 0,
          totalFats REAL NOT NULL DEFAULT 0,
          computedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          weekStart TEXT NOT NULL,
          ttlSeconds INTEGER NOT NULL DEFAULT 86400,
          UNIQUE(userId, day),
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_psc_user_day ON plan_stats_cache(userId, day)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_psc_user_week ON plan_stats_cache(userId, weekStart)');
    }
  }

  // ---------- Nutrition: Meals & Stats Cache ----------

  Future<int> addMeal(Meal meal) async {
    final db = await database;
    final id = await db.insert('meals', meal.toMap());
    return id;
  }

  Future<int> updateMeal(Meal meal) async {
    final db = await database;
    return await db.update(
      'meals',
      meal.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [meal.id],
    );
  }

  Future<int> deleteMeal(int mealId) async {
    final db = await database;
    return await db.delete('meals', where: 'id = ?', whereArgs: [mealId]);
  }

  Future<List<Meal>> getMealsByDay(int userId, String day) async {
    final db = await database;
    final rows = await db.query(
      'meals',
      where: 'userId = ? AND day = ?',
      whereArgs: [userId, day],
      orderBy: 'createdAt ASC',
    );
    return rows.map((e) => Meal.fromMap(e)).toList();
  }

  Future<List<Meal>> getFavoriteMeals(int userId) async {
    final db = await database;
    final rows = await db.query(
      'meals',
      where: 'userId = ? AND isFavorite = 1',
      whereArgs: [userId],
      orderBy: 'updatedAt DESC',
    );
    return rows.map((e) => Meal.fromMap(e)).toList();
  }

  // Upsert cache for a day based on meals
  Future<void> refreshDayCache({
    required int userId,
    required String day,
    required String weekStart,
  }) async {
    final db = await database;
    // SQLite doesn't support INSERT ... ON CONFLICT directly in rawInsert
    // So we use a workaround: DELETE then INSERT
    await db.execute(
        'DELETE FROM plan_stats_cache WHERE userId = ? AND day = ?',
        [userId, day]);

    final result = await db.rawQuery('''
      SELECT
        IFNULL(SUM(calories), 0) AS totalCalories,
        IFNULL(SUM(proteins), 0) AS totalProteins,
        IFNULL(SUM(carbs), 0) AS totalCarbs,
        IFNULL(SUM(fats), 0) AS totalFats
      FROM meals
      WHERE userId = ? AND day = ?
    ''', [userId, day]);

    final row = result.first;
    await db.insert('plan_stats_cache', {
      'userId': userId,
      'day': day,
      'weekStart': weekStart,
      'totalCalories': (row['totalCalories'] as num?)?.toDouble() ?? 0.0,
      'totalProteins': (row['totalProteins'] as num?)?.toDouble() ?? 0.0,
      'totalCarbs': (row['totalCarbs'] as num?)?.toDouble() ?? 0.0,
      'totalFats': (row['totalFats'] as num?)?.toDouble() ?? 0.0,
      'computedAt': DateTime.now().toIso8601String(),
      'ttlSeconds': 86400,
    });
  }

  Future<PlanStatsCache?> getCachedDay(int userId, String day) async {
    final db = await database;
    final rows = await db.query(
      'plan_stats_cache',
      where: 'userId = ? AND day = ?',
      whereArgs: [userId, day],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PlanStatsCache.fromMap(rows.first);
  }

  Future<List<Map<String, dynamic>>> getCalories7d(
      int userId, String endDayInclusive) async {
    final db = await database;
    final endDate = DateTime.parse(endDayInclusive);
    final startDate = endDate.subtract(const Duration(days: 6));
    final start = _dateKey(startDate);
    final end = _dateKey(endDate);

    final rows = await db.rawQuery('''
      SELECT day, totalCalories
      FROM plan_stats_cache
      WHERE userId = ? AND day >= ? AND day <= ?
      ORDER BY day ASC
    ''', [userId, start, end]);

    // Fill in missing days with 0
    final lookup = {
      for (final row in rows)
        row['day'] as String: (row['totalCalories'] as num?)?.toDouble() ?? 0.0,
    };

    final results = <Map<String, dynamic>>[];
    for (var i = 0; i < 7; i++) {
      final current = startDate.add(Duration(days: i));
      final key = _dateKey(current);
      results.add({
        'day': key,
        'totalCalories': lookup[key] ?? 0.0,
      });
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> getMacros7d(
      int userId, String endDayInclusive) async {
    final db = await database;
    final endDate = DateTime.parse(endDayInclusive);
    final startDate = endDate.subtract(const Duration(days: 6));
    final start = _dateKey(startDate);
    final end = _dateKey(endDate);

    final rows = await db.rawQuery('''
      SELECT day, totalProteins, totalCarbs, totalFats
      FROM plan_stats_cache
      WHERE userId = ? AND day >= ? AND day <= ?
      ORDER BY day ASC
    ''', [userId, start, end]);

    // Fill in missing days with 0
    final lookup = {
      for (final row in rows)
        row['day'] as String: {
          'totalProteins': (row['totalProteins'] as num?)?.toDouble() ?? 0.0,
          'totalCarbs': (row['totalCarbs'] as num?)?.toDouble() ?? 0.0,
          'totalFats': (row['totalFats'] as num?)?.toDouble() ?? 0.0,
        },
    };

    final results = <Map<String, dynamic>>[];
    for (var i = 0; i < 7; i++) {
      final current = startDate.add(Duration(days: i));
      final key = _dateKey(current);
      final data = lookup[key];
      results.add({
        'day': key,
        'totalProteins': data?['totalProteins'] ?? 0.0,
        'totalCarbs': data?['totalCarbs'] ?? 0.0,
        'totalFats': data?['totalFats'] ?? 0.0,
      });
    }
    return results;
  }

  Future<Map<String, num>> getWeeklyAverages(
      int userId, String weekStart) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT
        AVG(totalCalories) AS avgCalories,
        AVG(totalProteins) AS avgProteins,
        AVG(totalCarbs) AS avgCarbs,
        AVG(totalFats) AS avgFats
      FROM plan_stats_cache
      WHERE userId = ? AND weekStart = ?
    ''', [userId, weekStart]);

    if (rows.isEmpty || rows.first.values.every((value) => value == null)) {
      return const {
        'avgCalories': 0,
        'avgProteins': 0,
        'avgCarbs': 0,
        'avgFats': 0,
      };
    }

    final r = rows.first;
    return {
      'avgCalories': (r['avgCalories'] as num?) ?? 0,
      'avgProteins': (r['avgProteins'] as num?) ?? 0,
      'avgCarbs': (r['avgCarbs'] as num?) ?? 0,
      'avgFats': (r['avgFats'] as num?) ?? 0,
    };
  }

  String _dateKey(DateTime value) {
    final normalized = DateTime(value.year, value.month, value.day);
    return normalized.toIso8601String().substring(0, 10);
  }
}

