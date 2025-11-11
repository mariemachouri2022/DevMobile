import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/membership.dart';
import '../models/user_model.dart';
import '../models/payment.dart';
import '../models/attendance.dart';
import '../models/class_session.dart';
import '../models/coach.dart';
import '../services/membership_service.dart';
import '../services/database_service.dart';
import '../services/analytics_service.dart';
import '../services/payment_service.dart';
import '../services/gamification_service.dart';
import '../services/coaches_service.dart';
import '../services/app_database.dart';
import '../widgets/energetic_widgets.dart';
import '../theme/app_theme.dart';

class AdminMembershipListScreen extends StatefulWidget {
  const AdminMembershipListScreen({super.key});

  @override
  State<AdminMembershipListScreen> createState() => _AdminMembershipListScreenState();
}

class _AdminMembershipListScreenState extends State<AdminMembershipListScreen> {
  List<Membership> memberships = [];
  List<UserModel> users = [];
  Map<int, UserModel> userMap = {};
  Map<int, Coach?> coachMap = {};
  bool loading = true;
  String? statusFilter;
  
  // Analytics data
  int activeSubscribers = 0;
  double totalRevenue = 0.0;
  int totalAttendance = 0;
  
  // Member details cache
  Map<int, List<Payment>> paymentsCache = {};
  Map<int, List<Attendance>> attendanceCache = {};
  Map<int, int> pointsCache = {};
  Map<int, List<Map<String, Object?>>> badgesCache = {};
  Map<int, List<ClassSession>> classesCache = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() { loading = true; });
      
      // Load analytics
      final analytics = await Future.wait([
        AnalyticsService.instance.activeSubscribers(),
        AnalyticsService.instance.totalRevenue(),
        AnalyticsService.instance.totalAttendance(),
      ]);
      
      // Load memberships and users
      final allMemberships = await MembershipService.instance.getAllMemberships();
      final allUsers = await DatabaseService.instance.getAllUsers();
      final allCoaches = await CoachesService.instance.list();
      
      // Create user map for quick lookup
      final map = <int, UserModel>{};
      for (final user in allUsers) {
        if (user.id != null) {
          map[user.id!] = user;
        }
      }
      
      // Create coach map - map user ID to their assigned coach
      final coachMapData = <int, Coach?>{};
      for (final user in allUsers) {
        if (user.id != null && user.coachId != null) {
          try {
            final coach = allCoaches.firstWhere(
              (c) => c.id == user.coachId,
            );
            coachMapData[user.id!] = coach;
          } catch (_) {
            // Coach not found, leave as null
            coachMapData[user.id!] = null;
          }
        }
      }

      // Filter memberships if status filter is set
      final filtered = statusFilter != null
          ? allMemberships.where((m) => m.status == statusFilter).toList()
          : allMemberships;

      if (mounted) {
        setState(() {
          memberships = filtered;
          users = allUsers;
          userMap = map;
          coachMap = coachMapData;
          activeSubscribers = analytics[0] as int;
          totalRevenue = analytics[1] as double;
          totalAttendance = analytics[2] as int;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { loading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading memberships: $e')),
        );
      }
    }
  }
  
  Future<void> _loadMemberDetails(int userId) async {
    if (paymentsCache.containsKey(userId) && 
        attendanceCache.containsKey(userId) &&
        pointsCache.containsKey(userId)) {
      return; // Already loaded
    }
    
    try {
      // Load membership for user - try to get any membership, not just active
      final db = await AppDatabase().database;
      final membershipRows = await db.query(
        'memberships',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'start_date DESC',
        limit: 1,
      );
      
      if (membershipRows.isEmpty) {
        // No membership found, still load other details
        final results = await Future.wait([
          Future.value(<Payment>[]),
          _getUserAttendance(userId),
          GamificationService.instance.getPoints(userId),
          GamificationService.instance.listUserBadges(userId),
          _getUserClasses(userId),
        ]);
        
        if (mounted) {
          setState(() {
            paymentsCache[userId] = results[0] as List<Payment>;
            attendanceCache[userId] = results[1] as List<Attendance>;
            pointsCache[userId] = results[2] as int;
            badgesCache[userId] = results[3] as List<Map<String, Object?>>;
            classesCache[userId] = results[4] as List<ClassSession>;
          });
        }
        return;
      }
      
      final membership = Membership.fromMap(membershipRows.first);
      
      // Load all details in parallel
      final results = await Future.wait([
        membership.id != null
            ? PaymentService.instance.listForMembership(membership.id!)
            : Future<List<Payment>>.value(<Payment>[]),
        _getUserAttendance(userId),
        GamificationService.instance.getPoints(userId),
        GamificationService.instance.listUserBadges(userId),
        _getUserClasses(userId),
      ]);
      
      if (mounted) {
        setState(() {
          paymentsCache[userId] = results[0] as List<Payment>;
          attendanceCache[userId] = results[1] as List<Attendance>;
          pointsCache[userId] = results[2] as int;
          badgesCache[userId] = results[3] as List<Map<String, Object?>>;
          classesCache[userId] = results[4] as List<ClassSession>;
        });
      }
    } catch (e) {
      // Log error but don't crash
      if (mounted) {
        debugPrint('Error loading member details for user $userId: $e');
      }
    }
  }
  
  Future<List<Attendance>> _getUserAttendance(int userId) async {
    final db = await AppDatabase().database;
    final rows = await db.query(
      'attendance',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: 20,
    );
    return rows.map((e) => Attendance.fromMap(e)).toList();
  }
  
  Future<List<ClassSession>> _getUserClasses(int userId) async {
    final db = await AppDatabase().database;
    final attendanceRows = await db.query(
      'attendance',
      where: 'user_id = ? AND class_id IS NOT NULL',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: 10,
    );
    
    if (attendanceRows.isEmpty) return [];
    
    final classIds = attendanceRows
        .map((e) => e['class_id'] as int?)
        .whereType<int>()
        .toSet();
    
    if (classIds.isEmpty) return [];
    
    final classRows = await db.query(
      'class_sessions',
      where: 'id IN (${classIds.map((_) => '?').join(',')})',
      whereArgs: classIds.toList(),
      orderBy: 'start_time DESC',
    );
    
    return classRows.map((e) => ClassSession.fromMap(e)).toList();
  }

  Future<void> _createMembershipForUser(UserModel? selectedUser) async {
    if (selectedUser == null || selectedUser.id == null) {
      // Show user selection dialog
      final user = await showDialog<UserModel>(
        context: context,
        builder: (context) => _UserSelectionDialog(users: users),
      );
      if (user == null) return;
      selectedUser = user;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CreateMembershipDialog(),
    );

    if (result == null) return;

    try {
      final now = DateTime.now();
      final months = result['months'] as int;
      final end = DateTime(now.year, now.month + months, now.day);
      await MembershipService.instance.createMembership(
        userId: selectedUser.id!,
        type: result['type'] as String,
        startDate: now,
        endDate: end,
      );
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Membership created')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating membership: $e')),
        );
      }
    }
  }

  Future<void> _renewMembership(Membership membership) async {
    final addMonths = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) => _RenewSheet(),
    );
    if (addMonths == null) return;

    try {
      final currentEnd = membership.endDate.isAfter(DateTime.now())
          ? membership.endDate
          : DateTime.now();
      final newEnd = DateTime(
        currentEnd.year,
        currentEnd.month + addMonths,
        currentEnd.day,
      );
      await MembershipService.instance.renew(
        membershipId: membership.id!,
        newEndDate: newEnd,
      );
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Membership renewed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error renewing membership: $e')),
        );
      }
    }
  }

  Future<void> _recordPayment(Membership membership) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _PaymentDialog(),
    );
    
    if (result == null || membership.id == null) return;
    
    try {
      await PaymentService.instance.addPayment(
        membershipId: membership.id!,
        amount: result['amount'] as double,
        status: result['status'] as String,
        method: result['method'] as String?,
      );
      await _loadMemberDetails(membership.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment recorded')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recording payment: $e')),
        );
      }
    }
  }

  Future<void> _confirmAnd(Membership membership, ActionType type) async {
    final titles = {
      ActionType.suspend: 'Suspend membership?',
      ActionType.cancel: 'Cancel membership?',
    };
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titles[type]!),
        content: const Text('You can reactivate later by renewing if applicable.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      if (type == ActionType.suspend) {
        await MembershipService.instance.suspend(membership.id!);
      } else {
        await MembershipService.instance.cancel(membership.id!);
      }
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Membership ${type == ActionType.suspend ? 'suspended' : 'cancelled'}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('All Memberships')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Memberships'),
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
              const PopupMenuItem(value: 'active', child: Text('Active')),
              const PopupMenuItem(value: 'suspended', child: Text('Suspended')),
              const PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
              const PopupMenuItem(value: 'expired', child: Text('Expired')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Analytics Dashboard
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.backgroundColor,
            child: Row(
              children: [
                Expanded(
                  child: KpiCard(
                    title: 'Active Subscribers',
                    value: activeSubscribers.toString(),
                    icon: Icons.people,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KpiCard(
                    title: 'Total Revenue',
                    value: '\$${totalRevenue.toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KpiCard(
                    title: 'Total Attendance',
                    value: totalAttendance.toString(),
                    icon: Icons.check_circle,
                  ),
                ),
              ],
            ),
          ),
          // Filter chips
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
          // Memberships list
          Expanded(
            child: memberships.isEmpty
                ? const Center(child: Text('No memberships found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: memberships.length,
                    itemBuilder: (context, index) {
                      final membership = memberships[index];
                      final user = userMap[membership.userId];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          onExpansionChanged: (expanded) {
                            if (expanded && user?.id != null) {
                              _loadMemberDetails(user!.id!);
                            }
                          },
                          leading: CircleAvatar(
                            child: Text(
                              user?.firstName[0].toUpperCase() ?? '?',
                            ),
                          ),
                          title: Text(user?.fullName ?? 'User ${membership.userId}'),
                          subtitle: Text('${membership.type} • ${membership.status}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: membership.status == 'active'
                                  ? AppTheme.successColor.withOpacity(0.1)
                                  : AppTheme.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              membership.status.toUpperCase(),
                              style: TextStyle(
                                color: membership.status == 'active'
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildMembershipDetails(membership, user),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createMembershipForUser(null),
        icon: const Icon(Icons.add),
        label: const Text('Create Membership'),
      ),
    );
  }
  
  Widget _buildMembershipDetails(Membership membership, UserModel? user) {
    final userId = user?.id;
    final payments = userId != null ? paymentsCache[userId] : null;
    final attendance = userId != null ? attendanceCache[userId] : null;
    final points = userId != null ? pointsCache[userId] : null;
    final badges = userId != null ? badgesCache[userId] : null;
    final classes = userId != null ? classesCache[userId] : null;
    final coach = userId != null ? coachMap[userId] : null;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic Info
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                label: 'Start',
                value: membership.startDate.toString().split(' ').first,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoTile(
                label: 'End',
                value: membership.endDate.toString().split(' ').first,
              ),
            ),
          ],
        ),
        if (coach != null) ...[
          const SizedBox(height: 12),
          _InfoTile(
            label: 'Assigned Coach',
            value: coach.name,
          ),
        ],
        // QR Code
        if (membership.qrCode != null) ...[
          const SizedBox(height: 16),
          Center(
            child: QrImageView(
              data: membership.qrCode!,
              version: QrVersions.auto,
              size: 150.0,
            ),
          ),
        ],
        // Payments Section
        if (payments != null) ...[
          const SizedBox(height: 16),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payments',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => _recordPayment(membership),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Record Payment'),
              ),
            ],
          ),
          if (payments.isEmpty)
            const Text('No payments recorded', style: TextStyle(color: AppTheme.textSecondary))
          else
            ...payments.take(5).map((p) => ListTile(
              dense: true,
              leading: Icon(
                p.status == 'paid' ? Icons.check_circle : Icons.pending,
                color: p.status == 'paid' ? AppTheme.successColor : AppTheme.accentColor,
              ),
              title: Text('\$${p.amount.toStringAsFixed(2)}'),
              subtitle: Text('${p.date.toString().split(' ').first} • ${p.status}'),
              trailing: p.method != null ? Text(p.method!) : null,
            )),
        ],
        // Attendance Section
        if (attendance != null) ...[
          const SizedBox(height: 16),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Attendance',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text('${attendance.length} visits'),
            ],
          ),
          if (attendance.isEmpty)
            const Text('No attendance records', style: TextStyle(color: AppTheme.textSecondary))
          else
            ...attendance.take(5).map((a) => ListTile(
              dense: true,
              leading: const Icon(Icons.check_circle, color: AppTheme.successColor),
              title: Text(a.date.toString().split(' ').first),
              subtitle: Text(a.viaQr ? 'Via QR Code' : 'Manual'),
            )),
        ],
        // Gamification Section
        if (points != null) ...[
          const SizedBox(height: 16),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gamification',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text('$points points', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          if (badges != null && badges.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: badges.map((b) => Chip(
                label: Text(b['name'] as String),
                avatar: const Icon(Icons.star, size: 16),
              )).toList(),
            ),
          ],
        ],
        // Classes Section
        if (classes != null && classes.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(),
          const Text(
            'Recent Classes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...classes.take(5).map((c) => ListTile(
            dense: true,
            leading: const Icon(Icons.fitness_center, color: AppTheme.primaryColor),
            title: Text(c.title),
            subtitle: Text('${c.startTime.toString().split(' ').first} • ${c.objective ?? 'N/A'}'),
          )),
        ],
        // Actions
        const SizedBox(height: 16),
        const Divider(),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _renewMembership(membership),
                icon: const Icon(Icons.autorenew),
                label: const Text('Renew'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _recordPayment(membership),
                icon: const Icon(Icons.payment),
                label: const Text('Payment'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _confirmAnd(membership, ActionType.suspend),
                icon: const Icon(Icons.pause_circle_filled),
                label: const Text('Suspend'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _confirmAnd(membership, ActionType.cancel),
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum ActionType { suspend, cancel }

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RenewSheet extends StatefulWidget {
  @override
  State<_RenewSheet> createState() => _RenewSheetState();
}

class _RenewSheetState extends State<_RenewSheet> {
  int months = 1;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Renew Membership',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: months,
              items: const [1, 3, 6, 12]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text('$e month(s)'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => months = v ?? 1),
              decoration: const InputDecoration(labelText: 'Extend by'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context, months),
                icon: const Icon(Icons.check),
                label: const Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateMembershipDialog extends StatefulWidget {
  @override
  State<_CreateMembershipDialog> createState() => _CreateMembershipDialogState();
}

class _CreateMembershipDialogState extends State<_CreateMembershipDialog> {
  String type = 'Standard';
  int months = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Membership'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: type,
            items: const [
              DropdownMenuItem(value: 'Standard', child: Text('Standard')),
              DropdownMenuItem(value: 'Student', child: Text('Student')),
              DropdownMenuItem(value: 'Family', child: Text('Family')),
              DropdownMenuItem(value: 'Premium', child: Text('Premium')),
            ],
            onChanged: (v) => setState(() => type = v ?? 'Standard'),
            decoration: const InputDecoration(labelText: 'Type'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: months,
            items: const [1, 3, 6, 12]
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text('$e month(s)'),
                    ))
                .toList(),
            onChanged: (v) => setState(() => months = v ?? 1),
            decoration: const InputDecoration(labelText: 'Duration'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            {'type': type, 'months': months},
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _UserSelectionDialog extends StatelessWidget {
  final List<UserModel> users;

  const _UserSelectionDialog({required this.users});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select User'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(user.firstName[0].toUpperCase()),
              ),
              title: Text(user.fullName),
              subtitle: Text(user.email),
              onTap: () => Navigator.pop(context, user),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _amountController = TextEditingController();
  String _status = 'paid';
  String? _method;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Payment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '\$',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'paid', child: Text('Paid')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'paid'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _method,
            decoration: const InputDecoration(
              labelText: 'Payment Method (Optional)',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('None')),
              DropdownMenuItem(value: 'Cash', child: Text('Cash')),
              DropdownMenuItem(value: 'Card', child: Text('Card')),
              DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
              DropdownMenuItem(value: 'Online', child: Text('Online')),
            ],
            onChanged: (v) => setState(() => _method = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text);
            if (amount == null || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid amount')),
              );
              return;
            }
            Navigator.pop(context, {
              'amount': amount,
              'status': _status,
              'method': _method,
            });
          },
          child: const Text('Record'),
        ),
      ],
    );
  }
}

