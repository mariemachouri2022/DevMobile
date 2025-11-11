# Migration de gym_manager.db vers planning.db

## 📋 Vue d'ensemble

Toutes les tables ont été centralisées dans une seule base de données : **`planning.db`**

### Tables incluses dans planning.db :
1. ✅ **planning** - Table existante pour la gestion des plannings
2. ✅ **users** - Utilisateurs (réutilise la table existante si présente)
3. ✅ **memberships** - Abonnements
4. ✅ **payments** - Paiements
5. ✅ **coaches** - Coachs
6. ✅ **class_sessions** - Séances de cours
7. ✅ **ratings** - Évaluations
8. ✅ **attendance** - Présences
9. ✅ **user_points** - Points de gamification
10. ✅ **badges** - Badges disponibles
11. ✅ **user_badges** - Badges obtenus par les utilisateurs
12. ✅ **gamification_log** - Journal de gamification

## 🔄 Migration automatique

### Option 1 : Migration au démarrage de l'application

Ajoutez ce code dans votre fichier `main.dart` :

```dart
import 'package:flutter/material.dart';
import 'services/database_migration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Vérifier et effectuer la migration si nécessaire
  if (await DatabaseMigration.needsMigration()) {
    print('🔄 Migration nécessaire - démarrage...');
    await DatabaseMigration.migrateGymManagerToPlanning();
  }
  
  runApp(MyApp());
}
```

### Option 2 : Migration manuelle

Si vous préférez effectuer la migration manuellement :

```dart
import 'services/database_migration.dart';

// Dans votre écran de configuration ou paramètres
ElevatedButton(
  onPressed: () async {
    try {
      await DatabaseMigration.migrateGymManagerToPlanning();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Migration réussie !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur : $e')),
      );
    }
  },
  child: Text('Migrer les données'),
)
```

## 📊 Structure de la base de données

### Table `users`
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL,  -- 'admin' or 'member'
  age INTEGER,
  goals TEXT,
  created_at TEXT NOT NULL
)
```

### Relations entre les tables

```
users
  ├── memberships (user_id)
  │     └── payments (membership_id)
  ├── ratings (user_id)
  ├── attendance (user_id)
  ├── user_points (user_id)
  └── user_badges (user_id)

coaches
  ├── class_sessions (coach_id)
  └── ratings (coach_id)

class_sessions
  ├── ratings (class_id)
  └── attendance (class_id)

badges
  └── user_badges (badge_id)
```

## 🔧 Utilisation du DatabaseHelper

```dart
import 'services/database_helper.dart';

// Obtenir une instance de la base de données
final dbHelper = DatabaseHelper();
final db = await dbHelper.database;

// Exemple : Insérer un utilisateur
await db.insert('users', {
  'name': 'John Doe',
  'email': 'john@example.com',
  'password': 'hashed_password',
  'role': 'member',
  'age': 25,
  'goals': 'Perte de poids',
  'created_at': DateTime.now().toIso8601String(),
});

// Exemple : Récupérer tous les utilisateurs
final users = await db.query('users');
print('Utilisateurs : $users');

// Exemple : Récupérer les abonnements d'un utilisateur
final memberships = await db.query(
  'memberships',
  where: 'user_id = ?',
  whereArgs: [userId],
);
```

## ⚠️ Points importants

1. **Clés étrangères activées** : `PRAGMA foreign_keys = ON` est activé automatiquement
2. **Migrations automatiques** : Le système de migration gère les versions 1, 2 et 3
3. **Indices uniques** : Empêchent les évaluations en double par utilisateur
4. **Suppression en cascade** : La suppression d'un utilisateur supprime automatiquement ses données associées

## 🗑️ Nettoyage de l'ancienne base

Une fois la migration effectuée et vérifiée, vous pouvez supprimer l'ancienne base :

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<void> deleteOldDatabase() async {
  final dbPath = await getDatabasesPath();
  final gymManagerPath = join(dbPath, 'gym_manager.db');
  await deleteDatabase(gymManagerPath);
  print('✅ Ancienne base supprimée');
}
```

## 📝 Notes de version

### Version 3 (actuelle)
- ✅ Toutes les tables gym_manager ajoutées
- ✅ Migration automatique depuis gym_manager.db
- ✅ Réutilisation de la table users existante
- ✅ Indices uniques pour les évaluations
- ✅ Clés étrangères activées

### Version 2
- ✅ Ajout de la colonne `dateSeance` à la table `planning`

### Version 1
- ✅ Table `planning` de base

