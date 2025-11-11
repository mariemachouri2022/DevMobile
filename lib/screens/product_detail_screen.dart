import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import 'dart:io'; // Ajout de l'import pour File

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Détails du produit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit - CORRIGÉ
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: _buildProductImage(),
            ),
            SizedBox(height: 24),

            // Nom et prix
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Text(
                  '${product.price.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Catégorie et stock
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Text(
                    product.category,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: product.quantityInStock > 0 ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: product.quantityInStock > 0 ? Colors.green[100]! : Colors.red[100]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        product.quantityInStock > 0 ? Icons.inventory_2 : Icons.error_outline,
                        size: 16,
                        color: product.quantityInStock > 0 ? Colors.green[600] : Colors.red[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        product.quantityInStock > 0 ? 'En stock' : 'Rupture',
                        style: TextStyle(
                          color: product.quantityInStock > 0 ? Colors.green[600] : Colors.red[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Description
            Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                product.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 24),

            // Détails supplémentaires
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations produit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.category,
                    label: 'Catégorie',
                    value: product.category,
                  ),
                  _InfoRow(
                    icon: Icons.inventory_2,
                    label: 'Stock disponible',
                    value: '${product.quantityInStock} unités',
                  ),
                  _InfoRow(
                    icon: Icons.attach_money,
                    label: 'Prix unitaire',
                    value: '${product.price.toStringAsFixed(2)} €',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: product.quantityInStock > 0
          ? Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              cartProvider.addToCart(product, 1);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} ajouté au panier'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
            child: Text(
              'Ajouter au panier',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      )
          : null,
    );
  }

  // NOUVELLE MÉTHODE pour gérer l'affichage de l'image
  Widget _buildProductImage() {
    if (product.imagePath == null || product.imagePath!.isEmpty) {
      // Aucune image - afficher une icône par défaut
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: Colors.blue[50],
          child: Center(
            child: Icon(
              Icons.shopping_bag,
              size: 80,
              color: Colors.blue[200],
            ),
          ),
        ),
      );
    }

    try {
      // Vérifier si c'est un chemin d'asset (commence par 'assets/')
      if (product.imagePath!.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            product.imagePath!,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorImage();
            },
          ),
        );
      } else {
        // C'est un chemin de fichier local (File)
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(product.imagePath!),
            width: double.infinity,
            height: 250,
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: Colors.grey[200],
        child: Center(
          child: Icon(
            Icons.broken_image,
            color: Colors.grey[400],
            size: 60,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue[700],
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}