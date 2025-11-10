import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import 'user_form_screen.dart';
import 'assign_coach_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final UserModel user;
  final bool isCurrentUser;

  const UserProfileScreen({
    super.key,
    required this.user,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser?.role == UserRole.admin;
    final isCoach = authProvider.currentUser?.role == UserRole.coach;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCurrentUser ? 'My Profile' : user.fullName),
        actions: [
          if (isAdmin || isCurrentUser)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UserFormScreen(user: user),
                  ),
                );
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
                    child: Text(
                      user.firstName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName,
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
                      user.role.displayName,
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
                        value: user.name,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        context,
                        icon: Icons.person_outline,
                        label: 'First Name',
                        value: user.firstName,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        context,
                        icon: Icons.cake_outlined,
                        label: 'Age',
                        value: '${user.age} years',
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
                        value: user.email,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        context,
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: user.phone,
                      ),
                    ],
                  ),
                  
                  // Coach Assignment for clients
                  if (user.role == UserRole.client) ...[
                    const SizedBox(height: 16),
                    _buildCoachAssignmentCard(context, isAdmin, isCoach),
                  ],

                  // Client List for coaches
                  if (user.role == UserRole.coach && (isAdmin || isCurrentUser)) ...[
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachAssignmentCard(BuildContext context, bool isAdmin, bool isCoach) {
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (isAdmin)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AssignCoachScreen(client: user),
                        ),
                      );
                    },
                    icon: const Icon(Icons.link, size: 20),
                    label: const Text('Assign'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (user.coachId != null)
              FutureBuilder<UserModel?>(
                future: _getCoach(context, user.coachId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<UserModel>>(
              future: _getClients(context, user.id!),
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

  Future<UserModel?> _getCoach(BuildContext context, int coachId) async {
    return await Provider.of<UserProvider>(context, listen: false)
        .loadUsers()
        .then((_) {
      final users = Provider.of<UserProvider>(context, listen: false).users;
      return users.firstWhere((u) => u.id == coachId);
    });
  }

  Future<List<UserModel>> _getClients(BuildContext context, int coachId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadClientsByCoach(coachId);
    return userProvider.users;
  }
}
