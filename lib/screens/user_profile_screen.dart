import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'user_form_screen.dart';
import 'assign_coach_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final UserModel user;
  final bool isCurrentUser;

  const UserProfileScreen({
    super.key,
    required this.user,
    this.isCurrentUser = false,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late UserModel _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  Future<void> _refreshUser() async {
    if (_currentUser.id != null) {
      final updatedUser = await DatabaseService.instance.getUserById(
        _currentUser.id!,
      );
      if (updatedUser != null && mounted) {
        setState(() {
          _currentUser = updatedUser;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role == UserRole.admin;
    final isCoach = authProvider.currentUser?.role == UserRole.coach;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCurrentUser ? 'My Profile' : _currentUser.fullName,
        ),
        actions: [
          if (isAdmin || widget.isCurrentUser)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UserFormScreen(user: _currentUser),
                  ),
                );
                // Refresh user data after returning from edit screen
                await _refreshUser();
              },
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              color: AppTheme.primaryColor,
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: _currentUser.profileImagePath != null
                        ? (File(_currentUser.profileImagePath!).existsSync()
                              ? FileImage(File(_currentUser.profileImagePath!))
                              : null)
                        : null,
                    child:
                        _currentUser.profileImagePath == null ||
                            !File(_currentUser.profileImagePath!).existsSync()
                        ? Text(
                            _currentUser.firstName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentUser.fullName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _currentUser.role.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Profile Information
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoCard(
                    context,
                    title: 'Personal Information',
                    children: [
                      _buildInfoRow(
                        context,
                        icon: Icons.person_outline,
                        label: 'Name',
                        value: _currentUser.name,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        context,
                        icon: Icons.person_outline,
                        label: 'First Name',
                        value: _currentUser.firstName,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        context,
                        icon: Icons.cake_outlined,
                        label: 'Age',
                        value: '${_currentUser.age} years',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    title: 'Contact Information',
                    children: [
                      _buildInfoRow(
                        context,
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: _currentUser.email,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        context,
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: _currentUser.phone,
                      ),
                    ],
                  ),

                  // Coach Assignment for clients
                  if (_currentUser.role == UserRole.client) ...[
                    const SizedBox(height: 16),
                    _buildCoachAssignmentCard(context, isAdmin, isCoach),
                  ],

                  // Client List for coaches
                  if (_currentUser.role == UserRole.coach &&
                      (isAdmin || widget.isCurrentUser)) ...[
                    const SizedBox(height: 16),
                    _buildClientListCard(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachAssignmentCard(
    BuildContext context,
    bool isAdmin,
    bool isCoach,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Assigned Coach',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (isAdmin)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AssignCoachScreen(client: _currentUser),
                        ),
                      );
                    },
                    icon: const Icon(Icons.link, size: 20),
                    label: const Text('Assign'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_currentUser.coachId != null)
              FutureBuilder<UserModel?>(
                future: _getCoachFromDatabase(context, _currentUser.coachId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(
                      'Error loading coach: ${snapshot.error}',
                      style: const TextStyle(color: AppTheme.errorColor),
                    );
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    final coach = snapshot.data!;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          coach.firstName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(coach.fullName),
                      subtitle: Text(coach.email),
                    );
                  }
                  return const Text('No coach assigned');
                },
              )
            else
              const Text('No coach assigned'),
          ],
        ),
      ),
    );
  }

  Widget _buildClientListCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clients',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<UserModel>>(
              future: _getClients(context, _currentUser.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data != null) {
                  final clients = snapshot.data!;
                  if (clients.isEmpty) {
                    return const Text('No clients assigned');
                  }
                  return Column(
                    children: clients.map((client) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.accentColor,
                          child: Text(
                            client.firstName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(client.fullName),
                        subtitle: Text(client.email),
                      );
                    }).toList(),
                  );
                }
                return const Text('No clients assigned');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<UserModel?> _getCoachFromDatabase(
    BuildContext context,
    int coachId,
  ) async {
    try {
      // Query the database directly to avoid provider filter issues
      return await DatabaseService.instance.getUserById(coachId);
    } catch (e) {
      // If any error occurs, return null
      return null;
    }
  }

  Future<List<UserModel>> _getClients(BuildContext context, int coachId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadClientsByCoach(coachId);
    return userProvider.users;
  }
}
