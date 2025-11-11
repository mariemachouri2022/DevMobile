import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_service.dart';
import 'app_database.dart';

/// Helper pour gérer les migrations et la compatibilité entre DatabaseService et AppDatabase
class MigrationHelper {
  static final MigrationHelper instance = MigrationHelper._init();

  MigrationHelper._init();

  /// Vérifie si les deux bases de données sont synchronisées
  Future<bool> isDatabasesSynced() async {
    try {
      final dbService = await DatabaseService.instance.database;
      final appDb = await AppDatabase().database;

      // Vérifier si les deux bases pointent vers le même fichier
      return dbService.path == appDb.path;
    } catch (e) {
      print('Erreur lors de la vérification de synchronisation: $e');
      return false;
    }
  }

  /// Force la recréation de la base de données (utilisé pour le développement)
  Future<void> resetDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'smartfit.db');

      // Supprimer l'ancienne base
      await deleteDatabase(path);

      print('Base de données réinitialisée avec succès');
    } catch (e) {
      print('Erreur lors de la réinitialisation de la base de données: $e');
      rethrow;
    }
  }

  /// Vérifie l'intégrité du schéma de la base de données
  Future<Map<String, dynamic>> checkDatabaseIntegrity() async {
    final db = await AppDatabase().database;

    // Vérifier les tables requises
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
    );

    final requiredTables = [
      'users',
      'memberships',
      'payments',
      'coaches',
      'class_sessions',
      'ratings',
      'attendance',
      'user_points',
      'badges',
      'user_badges',
      'gamification_log',
      'coach_client_history',
      'profile_history',
    ];

    final existingTables = tables.map((t) => t['name'] as String).toList();
    final missingTables = requiredTables
        .where((t) => !existingTables.contains(t))
        .toList();

    return {
      'allTablesPresent': missingTables.isEmpty,
      'existingTables': existingTables,
      'missingTables': missingTables,
      'totalTables': existingTables.length,
    };
  }

  /// Récupère le schéma de la table users pour vérification
  Future<List<Map<String, dynamic>>> getUsersTableSchema() async {
    final db = await AppDatabase().database;
    return await db.rawQuery('PRAGMA table_info(users)');
  }

  /// Affiche les informations de debug sur la base de données
  Future<void> printDatabaseInfo() async {
    print('=== Informations de la base de données ===');

    final integrity = await checkDatabaseIntegrity();
    print('Tables présentes: ${integrity['totalTables']}');
    print('Tables existantes: ${integrity['existingTables']}');

    if (integrity['missingTables'].isNotEmpty) {
      print('Tables manquantes: ${integrity['missingTables']}');
    }

    final schema = await getUsersTableSchema();
    print('\nSchéma de la table users:');
    for (final column in schema) {
      print('  - ${column['name']}: ${column['type']}');
    }

    print('==========================================');
  }
}

