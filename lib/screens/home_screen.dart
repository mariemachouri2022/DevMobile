import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfit/screens/products_catalog_screen.dart';
import '../assistant_ia_page.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_card.dart';
import 'client_calendar_screen.dart';
import 'coach_calendar_screen.dart';
import 'user_list_screen.dart';
import 'user_profile_screen.dart';
import 'login_screen.dart';
import 'statistics_screen.dart';
import 'backup_restore_screen.dart';
import 'coach_assignment_manager_screen.dart';
import 'admin_dashboard_screen.dart';
import 'member_home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminRedirect();
      _loadData();
    });
  }

  Future<void> _checkAdminRedirect() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user == null) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user.role == UserRole.admin) {
        // Redirect admin users to the new dashboard with tabs
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      }
      // Clients and coaches stay on HomeScreen
    });
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser?.role == UserRole.coach) {
      await userProvider.loadClientsByCoach(authProvider.currentUser!.id!);
    } else {
      await userProvider.loadUsers();
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('LOGOUT'),
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('SmartFit'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _handleLogout,
                tooltip: 'Logout',
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  currentUser.firstName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back,',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    Text(
                                      currentUser.fullName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        currentUser.role.displayName,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.email_outlined,
                                  size: 16, color: AppTheme.textSecondary),
                              const SizedBox(width: 8),
                              Text(
                                currentUser.email,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined,
                                  size: 16, color: AppTheme.textSecondary),
                              const SizedBox(width: 8),
                              Text(
                                currentUser.phone,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons based on role
                  if (currentUser.role == UserRole.admin) ...[
                    _buildActionCard(
                      context,
                      icon: Icons.people,
                      title: 'Manage Users',
                      subtitle: 'View, create, edit, or delete users',
                      color: AppTheme.primaryColor,
                      delay: 100,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const UserListScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      context,
                      icon: Icons.bar_chart,
                      title: 'Statistics',
                      subtitle: 'View analytics and insights',
                      color: AppTheme.accentColor,
                      delay: 200,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StatisticsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      context,
                      icon: Icons.backup,
                      title: 'Backup & Restore',
                      subtitle: 'Manage data backups',
                      color: AppTheme.successColor,
                      delay: 300,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BackupRestoreScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      context,
                      icon: Icons.link,
                      title: 'Assign Coaches',
                      subtitle: 'Manage coach-client assignments',
                      color: Colors.purple,
                      delay: 350,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CoachAssignmentManagerScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      context,
                      icon: Icons.person,
                      title: 'My Profile',
                      subtitle: 'View and edit your profile',
                      color: AppTheme.warningColor,
                      delay: 400,
                      onTap: () {
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
                  ] else if (currentUser.role == UserRole.coach) ...[
                    _buildActionCard(
                      context,
                      icon: Icons.group,
                      title: 'My Clients',
                      subtitle: 'View and manage your clients',
                      color: AppTheme.primaryColor,
                      delay: 100,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const UserListScreen(
                              coachView: true,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      context,
                      icon: Icons.calendar_today,
                      title: 'Planning',
                      subtitle: 'Manage your schedule and sessions',
                      color: Colors.blue,
                      delay: 150,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CoachCalendarScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      context,
                      icon: Icons.person,
                      title: 'My Profile',
                      subtitle: 'View and edit your profile',
                      color: AppTheme.accentColor,
                      delay: 200,
                      onTap: () {
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
                  ] else ...[
                    // Client actions
                    _buildActionCard(
                      context,
                      icon: Icons.card_membership,
                      title: 'My Subscription',
                      subtitle: 'Manage your membership and subscription',
                      color: Colors.green,
                      delay: 50,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MemberHome(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      context,
                      icon: Icons.calendar_today,
                      title: 'Planning',
                      subtitle: 'View your schedule and sessions',
                      color: AppTheme.primaryColor,
                      delay: 100,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ClientCalendarScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.calendar_today,
                      title: 'Produits',
                      subtitle: 'View your schedule and sessions',
                      color: AppTheme.primaryColor,
                      delay: 100,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>  ProductsCatalogScreen(),
                          ),
                        );
                      },
                    ),
                    Builder(builder: (context) {
                      print('[DEBUG] Building Assistant IA card...');
                      return _buildActionCard(
                        context,
                        icon: Icons.smart_toy,
                        title: 'Assistant IA',
                        subtitle: 'Discutez avec votre coach intelligent',
                        color: Colors.deepPurple,
                        onTap: () {
                          print('[DEBUG] Assistant IA card clicked');
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const AssistantIAPage(),
                          ));
                        },
                      );
                    }),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      context,
                      icon: Icons.person,
                      title: 'My Profile',
                      subtitle: 'View your profile and performance',
                      color: AppTheme.accentColor,
                      delay: 200,
                      onTap: () {
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
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
        int delay = 0,
      }) {
    return AnimatedCard(
      delay: delay,
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}