import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _productsKey = 'smartfit_products';

  // Sauvegarder les produits
  Future<bool> saveProducts(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = products.map((product) => product.toMap()).toList();
      return await prefs.setString(_productsKey, json.encode(productsJson));
    } catch (e) {
      print('Erreur sauvegarde produits: $e');
      return false;
    }
  }

  // Charger les produits
  Future<List<Product>> getProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString(_productsKey);

      if (productsJson == null) {
        return _getDefaultProducts(); // Produits par défaut
      }

      final List<dynamic> productsList = json.decode(productsJson);
      return productsList.map((item) => Product.fromMap(item)).toList();
    } catch (e) {
      print('Erreur chargement produits: $e');
      return _getDefaultProducts();
    }
  }

  // Produits par défaut pour démonstration
  List<Product> _getDefaultProducts() {
    return [
      // PROTÉINES
      Product(
        id: 1,
        name: 'Whey Protein Premium',
        category: 'Protéine',
        description: 'Protéine de lactosérum isolate de haute qualité - 2kg',
        price: 39.99,
        quantityInStock: 15,
      ),
      Product(
        id: 2,
        name: 'Protéine Végétale',
        category: 'Protéine',
        description: 'Mélange de protéines végétales - Vanille - 1.8kg',
        price: 34.99,
        quantityInStock: 8,
      ),
      Product(
        id: 3,
        name: 'Caséine Micellaire',
        category: 'Protéine',
        description: 'Libération lente - Chocolat - 2kg',
        price: 42.99,
        quantityInStock: 12,
      ),
      Product(
        id: 4,
        name: 'Barre Protéinée',
        category: 'Protéine',
        description: '20g de protéines - Saveur Chocolat Noisette',
        price: 2.99,
        quantityInStock: 50,
      ),

      // CRÉATINE
      Product(
        id: 5,
        name: 'Créatine Monohydrate',
        category: 'Créatine',
        description: 'Créatine pure micronisée - 500g',
        price: 19.99,
        quantityInStock: 10,
      ),
      Product(
        id: 6,
        name: 'Créatine HCl',
        category: 'Créatine',
        description: 'Créatine hydrochloride - 300g',
        price: 24.99,
        quantityInStock: 7,
      ),
      Product(
        id: 7,
        name: 'Complexe Créatine',
        category: 'Créatine',
        description: 'Mélange avancé avec transporteurs - 400g',
        price: 29.99,
        quantityInStock: 5,
      ),

      // BCAA
      Product(
        id: 8,
        name: 'BCAA 2:1:1',
        category: 'Acides Aminés',
        description: 'Ratio optimal - Saveur Fruits Rouges - 300g',
        price: 22.99,
        quantityInStock: 18,
      ),
      Product(
        id: 9,
        name: 'BCAA 4:1:1',
        category: 'Acides Aminés',
        description: 'Fortifié en Leucine - Citron - 400g',
        price: 26.99,
        quantityInStock: 14,
      ),
      Product(
        id: 10,
        name: 'EAAs Complex',
        category: 'Acides Aminés',
        description: '9 Acides Aminés Essentiels - 500g',
        price: 32.99,
        quantityInStock: 9,
      ),

      // PRÉ-ENTRAÎNEMENT
      Product(
        id: 11,
        name: 'Pre-Workout Extreme',
        category: 'Pré-entraînement',
        description: 'Formule énergétique intense - Berry Blast',
        price: 35.99,
        quantityInStock: 11,
      ),
      Product(
        id: 12,
        name: 'Pre-Workout Pump',
        category: 'Pré-entraînement',
        description: 'Focus sur la congestion - Fruit Punch',
        price: 31.99,
        quantityInStock: 13,
      ),
      Product(
        id: 13,
        name: 'Pre-Workout Stim Free',
        category: 'Pré-entraînement',
        description: 'Sans stimulants - Saveur Orange',
        price: 28.99,
        quantityInStock: 6,
      ),

      // VITAMINES & MINÉRAUX
      Product(
        id: 14,
        name: 'Multivitamines Premium',
        category: 'Vitamines',
        description: 'Complexe complet - 90 comprimés',
        price: 18.99,
        quantityInStock: 25,
      ),
      Product(
        id: 15,
        name: 'Vitamine D3 4000UI',
        category: 'Vitamines',
        description: 'Haut dosage - 120 gélules',
        price: 14.99,
        quantityInStock: 20,
      ),
      Product(
        id: 16,
        name: 'Magnésium Bisglycinate',
        category: 'Minéraux',
        description: 'Haute absorption - 180 gélules',
        price: 16.99,
        quantityInStock: 16,
      ),

      // TENUES
      Product(
        id: 17,
        name: 'T-shirt Training Pro',
        category: 'Tenue',
        description: 'T-shirt technique respirant - Noir',
        price: 24.99,
        quantityInStock: 20,
      ),
      Product(
        id: 18,
        name: 'Short de Sport',
        category: 'Tenue',
        description: 'Short léger avec poches - Bleu',
        price: 19.99,
        quantityInStock: 15,
      ),
      Product(
        id: 19,
        name: 'Legging Fitness',
        category: 'Tenue',
        description: 'Legging haute compression - Noir',
        price: 34.99,
        quantityInStock: 12,
      ),
      Product(
        id: 20,
        name: 'Survetement SmartFit',
        category: 'Tenue',
        description: 'Ensemble training - Gris',
        price: 49.99,
        quantityInStock: 8,
      ),

      // ACCESSOIRES
      Product(
        id: 21,
        name: 'Gourde Sport 1L',
        category: 'Accessoire',
        description: 'Gourde isotherme avec marquage SmartFit',
        price: 12.99,
        quantityInStock: 25,
      ),
      Product(
        id: 22,
        name: 'Shaker Pro 700ml',
        category: 'Accessoire',
        description: 'Shaker avec compartiment secrèt',
        price: 8.99,
        quantityInStock: 30,
      ),
      Product(
        id: 23,
        name: 'Gants de Fitness',
        category: 'Accessoire',
        description: 'Protection mains avec support poignet',
        price: 15.99,
        quantityInStock: 18,
      ),
      Product(
        id: 24,
        name: 'Ceinture d\'haltérophilie',
        category: 'Accessoire',
        description: 'Ceinture de force en cuir - Taille L',
        price: 39.99,
        quantityInStock: 10,
      ),
      Product(
        id: 25,
        name: 'Corde à Sauter',
        category: 'Accessoire',
        description: 'Corde vitesse réglable avec roulements',
        price: 14.99,
        quantityInStock: 22,
      ),

      // BRÛLEURS DE GRAISSE
      Product(
        id: 26,
        name: 'Thermogénique Ultra',
        category: 'Brûleur de Graisse',
        description: 'Formule avancée pour la perte de poids',
        price: 29.99,
        quantityInStock: 9,
      ),
      Product(
        id: 27,
        name: 'L-Carnitine 3000',
        category: 'Brûleur de Graisse',
        description: 'Transport des graisses - Liquide 500ml',
        price: 19.99,
        quantityInStock: 11,
      ),

      // OMEGA & HUILES
      Product(
        id: 28,
        name: 'Omega 3-6-9',
        category: 'Oméga & Huiles',
        description: 'Complexe d\'acides gras essentiels - 180 gélules',
        price: 21.99,
        quantityInStock: 17,
      ),
      Product(
        id: 29,
        name: 'Huile de Poisson',
        category: 'Oméga & Huiles',
        description: 'Source concentrée d\'EPA/DHA - 120 gélules',
        price: 16.99,
        quantityInStock: 14,
      ),

      // COLLAGÈNE
      Product(
        id: 30,
        name: 'Collagène Hydrolysé',
        category: 'Collagène',
        description: 'Peptides de collagène - 300g',
        price: 27.99,
        quantityInStock: 7,
      ),
    ];
  }

  // Ajouter un produit
  Future<bool> addProduct(Product product) async {
    final products = await getProducts();
    final newId = products.isEmpty ? 1 : (products.last.id ?? 0) + 1;
    products.add(product.copyWith(id: newId));
    return await saveProducts(products);
  }

  // Modifier un produit
  Future<bool> updateProduct(Product updatedProduct) async {
    final products = await getProducts();
    final index = products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      products[index] = updatedProduct;
      return await saveProducts(products);
    }
    return false;
  }

  // Supprimer un produit
  Future<bool> deleteProduct(int id) async {
    final products = await getProducts();
    products.removeWhere((p) => p.id == id);
    return await saveProducts(products);
  }

  // Rechercher des produits
  Future<List<Product>> searchProducts(String query) async {
    final products = await getProducts();
    if (query.isEmpty) return products;

    return products.where((product) =>
    product.name.toLowerCase().contains(query.toLowerCase()) ||
        product.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Filtrer par catégorie
  Future<List<Product>> getProductsByCategory(String category) async {
    final products = await getProducts();
    if (category == 'Tous') return products;

    return products.where((product) => product.category == category).toList();
  }

  // Obtenir toutes les catégories disponibles
  Future<List<String>> getCategories() async {
    final products = await getProducts();
    final categories = products.map((p) => p.category).toSet().toList();
    categories.insert(0, 'Tous');
    return categories;
  }
}