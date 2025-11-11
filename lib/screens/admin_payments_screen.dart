import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment.dart';
import '../models/membership.dart';
import '../models/user_model.dart';
import '../services/membership_service.dart';
import '../services/database_service.dart';
import '../services/app_database.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  List<Payment> allPayments = [];
  Map<int, Membership> membershipMap = {};
  Map<int, UserModel> userMap = {};
  bool loading = true;
  String? statusFilter;
  double totalRevenue = 0.0;
  double pendingRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() { loading = true; });
      
      // Load all memberships and users
      final allMemberships = await MembershipService.instance.getAllMemberships();
      final allUsers = await DatabaseService.instance.getAllUsers();
      
      // Create maps
      final memMap = <int, Membership>{};
      for (final m in allMemberships) {
        if (m.id != null) {
          memMap[m.id!] = m;
        }
      }
      
      final uMap = <int, UserModel>{};
      for (final u in allUsers) {
        if (u.id != null) {
          uMap[u.id!] = u;
        }
      }
      
      // Load all payments
      final db = await AppDatabase().database;
      final paymentRows = await db.query(
        'payments',
        orderBy: 'date DESC',
      );
      
      final payments = paymentRows.map((e) => Payment.fromMap(e)).toList();
      
      // Calculate revenue
      final revenue = await AnalyticsService.instance.totalRevenue();
      final pending = payments
          .where((p) => p.status == 'pending')
          .fold(0.0, (sum, p) => sum + p.amount);
      
      // Filter payments if needed
      final filtered = statusFilter != null
          ? payments.where((p) => p.status == statusFilter).toList()
          : payments;

      if (mounted) {
        setState(() {
          allPayments = filtered;
          membershipMap = memMap;
          userMap = uMap;
          totalRevenue = revenue;
          pendingRevenue = pending;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { loading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payments: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('All Payments')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final df = DateFormat('yMMMd • HH:mm');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                statusFilter = value == 'all' ? null : value;
              });
              _load();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'paid', child: Text('Paid')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Revenue Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.backgroundColor,
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Revenue',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${totalRevenue.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.successColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pending',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${pendingRevenue.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Filter chip
          if (statusFilter != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: Text('Filter: ${statusFilter!}'),
                onDeleted: () {
                  setState(() { statusFilter = null; });
                  _load();
                },
              ),
            ),
          // Payments list
          Expanded(
            child: allPayments.isEmpty
                ? const Center(child: Text('No payments found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: allPayments.length,
                    itemBuilder: (context, index) {
                      final payment = allPayments[index];
                      final membership = membershipMap[payment.membershipId];
                      final user = membership != null
                          ? userMap[membership.userId]
                          : null;
                      final isPaid = payment.status == 'paid';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isPaid
                                  ? AppTheme.successColor.withOpacity(0.1)
                                  : AppTheme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isPaid ? Icons.check_circle : Icons.pending,
                              color: isPaid
                                  ? AppTheme.successColor
                                  : AppTheme.accentColor,
                            ),
                          ),
                          title: Text(
                            '\$${payment.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (user != null)
                                Text('Member: ${user.fullName}'),
                              Text('${df.format(payment.date)}'),
                              if (payment.method != null)
                                Text('Method: ${payment.method}'),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isPaid
                                  ? AppTheme.successColor.withOpacity(0.1)
                                  : AppTheme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              payment.status.toUpperCase(),
                              style: TextStyle(
                                color: isPaid
                                    ? AppTheme.successColor
                                    : AppTheme.accentColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

