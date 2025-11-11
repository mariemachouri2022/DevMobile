import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/class_session.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/classes_service.dart';
import '../services/ratings_service.dart';
import '../widgets/rating_stars.dart';
import 'package:intl/intl.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  String? intensity;
  String? objective;
  DateTime? from;
  DateTime? to;

  List<ClassSession> classes = [];
  bool loading = true;
  final Map<int, int> _ratings = {}; // classId -> stars
  Set<int> ratedClassIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() { loading = true; });
      final list = await ClassesService.instance.list(intensity: intensity, objective: objective, from: from, to: to);
      final user = context.read<AuthProvider>().currentUser;
      Set<int> rated = {};
      if (user?.id != null) {
        rated = await RatingsService.instance.listRatedClassIds(user!.id!);
      }
      if (mounted) {
        setState(() { classes = list; ratedClassIds = rated; loading = false; });
      }
    } catch (e) {
      if (mounted) {
        setState(() { loading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading classes: $e')),
        );
      }
    }
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2035));
    if (range != null) {
      setState(() { from = range.start; to = range.end; });
      _load();
    }
  }

  Future<void> _rateClass(int classId) async {
    final user = context.read<AuthProvider>().currentUser!;
    final stars = _ratings[classId] ?? 5;
    await RatingsService.instance.addRating(userId: user.id!, classId: classId, stars: stars);
    if (!mounted) return;
    setState(() { ratedClassIds = {...ratedClassIds, classId}; });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks for rating!')));
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().currentUser?.role == UserRole.admin;
    return Scaffold(
      appBar: AppBar(title: const Text('Classes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownButton<String>(
                  hint: const Text('Intensity'),
                  value: intensity,
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: (v) { setState(() => intensity = v); _load(); },
                ),
                DropdownButton<String>(
                  hint: const Text('Objective'),
                  value: objective,
                  items: const [
                    DropdownMenuItem(value: 'Cardio', child: Text('Cardio')),
                    DropdownMenuItem(value: 'Muscle', child: Text('Muscle')),
                    DropdownMenuItem(value: 'Fitness', child: Text('Fitness')),
                  ],
                  onChanged: (v) { setState(() => objective = v); _load(); },
                ),
                OutlinedButton(onPressed: _pickDateRange, child: const Text('Pick dates')),
                IconButton(onPressed: () { setState(() { intensity = null; objective = null; from = null; to = null; }); _load(); }, icon: const Icon(Icons.clear))
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : classes.isEmpty
                    ? const Center(child: Text('No classes match filters'))
                    : ListView.separated(
                        itemCount: classes.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final c = classes[i];
                          final cid = c.id ?? i; // fallback key if id is null
                          final current = _ratings[cid] ?? 5;
                          final dateStr = DateFormat('EEE, MMM d • HH:mm').format(c.startTime);
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(c.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${c.objective ?? '-'} • ${c.intensity ?? '-'} • $dateStr'),
                                if (!isAdmin && !ratedClassIds.contains(cid)) ...[
                                  const SizedBox(height: 6),
                                  RatingStars(value: current, onChanged: (v) => setState(() => _ratings[cid] = v)),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(onPressed: () => _rateClass(cid), child: const Text('Rate')),
                                  ),
                                ] else if (ratedClassIds.contains(cid)) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    child: const Text('Rated', style: TextStyle(color: Colors.green)),
                                  )
                                ],
                              ],
                            ),
                            isThreeLine: true,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
