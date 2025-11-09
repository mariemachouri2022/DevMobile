import 'database_service.dart';
import '../models/user_model.dart';

class StatisticsService {
  static final StatisticsService instance = StatisticsService._init();
  StatisticsService._init();

  // Get comprehensive statistics
  Future<Map<String, dynamic>> getOverallStatistics() async {
    final db = DatabaseService.instance;
    
    final users = await db.getAllUsers();
    final coaches = users.where((u) => u.role == UserRole.coach).toList();
    final clients = users.where((u) => u.role == UserRole.client).toList();
    
    final clientStats = await db.getClientStatistics();
    final coachesWithCount = await db.getCoachesWithClientCount();
    
    return {
      'totalUsers': users.length,
      'totalCoaches': coaches.length,
      'totalClients': clients.length,
      'totalAdmins': users.where((u) => u.role == UserRole.admin).length,
      'averageAge': clientStats.isNotEmpty ? clientStats[0]['averageAge'] ?? 0 : 0,
      'minAge': clientStats.isNotEmpty ? clientStats[0]['minAge'] ?? 0 : 0,
      'maxAge': clientStats.isNotEmpty ? clientStats[0]['maxAge'] ?? 0 : 0,
      'coachesWithClients': coachesWithCount.length,
      'averageClientsPerCoach': _calculateAverageClientsPerCoach(coachesWithCount),
      'mostPopularCoach': _getMostPopularCoach(coachesWithCount),
    };
  }

  // Get coach-specific statistics
  Future<Map<String, dynamic>> getCoachStatistics(int coachId) async {
    final db = DatabaseService.instance;
    final clients = await db.getClientsByCoach(coachId);
    
    if (clients.isEmpty) {
      return {
        'totalClients': 0,
        'averageAge': 0,
        'ageDistribution': <String, int>{},
      };
    }
    
    final ages = clients.map((c) => c.age).toList();
    final averageAge = ages.reduce((a, b) => a + b) / ages.length;
    
    return {
      'totalClients': clients.length,
      'averageAge': averageAge.toStringAsFixed(1),
      'youngestClient': ages.reduce((a, b) => a < b ? a : b),
      'oldestClient': ages.reduce((a, b) => a > b ? a : b),
      'ageDistribution': _getAgeDistribution(clients),
      'genderDistribution': {'male': 0, 'female': 0}, // Placeholder
    };
  }

  // Get client statistics over time
  Future<List<Map<String, dynamic>>> getClientGrowthOverTime() async {
    final db = DatabaseService.instance;
    final users = await db.getAllUsers();
    
    final clients = users
        .where((u) => u.role == UserRole.client && u.createdAt != null)
        .toList();
    
    // Group by month
    final monthlyData = <String, int>{};
    
    for (var client in clients) {
      final month = '${client.createdAt!.year}-${client.createdAt!.month.toString().padLeft(2, '0')}';
      monthlyData[month] = (monthlyData[month] ?? 0) + 1;
    }
    
    return monthlyData.entries
        .map((e) => {'month': e.key, 'count': e.value})
        .toList()
      ..sort((a, b) => (a['month'] as String).compareTo(b['month'] as String));
  }

  // Get role distribution
  Future<Map<String, int>> getRoleDistribution() async {
    final db = DatabaseService.instance;
    final users = await db.getAllUsers();
    
    return {
      'admin': users.where((u) => u.role == UserRole.admin).length,
      'coach': users.where((u) => u.role == UserRole.coach).length,
      'client': users.where((u) => u.role == UserRole.client).length,
    };
  }

  // Get recent activity
  Future<List<Map<String, dynamic>>> getRecentActivity(int limit) async {
    final db = DatabaseService.instance;
    final recentUsers = await db.getRecentlyModifiedUsers(limit);
    
    return recentUsers.map((user) {
      return {
        'userId': user['id'],
        'name': '${user['firstName']} ${user['name']}',
        'action': 'Profile updated',
        'timestamp': user['lastModified'],
      };
    }).toList();
  }

  // Get unassigned clients count
  Future<int> getUnassignedClientsCount() async {
    final db = DatabaseService.instance;
    final users = await db.getAllUsers();
    
    return users
        .where((u) => u.role == UserRole.client && u.coachId == null)
        .length;
  }

  // Private helper methods
  double _calculateAverageClientsPerCoach(List<Map<String, dynamic>> coachData) {
    if (coachData.isEmpty) return 0.0;
    
    final totalClients = coachData.fold<int>(
      0,
      (sum, coach) => sum + (coach['clientCount'] as int),
    );
    
    return totalClients / coachData.length;
  }

  Map<String, dynamic>? _getMostPopularCoach(List<Map<String, dynamic>> coachData) {
    if (coachData.isEmpty) return null;
    
    var mostPopular = coachData[0];
    for (var coach in coachData) {
      if ((coach['clientCount'] as int) > (mostPopular['clientCount'] as int)) {
        mostPopular = coach;
      }
    }
    
    return mostPopular;
  }

  Map<String, int> _getAgeDistribution(List<UserModel> clients) {
    final distribution = <String, int>{
      '18-25': 0,
      '26-35': 0,
      '36-45': 0,
      '46-55': 0,
      '56+': 0,
    };
    
    for (var client in clients) {
      if (client.age <= 25) {
        distribution['18-25'] = distribution['18-25']! + 1;
      } else if (client.age <= 35) {
        distribution['26-35'] = distribution['26-35']! + 1;
      } else if (client.age <= 45) {
        distribution['36-45'] = distribution['36-45']! + 1;
      } else if (client.age <= 55) {
        distribution['46-55'] = distribution['46-55']! + 1;
      } else {
        distribution['56+'] = distribution['56+']! + 1;
      }
    }
    
    return distribution;
  }
}
