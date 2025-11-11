import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfit/providers/auth_provider.dart';
import '../../services/gamification_service.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen> {
  int points = 0;
  List<Map<String, Object?>> badges = [];
  bool loading = true;
  bool canDaily = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = context.read<AuthProvider>().currentUser!;
      await GamificationService.instance.ensureDefaultBadges();
      final p = await GamificationService.instance.getPoints(user.id!);
      final b = await GamificationService.instance.listUserBadges(user.id!);
      final daily = await GamificationService.instance.canClaimDaily(user.id!);
      if (mounted) {
        setState(() { points = p; badges = b; canDaily = daily; loading = false; });
      }
    } catch (e) {
      if (mounted) {
        setState(() { loading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading gamification: $e')),
        );
      }
    }
  }

  Future<void> _claimDaily() async {
    final user = context.read<AuthProvider>().currentUser!;
    final ok = await GamificationService.instance.claimDailyChallenge(user.id!);
    if (ok) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Daily challenge claimed! +10 pts')));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Already claimed today')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Gamification')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.stars),
              title: Text('Points: $points'),
              subtitle: const Text('Earn points by attending classes'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.orange),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Daily Challenge: Claim once per day to earn points')), 
                  ElevatedButton(onPressed: canDaily ? _claimDaily : null, child: Text(canDaily ? 'Claim +10' : 'Claimed')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Badges', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (badges.isEmpty)
            const Card(child: ListTile(title: Text('No badges yet. Keep going!')))
          else
            ...badges.map((b) => Card(
              child: ListTile(
                leading: const Icon(Icons.emoji_events),
                title: Text(b['name'] as String? ?? ''),
                subtitle: Text('Threshold: ${(b['threshold'] as int?) ?? 0} • Earned: ${(b['awarded_at'] as String?) ?? ''}'),
              ),
            )),
        ],
      ),
    );
  }
}
