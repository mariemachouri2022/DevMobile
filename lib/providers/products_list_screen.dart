import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_provider.dart';
import 'cart_provider.dart';
import '../models/product.dart';
import '../screens/product_detail_screen.dart';
import '../screens/add_product_screen.dart';
import '../screens/edit_product_screen.dart';
import 'dart:io'; // Ajout de l'import pour File

class ProductsListScreen extends StatefulWidget {
  @override
  _ProductsListScreenState createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Tous';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  void _searchProducts(String query) {
    setState(() {
      _searchQuery = query;
    });

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    if (query.isEmpty) {
      productProvider.loadProducts();
    } else {
      productProvider.searchProducts(query);
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    if (category == 'Tous') {
      productProvider.loadProducts();
    } else {
      productProvider.filterByCategory(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Boutique SmartFit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header avec recherche
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Barre de recherche
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un produit...',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          _searchController.clear();
                          _searchProducts('');
                        },
                      )
                          : null,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onChanged: _searchProducts,
                  ),
                ),
                SizedBox(height: 12),
                // Filtres par catégorie
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CategoryChip(
                        label: 'Tous',
                        isSelected: _selectedCategory == 'Tous',
                        onTap: () => _filterByCategory('Tous'),
                      ),
                      _CategoryChip(
                        label: 'Protéine',
                        isSelected: _selectedCategory == 'Protéine',
                        onTap: () => _filterByCategory('Protéine'),
                      ),
                      _CategoryChip(
                        label: 'Créatine',
                        isSelected: _selectedCategory == 'Créatine',
                        onTap: () => _filterByCategory('Créatine'),
                      ),
                      _CategoryChip(
                        label: 'Tenue',
                        isSelected: _selectedCategory == 'Tenue',
                        onTap: () => _filterByCategory('Tenue'),
                      ),
                      _CategoryChip(
                        label: 'Accessoire',
                        isSelected: _selectedCategory == 'Accessoire',
                        onTap: () => _filterByCategory('Accessoire'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Indicateur de chargement
          if (productProvider.isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Chargement des produits...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Message d'erreur
          if (productProvider.error != null && !productProvider.isLoading)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Erreur',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          productProvider.error!,
                          style: TextStyle(color: Colors.red[600]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            productProvider.clearError();
                            productProvider.loadProducts();
                          },
                          child: Text('Réessayer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Liste des produits
          if (!productProvider.isLoading && productProvider.error == null)
            Expanded(
              child: productProvider.products.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: productProvider.products.length,
                itemBuilder: (context, index) {
                  final product = productProvider.products[index];
                  return ProductCard(
                    product: product,
                    onEdit: () => _navigateToEditScreen(context, product),
                    onDelete: () => _showDeleteDialog(context, productProvider, product),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddScreen(context),
        child: Icon(Icons.add, size: 28),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  void _navigateToAddScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductScreen()),
    );
    // Recharger les produits après retour
    Provider.of<ProductProvider>(context, listen: false).loadProducts();
  }

  void _navigateToEditScreen(BuildContext context, Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: product),
      ),
    );
    // Recharger les produits après retour
    Provider.of<ProductProvider>(context, listen: false).loadProducts();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'Tous'
                ? 'Aucun produit trouvé'
                : 'Aucun produit disponible',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          if (_searchQuery.isNotEmpty || _selectedCategory != 'Tous')
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = 'Tous';
                });
                Provider.of<ProductProvider>(context, listen: false).loadProducts();
              },
              child: Text(
                'Voir tous les produits',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ProductProvider productProvider, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirmer la suppression',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Êtes-vous sûr de vouloir supprimer "${product.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await productProvider.deleteProduct(product.id!);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Produit supprimé avec succès'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur lors de la suppression'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// Composant pour les chips de catégorie
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[700] : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// Carte produit améliorée avec bouton d'édition
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Image du produit - CORRIGÉ
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildProductImage(),
                ),
                SizedBox(width: 16),
                // Informations du produit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${product.price.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Stock: ${product.quantityInStock}',
                            style: TextStyle(
                              fontSize: 12,
                              color: product.quantityInStock > 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                Column(
                  children: [
                    // Bouton d'édition
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.orange[700]),
                      onPressed: onEdit,
                    ),
                    // Bouton d'ajout au panier (si en stock)
                    if (product.quantityInStock > 0)
                      IconButton(
                        icon: Icon(Icons.add_shopping_cart, color: Colors.blue[700]),
                        onPressed: () {
                          cartProvider.addToCart(product, 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} ajouté au panier'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    // Bouton de suppression
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // NOUVELLE MÉTHODE pour gérer l'affichage de l'image
  Widget _buildProductImage() {
    if (product.imagePath == null || product.imagePath!.isEmpty) {
      // Aucune image - afficher une icône par défaut
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.blue[50],
          child: Icon(
            Icons.shopping_bag,
            color: Colors.blue[700],
            size: 30,
          ),
        ),
      );
    }

    try {
      // Vérifier si c'est un chemin d'asset (commence par 'assets/')
      if (product.imagePath!.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            product.imagePath!,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorImage();
            },
          ),
        );
      } else {
        // C'est un chemin de fichier local (File)
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(product.imagePath!),
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorImage();
            },
          ),
        );
      }
    } catch (e) {
      // En cas d'erreur, afficher l'icône par défaut
      return _buildErrorImage();
    }
  }

  // Widget pour afficher une image d'erreur
  Widget _buildErrorImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: Colors.grey[200],
        child: Icon(
          Icons.broken_image,
          color: Colors.grey[400],
          size: 30,
        ),
      ),
    );
  }
}