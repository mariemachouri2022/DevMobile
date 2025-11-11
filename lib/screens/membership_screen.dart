import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smartfit/models/membership.dart';
import 'package:smartfit/providers/auth_provider.dart';
import 'package:smartfit/services/membership_service.dart';
import 'package:smartfit/theme/app_theme.dart';


class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  Membership? active;
  bool loading = true;
  String type = 'Standard';
  int months = 1;
  String? statusMsg;
  bool expiringSoon = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final userId = context.read<AuthProvider>().currentUser!.id!;
      final m = await MembershipService.instance.getActiveMembership(userId);
      bool soon = false;
      if (m != null) {
        soon = await MembershipService.instance.isExpiringSoon(m, days: 7);
      }
      if (mounted) {
        setState(() { active = m; loading = false; expiringSoon = soon; });
      }
    } catch (e) {
      if (mounted) {
        setState(() { loading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading membership: $e')),
        );
      }
    }
  }

  Future<void> _create() async {
    final userId = context.read<AuthProvider>().currentUser!.id!;
    final now = DateTime.now();
    final end = DateTime(now.year, now.month + months, now.day);
    final m = await MembershipService.instance.createMembership(userId: userId, type: type, startDate: now, endDate: end);
    setState(() { active = m; statusMsg = 'Membership created'; expiringSoon = false; });
  }

  Future<void> _renew() async {
    if (active == null) return;
    final addMonths = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) => _RenewSheet(),
    );
    if (addMonths == null) return;
    final currentEnd = active!.endDate.isAfter(DateTime.now()) ? active!.endDate : DateTime.now();
    final newEnd = DateTime(currentEnd.year, currentEnd.month + addMonths, currentEnd.day);
    await MembershipService.instance.renew(membershipId: active!.id!, newEndDate: newEnd);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membership renewed')));
  }

  Future<void> _confirmAnd(ActionType type) async {
    if (active == null) return;
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );
    if (confirm != true) return;
    if (type == ActionType.suspend) {
      await MembershipService.instance.suspend(active!.id!);
    } else {
      await MembershipService.instance.cancel(active!.id!);
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My Membership')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: active == null ? _buildCreate() : _buildActive(),
      ),
    );
  }

  Widget _buildCreate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Start a new plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
                  items: const [1, 3, 6, 12].map((e) => DropdownMenuItem(value: e, child: Text('$e month(s)'))).toList(),
                  onChanged: (v) => setState(() => months = v ?? 1),
                  decoration: const InputDecoration(labelText: 'Duration'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(onPressed: _create, icon: const Icon(Icons.bolt), label: const Text('Activate membership')),
                ),
              ],
            ),
          ),
        ),
        if (statusMsg != null) ...[
          const SizedBox(height: 12),
          Text(statusMsg!, style: const TextStyle(color: AppTheme.successColor)),
        ],
      ],
    );
  }

  Widget _buildActive() {
    final m = active!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (expiringSoon)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, color: AppTheme.accentColor),
              SizedBox(width: 8),
              Expanded(child: Text('Your membership expires soon. Renew now to avoid interruption.')),
            ]),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.type, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: m.status == 'active' ? AppTheme.successColor.withOpacity(0.12) : AppTheme.errorColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(m.status.toUpperCase(), style: TextStyle(color: m.status == 'active' ? AppTheme.successColor : AppTheme.errorColor, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _InfoTile(label: 'Start', value: m.startDate.toString().split(' ').first)),
                const SizedBox(width: 12),
                Expanded(child: _InfoTile(label: 'End', value: m.endDate.toString().split(' ').first)),
              ]),
              const SizedBox(height: 16),
              if ((m.qrCode ?? '').isNotEmpty) ...[
                Center(
                  child: QrImageView(
                    data: m.qrCode!,
                    version: QrVersions.auto,
                    size: 180,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(children: [
                Expanded(child: FilledButton.icon(onPressed: _renew, icon: const Icon(Icons.autorenew), label: const Text('Renew'))),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: OutlinedButton.icon(onPressed: () => _confirmAnd(ActionType.suspend), icon: const Icon(Icons.pause_circle_filled), label: const Text('Suspend'))),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton.icon(onPressed: () => _confirmAnd(ActionType.cancel), icon: const Icon(Icons.cancel), label: const Text('Cancel'))),
              ]),
            ]),
          ),
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
      decoration: BoxDecoration(color: AppTheme.backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ]),
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
            const Text('Renew Membership', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: months,
              items: const [1, 3, 6, 12].map((e) => DropdownMenuItem(value: e, child: Text('$e month(s)'))).toList(),
              onChanged: (v) => setState(() => months = v ?? 1),
              decoration: const InputDecoration(labelText: 'Extend by'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(onPressed: () => Navigator.pop(context, months), icon: const Icon(Icons.check), label: const Text('Confirm')),
            ),
          ],
        ),
      ),
    );
  }
}
