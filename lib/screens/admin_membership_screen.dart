import 'package:flutter/material.dart';
import 'admin_membership_list_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_classes_list_screen.dart';
import 'admin_classes_screen.dart';
import 'admin_coaches_screen.dart';
import 'admin_payments_screen.dart';

class AdminMembershipScreen extends StatefulWidget {
  const AdminMembershipScreen({super.key});

  @override
  State<AdminMembershipScreen> createState() => _AdminMembershipScreenState();
}

class _AdminMembershipScreenState extends State<AdminMembershipScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Settings action
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.of(context).pop();
            },
            tooltip: 'Back',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Membership Management',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Manage memberships, payments, and subscriptions',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              _buildOptionCard(
                context,
                icon: Icons.analytics,
                iconColor: Colors.deepPurple,
                title: 'Analytics',
                subtitle: 'KPIs and charts',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminAnalyticsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                context,
                icon: Icons.card_membership,
                iconColor: Colors.green,
                title: 'Membership Management',
                subtitle: 'Create, renew, suspend, cancel',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminMembershipListScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                context,
                icon: Icons.calendar_today,
                iconColor: Colors.blue,
                title: 'Classes & Coaches',
                subtitle: 'Manage schedules, coaches, filters',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminClassesListScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                context,
                icon: Icons.event_repeat,
                iconColor: Colors.orange,
                title: 'Batch Create Classes',
                subtitle: 'Create sessions across multiple dates for rating tests',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminClassesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                context,
                icon: Icons.person,
                iconColor: Colors.teal,
                title: 'Coaches',
                subtitle: 'Add and manage coaches',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminCoachesScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                context,
                icon: Icons.payment,
                iconColor: Colors.purple,
                title: 'Payments',
                subtitle: 'Track payments and states',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminPaymentsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
