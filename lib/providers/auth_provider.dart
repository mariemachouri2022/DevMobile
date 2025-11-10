import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId != null) {
        _currentUser = await DatabaseService.instance.getUserById(userId);
      }
    } catch (e) {
      _errorMessage = 'Error checking authentication: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await DatabaseService.instance.getUserByEmail(email);

      if (user == null) {
        _errorMessage = 'User not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (user.password != password) {
        _errorMessage = 'Incorrect password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;

      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Login error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if email already exists
      final existingUser = await DatabaseService.instance.getUserByEmail(
        user.email,
      );

      if (existingUser != null) {
        _errorMessage = 'Email already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final userId = await DatabaseService.instance.createUser(user);
      _currentUser = user.copyWith(id: userId);

      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Registration error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    notifyListeners();
  }

  // Check if email exists
  Future<bool> checkEmailExists(String email) async {
    try {
      final user = await DatabaseService.instance.getUserByEmail(email);
      return user != null;
    } catch (e) {
      _errorMessage = 'Error checking email: $e';
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await DatabaseService.instance.getUserByEmail(email);

      if (user == null) {
        _errorMessage = 'User not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Update user with new password
      final updatedUser = user.copyWith(password: newPassword);
      await DatabaseService.instance.updateUser(updatedUser);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error resetting password: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}