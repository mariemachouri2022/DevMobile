import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'admin_analytics_screen.dart';
import 'admin_membership_screen.dart';
import 'classes_screen.dart';
import 'admin_coaches_screen.dart';
import 'payments_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(onPressed: () => auth.logout(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: ListTile(title: const Text('Analytics'), subtitle: const Text('KPIs and charts'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen())))),
          const SizedBox(height: 12),
          Card(child: ListTile(title: const Text('Membership Management'), subtitle: const Text('Create, renew, suspend, cancel'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMembershipScreen())))),
          const SizedBox(height: 12),
          Card(child: ListTile(title: const Text('Classes & Coaches'), subtitle: const Text('Manage schedules, coaches, filters'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassesScreen())))),
          const SizedBox(height: 12),
          Card(child: ListTile(title: const Text('Coaches'), subtitle: const Text('Add and manage coaches'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCoachesScreen())))),
          const SizedBox(height: 12),
          Card(child: ListTile(title: const Text('Payments'), subtitle: const Text('Track payments and states'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsScreen())))),
        ],
      ),
    );
  }
}
