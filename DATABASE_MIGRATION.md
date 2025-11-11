# Migration de la Base de Données - SmartFit

## Changements effectués

### 1. Unification de la table `users`

La table `users` a été mise à jour dans `AppDatabase` pour correspondre au schéma de `DatabaseService` avec les champs suivants :

#### Champs de la table `users` :
- `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
- `name` (TEXT NOT NULL) - Nom de famille
- `firstName` (TEXT NOT NULL) - Prénom
- `age` (INTEGER NOT NULL)
- `phone` (TEXT NOT NULL)
- `email` (TEXT UNIQUE NOT NULL)
- `password` (TEXT NOT NULL)
- `role` (TEXT NOT NULL) - 'admin', 'coach', ou 'client'
- `coachId` (INTEGER) - ID du coach assigné (pour les clients)
- `profileImagePath` (TEXT) - Chemin vers la photo de profil
- `lastModified` (TEXT DEFAULT CURRENT_TIMESTAMP) - Date de dernière modification
- `createdAt` (TEXT DEFAULT CURRENT_TIMESTAMP) - Date de création
- `isActive` (INTEGER DEFAULT 1) - Statut actif/inactif (soft delete)
- `goals` (TEXT) - Objectifs de l'utilisateur

### 2. Tables d'historique ajoutées

Deux tables d'historique ont été ajoutées pour suivre les modifications :

#### `coach_client_history`
Suit l'historique des assignations coach-client :
- `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
- `clientId` (INTEGER NOT NULL)
- `coachId` (INTEGER NOT NULL)
- `assignedAt` (TEXT)
- `unassignedAt` (TEXT)
- `isActive` (INTEGER DEFAULT 1)

#### `profile_history`
Suit l'historique des modifications de profil :
- `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
- `userId` (INTEGER NOT NULL)
- `field` (TEXT NOT NULL) - Nom du champ modifié
- `oldValue` (TEXT) - Ancienne valeur
- `newValue` (TEXT) - Nouvelle valeur
- `modifiedAt` (TEXT)
- `modifiedBy` (INTEGER) - ID de l'utilisateur qui a fait la modification

### 3. Version de la base de données

La version de la base de données a été incrémentée à **4** pour forcer la migration.

## Migration automatique

Lors du lancement de l'application, la base de données sera automatiquement mise à jour vers la version 4 :

1. Les anciennes colonnes seront conservées
2. Les nouvelles colonnes seront ajoutées avec des valeurs par défaut
3. Les tables d'historique seront créées si elles n'existent pas

## Utilisation du MigrationHelper

Un utilitaire `MigrationHelper` a été créé pour faciliter la gestion de la base de données :

```dart
import 'package:devmobile/services/migration_helper.dart';

// Vérifier l'intégrité de la base de données
final integrity = await MigrationHelper.instance.checkDatabaseIntegrity();
print('Toutes les tables présentes: ${integrity['allTablesPresent']}');

// Afficher les informations de debug
await MigrationHelper.instance.printDatabaseInfo();

// Réinitialiser la base (ATTENTION: supprime toutes les données)
// await MigrationHelper.instance.resetDatabase();
```

## Compatibilité

- ✅ `DatabaseService` et `AppDatabase` utilisent maintenant le même schéma pour la table `users`
- ✅ Les deux services pointent vers le même fichier de base de données (`smartfit.db`)
- ✅ Le modèle `UserModel` est compatible avec les deux services
- ✅ Toutes les fonctionnalités existantes sont préservées

## Champs supprimés

L'ancienne structure utilisait :
- `created_at` → remplacé par `createdAt` (camelCase)

## Nouveaux champs ajoutés

Pour une meilleure compatibilité :
- `firstName` - Prénom de l'utilisateur
- `phone` - Numéro de téléphone
- `coachId` - Référence au coach assigné
- `profileImagePath` - Chemin vers la photo de profil
- `lastModified` - Horodatage de modification
- `isActive` - Statut actif/inactif

## Recommandations

1. **Testez sur un émulateur** avant de déployer en production
2. **Sauvegardez les données** importantes avant la migration
3. **Utilisez le MigrationHelper** pour vérifier l'intégrité de la base
4. Si des problèmes surviennent, vous pouvez réinitialiser la base avec `MigrationHelper.instance.resetDatabase()` (cela supprimera toutes les données)

## Prochaines étapes

1. Tester la migration sur un environnement de développement
2. Vérifier que toutes les fonctionnalités fonctionnent correctement
3. Documenter tout problème rencontré
4. Mettre à jour les tests unitaires si nécessaire

