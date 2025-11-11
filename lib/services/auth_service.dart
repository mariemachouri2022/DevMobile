import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfit/models/user_model.dart';
import 'package:smartfit/services/app_database.dart';


class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Future<UserModel?> login(String email, String password) async {
    final db = await AppDatabase().database;
    final rows = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password], limit: 1);
    if (rows.isEmpty) return null;
    final user = UserModel.fromMap(rows.first);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id!);
    return user;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String role = 'client',
  }) async {
    final db = await AppDatabase().database;
    final roleEnum = role == 'admin' ? UserRole.admin : (role == 'coach' ? UserRole.coach : UserRole.client);
    final id = await db.insert('users', {
      'name': name,
      'firstName': name.split(' ').first,
      'age': 25,
      'phone': '',
      'email': email,
      'password': password,
      'role': roleEnum.toString().split('.').last,
      'created_at': DateTime.now().toIso8601String(),
    });
    final user = UserModel(
      id: id,
      name: name,
      firstName: name.split(' ').first,
      age: 25,
      phone: '',
      email: email,
      password: password,
      role: roleEnum,
      createdAt: DateTime.now(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', id);
    return user;
  }

  Future<UserModel?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    if (id == null) return null;
    final db = await AppDatabase().database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }
}
