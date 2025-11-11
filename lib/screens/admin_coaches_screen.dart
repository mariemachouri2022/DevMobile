import 'package:flutter/material.dart';
import '../models/coach.dart';
import '../services/coaches_service.dart';

class AdminCoachesScreen extends StatefulWidget {
  const AdminCoachesScreen({super.key});

  @override
  State<AdminCoachesScreen> createState() => _AdminCoachesScreenState();
}

class _AdminCoachesScreenState extends State<AdminCoachesScreen> {
  final nameCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  bool creating = false;
  List<Coach> coaches = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await CoachesService.instance.list();
    setState(() { coaches = list; loading = false; });
  }

  Future<void> _add() async {
    if (nameCtrl.text.trim().isEmpty) return;
    setState(() { creating = true; });
    await CoachesService.instance.add(name: nameCtrl.text.trim(), bio: bioCtrl.text.trim().isEmpty ? null : bioCtrl.text.trim());
    nameCtrl.clear();
    bioCtrl.clear();
    await _load();
    if (!mounted) return;
    setState(() { creating = false; });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coach added')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin • Coaches')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Add Coach', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                        const SizedBox(height: 8),
                        TextField(controller: bioCtrl, decoration: const InputDecoration(labelText: 'Bio (optional)')),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(onPressed: creating ? null : _add, child: creating ? const CircularProgressIndicator() : const Text('Add')),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Coaches', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (coaches.isEmpty)
                  const Card(child: ListTile(title: Text('No coaches yet.')))
                else
                  ...coaches.map((c) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(c.name),
                          subtitle: Text(c.bio ?? ''),
                          trailing: Text('⭐ ${(c.ratingAvg).toStringAsFixed(1)}'),
                        ),
                      )),
              ],
            ),
    );
  }
}
