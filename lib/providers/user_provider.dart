import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class UserProvider with ChangeNotifier {
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = false;
  String? _errorMessage;
  UserRole? _filterRole;
  String _searchQuery = '';

  List<UserModel> get users => _filteredUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserRole? get filterRole => _filterRole;
  String get searchQuery => _searchQuery;

  // Load all users
  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await DatabaseService.instance.getAllUsers();
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Error loading users: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load users by role
  Future<void> loadUsersByRole(UserRole role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await DatabaseService.instance.getUsersByRole(role);
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Error loading users: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load clients by coach
  Future<void> loadClientsByCoach(int coachId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await DatabaseService.instance.getClientsByCoach(coachId);
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Error loading clients: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create user
  Future<bool> createUser(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if email already exists
      final existing = await DatabaseService.instance.getUserByEmail(user.email);
      if (existing != null) {
        _errorMessage = 'Email already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await DatabaseService.instance.createUser(user);
      await loadUsers();
      return true;
    } catch (e) {
      _errorMessage = 'Error creating user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user
  Future<bool> updateUser(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await DatabaseService.instance.updateUser(user);
      await loadUsers();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await DatabaseService.instance.deleteUser(id);
      await loadUsers();
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Assign coach to client
  Future<bool> assignCoachToClient(int clientId, int coachId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await DatabaseService.instance.assignCoachToClient(clientId, coachId);
      await loadUsers();
      return true;
    } catch (e) {
      _errorMessage = 'Error assigning coach: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Search users
  void searchUsers(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by role
  void filterByRole(UserRole? role) {
    _filterRole = role;
    _applyFilters();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _filterRole = null;
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Apply filters
  void _applyFilters() {
    _filteredUsers = _users;

    // Apply role filter
    if (_filterRole != null) {
      _filteredUsers = _filteredUsers
          .where((user) => user.role == _filterRole)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredUsers = _filteredUsers.where((user) {
        final query = _searchQuery.toLowerCase();
        return user.name.toLowerCase().contains(query) ||
            user.firstName.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query) ||
            user.phone.contains(query);
      }).toList();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
