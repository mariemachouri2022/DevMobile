import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // singleton factory
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // 🔹 Accès unique à la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // 🧱 Initialisation de la base
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'materiel_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // 📦 Création des tables
  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const textTypeNotNull = 'TEXT NOT NULL';

    // Table des équipements
    await db.execute('''
      CREATE TABLE equipements (
        id $idType,
        nom $textTypeNotNull,
        type $textType,
        localisation $textType,
        etat $textType,
        dateAjout $textType,
        derniereModification $textType
      )
    ''');

    // Table de l'historique
    await db.execute('''
      CREATE TABLE historique (
        id $idType,
        equipementId INTEGER NOT NULL,
        ancienEtat $textType,
        nouvelEtat $textType,
        dateChangement $textType,
        commentaire $textType,
        FOREIGN KEY (equipementId) REFERENCES equipements (id) ON DELETE CASCADE
      )
    ''');

    // Table des signalements
    await db.execute('''
      CREATE TABLE signalements (
        id $idType,
        equipementId INTEGER NOT NULL,
        description $textTypeNotNull,
        dateSignalement $textType,
        statut $textType DEFAULT 'en attente',
        FOREIGN KEY (equipementId) REFERENCES equipements (id) ON DELETE CASCADE
      )
    ''');

    // ✅ Donnée initiale (optionnelle)
  }

  // ----------------------------------------------------------
  // 🔹 CRUD - Équipements
  // ----------------------------------------------------------

  // Ajout : accepte une Map (flexible)
  Future<int> addEquipment(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('equipements', data);
  }

  // Alias (compatibilité noms FR)
  Future<int> ajouterEquipement(Map<String, dynamic> data) => addEquipment(data);

  // Récupérer tous les équipements
  Future<List<Map<String, dynamic>>> getEquipments() async {
    final db = await database;
    return await db.query('equipements');
  }

  // Alias FR
  Future<List<Map<String, dynamic>>> getTousLesEquipements() => getEquipments();

  Future<int> updateEquipment(int id, Map<String, dynamic> newValues) async {
    final db = await database;
    return await db.update(
      'equipements',
      newValues,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> mettreAJourEquipement(int id, Map<String, dynamic> nouvellesValeurs) =>
      updateEquipment(id, nouvellesValeurs);

  Future<int> deleteEquipment(int id) async {
    final db = await database;
    return await db.delete('equipements', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> supprimerEquipement(int id) => deleteEquipment(id);

  // ----------------------------------------------------------
  // 🕒 Historique
  // ----------------------------------------------------------

  Future<void> addHistorique(int equipementId, String ancienEtat, String nouvelEtat, String commentaire) async {
    final db = await database;
    await db.insert('historique', {
      'equipementId': equipementId,
      'ancienEtat': ancienEtat,
      'nouvelEtat': nouvelEtat,
      'dateChangement': DateTime.now().toIso8601String(),
      'commentaire': commentaire,
    });
  }

  // Alias FR
  Future<void> enregistrerChangementEtat(int equipementId, String ancienEtat, String nouvelEtat, String commentaire) =>
      addHistorique(equipementId, ancienEtat, nouvelEtat, commentaire);

  Future<List<Map<String, dynamic>>> getHistoriqueByEquipement(int id) async {
    final db = await database;
    return await db.query(
      'historique',
      where: 'equipementId = ?',
      whereArgs: [id],
      orderBy: 'dateChangement DESC',
    );
  }

  // Alias FR pour compatibilité avec ton code
  Future<List<Map<String, dynamic>>> getHistoriqueParEquipement(int id) =>
      getHistoriqueByEquipement(id);

  // ----------------------------------------------------------
  // 🚨 Signalements
  // ----------------------------------------------------------

  Future<int> signalerPanne(int equipementId, String description) async {
    final db = await database;
    return await db.insert('signalements', {
      'equipementId': equipementId,
      'description': description,
      'dateSignalement': DateTime.now().toIso8601String(),
      'statut': 'en attente',
    });
  }

  // Alias FR
  Future<int> ajouterSignalement(int equipementId, String description) =>
      signalerPanne(equipementId, description);

  Future<List<Map<String, dynamic>>> getSignalements() async {
    final db = await database;
    return await db.query('signalements', orderBy: 'dateSignalement DESC');
  }

  // Alias FR attendu par ton code
  Future<List<Map<String, dynamic>>> getTousLesSignalements() => getSignalements();

  Future<int> updateStatutSignalement(int id, String nouveauStatut) async {
    final db = await database;
    return await db.update(
      'signalements',
      {'statut': nouveauStatut},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> mettreAJourStatutSignalement(int id, String nouveauStatut) =>
      updateStatutSignalement(id, nouveauStatut);

  Future<void> closeDB() async {
    final db = await database;
    db.close();
  }
}
