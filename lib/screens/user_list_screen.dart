import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_card.dart';
import 'user_profile_screen.dart';
import 'user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  final bool coachView;
  
  const UserListScreen({super.key, this.coachView = false});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _searchController = TextEditingController();
  UserRole? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  Future<void> _loadUsers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (widget.coachView && authProvider.currentUser?.role == UserRole.coach) {
      await userProvider.loadClientsByCoach(authProvider.currentUser!.id!);
    } else {
      await userProvider.loadUsers();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<UserRole?>(
              title: const Text('All'),
              value: null,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value);
                Provider.of<UserProvider>(context, listen: false)
                    .filterByRole(value);
                Navigator.of(context).pop();
              },
            ),
            ...UserRole.values.map((role) {
              return RadioListTile<UserRole?>(
                title: Text(role.displayName),
                value: role,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() => _selectedFilter = value);
                  Provider.of<UserProvider>(context, listen: false)
                      .filterByRole(value);
                  Navigator.of(context).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName}?'),
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
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.deleteUser(user.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'User deleted successfully'
                  : userProvider.errorMessage ?? 'Failed to delete user',
            ),
            backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coachView ? 'My Clients' : 'User List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<UserProvider>(context, listen: false)
                              .searchUsers('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                Provider.of<UserProvider>(context, listen: false)
                    .searchUsers(value);
              },
            ),
          ),

          // User List
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                if (userProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userProvider.users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    itemCount: userProvider.users.length,
                    itemBuilder: (context, index) {
                      final user = userProvider.users[index];
                      return AnimatedListItem(
                        index: index,
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              user.firstName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            user.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(user.email),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(user.role)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  user.role.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getRoleColor(user.role),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: isAdmin
                              ? PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'edit':
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => UserFormScreen(
                                              user: user,
                                            ),
                                          ),
                                        );
                                        break;
                                      case 'delete':
                                        _deleteUser(user);
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete,
                                              size: 20, color: AppTheme.errorColor),
                                          SizedBox(width: 8),
                                          Text('Delete',
                                              style: TextStyle(
                                                  color: AppTheme.errorColor)),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => UserProfileScreen(
                                  user: user,
                                  isCurrentUser: user.id ==
                                      authProvider.currentUser?.id,
                                ),
                              ),
                            );
                          },
                        ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const UserFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add User'),
            )
          : null,
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppTheme.errorColor;
      case UserRole.coach:
        return AppTheme.primaryColor;
      case UserRole.client:
        return AppTheme.accentColor;
    }
  }
}
