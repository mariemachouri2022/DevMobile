import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class BackupService {
  static final BackupService instance = BackupService._init();
  BackupService._init();

  // Export all data to JSON
  Future<String> exportDataToJson() async {
    final users = await DatabaseService.instance.getAllUsers();
    
    final exportData = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'users': users.map((user) => user.toMap()).toList(),
    };

    return jsonEncode(exportData);
  }

  // Save export to file
  Future<File> saveExportToFile() async {
    final jsonData = await exportDataToJson();
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/smartfit_backup_$timestamp.json');
    
    return await file.writeAsString(jsonData);
  }

  // Import data from JSON
  Future<bool> importDataFromJson(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final usersData = data['users'] as List<dynamic>;
      
      for (var userData in usersData) {
        final user = UserModel.fromMap(userData as Map<String, dynamic>);
        
        // Check if user exists
        final existing = await DatabaseService.instance.getUserByEmail(user.email);
        
        if (existing == null) {
          await DatabaseService.instance.createUser(user);
        } else {
          await DatabaseService.instance.updateUser(user.copyWith(id: existing.id));
        }
      }
      
      return true;
    } catch (e) {
      print('Import error: $e');
      return false;
    }
  }

  // Load import from file
  Future<bool> loadImportFromFile(File file) async {
    try {
      final jsonData = await file.readAsString();
      return await importDataFromJson(jsonData);
    } catch (e) {
      print('File read error: $e');
      return false;
    }
  }

  // Get all backup files
  Future<List<File>> getBackupFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final dir = Directory(directory.path);
    
    if (!await dir.exists()) {
      return [];
    }
    
    return dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.contains('smartfit_backup'))
        .toList();
  }

  // Delete backup file
  Future<void> deleteBackupFile(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
