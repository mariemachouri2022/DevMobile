import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/local_storage_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  final LocalStorageService _storageService = LocalStorageService();

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _storageService.getProducts();
      _error = null;
    } catch (e) {
      _error = 'Erreur lors du chargement des produits: $e';
      print(_error);
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct(Product product) async {
    try {
      final success = await _storageService.addProduct(product);
      if (success) {
        await loadProducts();
      }
      return success;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      final success = await _storageService.updateProduct(product);
      if (success) {
        await loadProducts();
      }
      return success;
    } catch (e) {
      _error = 'Erreur lors de la modification: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final success = await _storageService.deleteProduct(id);
      if (success) {
        await loadProducts();
      }
      return success;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  Future<void> searchProducts(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _storageService.searchProducts(query);
      _error = null;
    } catch (e) {
      _error = 'Erreur lors de la recherche: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByCategory(String category) async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _storageService.getProductsByCategory(category);
      _error = null;
    } catch (e) {
      _error = 'Erreur lors du filtrage: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}