import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/coach.dart';
import '../providers/auth_provider.dart';
import '../services/coaches_service.dart';
import '../services/ratings_service.dart';


class MemberCoachesScreen extends StatefulWidget {
  const MemberCoachesScreen({super.key});

  @override
  State<MemberCoachesScreen> createState() => _MemberCoachesScreenState();
}

class _MemberCoachesScreenState extends State<MemberCoachesScreen> {
  List<Coach> coaches = [];
  bool loading = true;
  final Map<int, int> _ratings = {}; // coachId -> stars
  Set<int> ratedCoachIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() { loading = true; });
      final list = await CoachesService.instance.list();
      final user = context.read<AuthProvider>().currentUser;
      Set<int> rated = {};
      if (user?.id != null) {
        rated = await RatingsService.instance.listRatedCoachIds(user!.id!);
      }
      if (mounted) {
        setState(() { coaches = list; ratedCoachIds = rated; loading = false; });
      }
    } catch (e) {
      if (mounted) {
        setState(() { loading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading coaches: $e')),
        );
      }
    }
  }

  Future<void> _rateCoach(int coachId) async {
    final user = context.read<AuthProvider>().currentUser!;
    final stars = _ratings[coachId] ?? 5;
    try {
      await RatingsService.instance.addRating(userId: user.id!, coachId: coachId, stars: stars);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks for rating!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Coaches')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: coaches.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final c = coaches[i];
                final current = _ratings[c.id ?? i] ?? 5;
                final isRated = c.id != null && ratedCoachIds.contains(c.id!);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(child: Text(c.name.isNotEmpty ? c.name[0] : '?')),
                  title: Text(c.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((c.bio ?? '').isNotEmpty) Text(c.bio!),
                      Text('⭐ ${c.ratingAvg.toStringAsFixed(1)}'),
                      if (!isRated) ...[
                        const SizedBox(height: 6),
                        Slider(
                          value: current.toDouble(),
                          onChanged: (v) => setState(() => _ratings[c.id ?? i] = v.round()),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: '${current.round()} stars',
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(onPressed: () => _rateCoach(c.id!), child: const Text('Rate')),
                        ),
                      ] else ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Text('Rated', style: TextStyle(color: Colors.green)),
                        ),
                      ],
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            ),
    );
  }
}
