# Configuration de l'API Nutritionix

## Étapes pour obtenir vos clés API

1. **Créer un compte**
   - Allez sur https://developer.nutritionix.com/
   - Cliquez sur "Sign Up" pour créer un compte gratuit

2. **Créer une application**
   - Une fois connecté, allez dans votre dashboard
   - Cliquez sur "Create Application" ou "Add Application"
   - Remplissez le formulaire avec les informations de votre application

3. **Récupérer vos clés**
   - Après avoir créé l'application, vous verrez :
     - **Application ID** (App ID)
     - **Application Key** (App Key)

4. **Configurer dans l'application**
   - Ouvrez le fichier `lib/config/nutritionix_config.dart`
   - Remplacez `YOUR_APP_ID` par votre Application ID
   - Remplacez `YOUR_APP_KEY` par votre Application Key

## Exemple de configuration

```dart
class NutritionixConfig {
  static const String appId = 'votre-app-id-ici';
  static const String appKey = 'votre-app-key-ici';
}
```

## Fonctionnalités

Une fois configuré, vous pourrez :
- ✅ Rechercher des aliments dans la base de données Nutritionix
- ✅ Obtenir automatiquement les calories, protéines, glucides et lipides
- ✅ Remplir automatiquement les champs nutritionnels lors de l'ajout d'un repas

## Limites du plan gratuit

Le plan gratuit de Nutritionix offre :
- 100 requêtes par jour
- Accès à la base de données complète
- Support pour les aliments communs et les produits de marque

## Notes importantes

⚠️ **Ne commitez jamais vos clés API dans Git !**
- Ajoutez `lib/config/nutritionix_config.dart` à votre `.gitignore`
- Ou utilisez des variables d'environnement pour la production

