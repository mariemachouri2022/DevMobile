import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';

class AssignCoachScreen extends StatefulWidget {
  final UserModel client;

  const AssignCoachScreen({super.key, required this.client});

  @override
  State<AssignCoachScreen> createState() => _AssignCoachScreenState();
}

class _AssignCoachScreenState extends State<AssignCoachScreen> {
  int? _selectedCoachId;
  List<UserModel> _coaches = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCoachId = widget.client.coachId;
    _loadCoaches();
  }

  Future<void> _loadCoaches() async {
    setState(() => _isLoading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // Clear any existing filters first
    userProvider.clearFilters();
    await userProvider.loadUsersByRole(UserRole.coach);
    setState(() {
      _coaches = userProvider.users
          .where((user) => user.role == UserRole.coach)
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _handleAssign() async {
    if (_selectedCoachId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a coach'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.assignCoachToClient(
      widget.client.id!,
      _selectedCoachId!,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coach assigned successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.errorMessage ?? 'Failed to assign coach'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Coach')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Client Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  color: AppTheme.backgroundColor,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppTheme.accentColor,
                            child: Text(
                              widget.client.firstName[0].toUpperCase(),
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
                                  widget.client.fullName,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  widget.client.email,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Coaches List
                Expanded(
                  child: _coaches.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_search,
                                size: 64,
                                color: AppTheme.textSecondary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No coaches available',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _coaches.length,
                          itemBuilder: (context, index) {
                            final coach = _coaches[index];
                            final isSelected = _selectedCoachId == coach.id;

                            return Card(
                              elevation: isSelected ? 4 : 1,
                              margin: const EdgeInsets.only(bottom: 12),
                              color: isSelected
                                  ? AppTheme.primaryLight.withOpacity(0.1)
                                  : null,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  backgroundColor: isSelected
                                      ? AppTheme.primaryColor
                                      : AppTheme.primaryLight,
                                  child: Text(
                                    coach.firstName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  coach.fullName,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(coach.email),
                                    const SizedBox(height: 2),
                                    Text(coach.phone),
                                  ],
                                ),
                                trailing: Radio<int>(
                                  value: coach.id!,
                                  groupValue: _selectedCoachId,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCoachId = value;
                                    });
                                  },
                                  activeColor: AppTheme.primaryColor,
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedCoachId = coach.id;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),

                // Assign Button
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleAssign,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('ASSIGN COACH'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
