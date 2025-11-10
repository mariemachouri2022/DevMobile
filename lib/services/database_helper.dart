import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/planning.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'planning.db');

    return await openDatabase(
      path,
      version: 2, // 🔹 CHANGEZ LA VERSION DE 1 À 2
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE planning(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nomCoach TEXT NOT NULL,
            nomClient TEXT NOT NULL,
            salle TEXT NOT NULL,
            typeSeance TEXT NOT NULL,
            heureDebut TEXT NOT NULL,
            heureFin TEXT NOT NULL,
            dateSeance TEXT NOT NULL, // 🔹 NOUVELLE COLONNE AJOUTÉE
            description TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // 🔹 AJOUTEZ LA MIGRATION POUR LA COLONNE dateSeance
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE planning ADD COLUMN dateSeance TEXT NOT NULL DEFAULT '2024-01-01T00:00:00.000'
          ''');
        }
      },
    );
  }

  // 🔹 Insertion
  Future<int> insertPlanning(Planning planning) async {
    try {
      final db = await database;
      return await db.insert('planning', planning.toMap());
    } catch (e) {
      print('Erreur insertion: $e');
      return -1;
    }
  }

  // 🔹 Récupération de tous les plannings
  Future<List<Planning>> getAllPlannings() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query('planning');
      return result.map((map) => Planning.fromMap(map)).toList();
    } catch (e) {
      print('Erreur récupération: $e');
      return [];
    }
  }

  // 🔹 Récupération par ID
  Future<Planning?> getPlanningById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        'planning',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return Planning.fromMap(result.first);
      }
      return null;
    } catch (e) {
      print('Erreur récupération par ID: $e');
      return null;
    }
  }

  // 🔹 Mise à jour
  Future<int> updatePlanning(Planning planning) async {
    try {
      final db = await database;
      return await db.update(
        'planning',
        planning.toMap(),
        where: 'id = ?',
        whereArgs: [planning.id],
      );
    } catch (e) {
      print('Erreur mise à jour: $e');
      return -1;
    }
  }

  // 🔹 Récupération des séances d'un client spécifique
  Future<List<Planning>> getClientSessions(String clientName) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        'planning',
        where: 'nomClient = ?',
        whereArgs: [clientName],
        orderBy: 'dateSeance ASC, heureDebut ASC',
      );
      return result.map((map) => Planning.fromMap(map)).toList();
    } catch (e) {
      print('Erreur récupération séances client: $e');
      return [];
    }
  }
  Future<List<Planning>> getCoachSessions(String coachName) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        'planning',
        where: 'nomCoach = ?',
        whereArgs: [coachName],
        orderBy: 'dateSeance ASC, heureDebut ASC',
      );
      return result.map((map) => Planning.fromMap(map)).toList();
    } catch (e) {
      print('Erreur récupération séances coach: $e');
      return [];
    }
  }

  // 🔹 Suppression
  Future<int> deletePlanning(int id) async {
    try {
      final db = await database;
      return await db.delete(
          'planning',
          where: 'id = ?',
          whereArgs: [id]
      );
    } catch (e) {
      print('Erreur suppression: $e');
      return -1;
    }
  }

  // 🔹 Fermeture de la base
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}