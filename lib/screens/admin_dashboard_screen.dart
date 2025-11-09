import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'user_list_screen.dart';
import 'user_profile_screen.dart';
import 'login_screen.dart';
import 'statistics_screen.dart';
import 'backup_restore_screen.dart';
import 'coach_assignment_manager_screen.dart';
import 'planning_screen.dart';
import 'equipment_screen.dart';
import 'performance_screen.dart';
import 'store_screen.dart';
import 'subscriptions_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ANNULER'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('DÉCONNEXION'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser;
        if (currentUser == null) {
          return const LoginScreen();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('SmartFit Admin'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => UserProfileScreen(
                        user: currentUser,
                        isCurrentUser: true,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _handleLogout,
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.calendar_today), text: 'Planning'),
                Tab(icon: Icon(Icons.fitness_center), text: 'Matériels'),
                Tab(icon: Icon(Icons.trending_up), text: 'Performance'),
                Tab(icon: Icon(Icons.shopping_bag), text: 'Store'),
                Tab(icon: Icon(Icons.card_membership), text: 'Abonnements'),
                Tab(icon: Icon(Icons.more_horiz), text: 'Plus'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: const [
              PlanningScreen(),
              EquipmentScreen(),
              PerformanceScreen(),
              StoreScreen(),
              SubscriptionsScreen(),
              AdminMoreScreen(),
            ],
          ),
        );
      },
    );
  }
}

// More tab with additional admin features
class AdminMoreScreen extends StatelessWidget {
  const AdminMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plus d\'Options',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Gestion avancée et outils',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _buildOptionCard(
            context,
            icon: Icons.people,
            title: 'Gestion des Utilisateurs',
            subtitle: 'Admins, coaches et clients',
            color: AppTheme.primaryColor,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UserListScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            context,
            icon: Icons.link,
            title: 'Assignation Coaches',
            subtitle: 'Gérer les relations coach-client',
            color: Colors.purple,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const CoachAssignmentManagerScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            context,
            icon: Icons.bar_chart,
            title: 'Statistiques Détaillées',
            subtitle: 'Analytics et insights',
            color: AppTheme.accentColor,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            context,
            icon: Icons.backup,
            title: 'Backup & Restore',
            subtitle: 'Sauvegarde des données',
            color: AppTheme.successColor,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
