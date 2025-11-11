import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  int get totalItems {
    return _cartItems.fold(0, (total, item) => total + item.quantity);
  }

  double get totalAmount {
    return _cartItems.fold(0, (total, item) => total + item.totalPrice);
  }

  void addToCart(Product product, [int quantity = 1]) {
    final index = _cartItems.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      // Produit déjà dans le panier - mettre à jour la quantité
      _cartItems[index] = _cartItems[index].copyWith(
          quantity: _cartItems[index].quantity + quantity
      );
    } else {
      // Nouveau produit
      _cartItems.add(CartItem(
          product: product,
          quantity: quantity
      ));
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      if (newQuantity > 0) {
        _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      } else {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  bool isProductInCart(int productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  int getProductQuantity(int productId) {
    final item = _cartItems.firstWhere(
            (item) => item.product.id == productId,
        orElse: () => CartItem(product: Product(id: -1, name: '', category: '', description: '', price: 0, quantityInStock: 0), quantity: 0)
    );
    return item.quantity;
  }
}