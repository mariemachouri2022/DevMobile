import 'package:flutter/material.dart';
import 'package:smartfit/models/coach.dart';
import 'package:smartfit/services/classes_service.dart';
import 'package:smartfit/services/coaches_service.dart';


class AdminClassesScreen extends StatefulWidget {
  const AdminClassesScreen({super.key});

  @override
  State<AdminClassesScreen> createState() => _AdminClassesScreenState();
}

class _AdminClassesScreenState extends State<AdminClassesScreen> {
  final titleCtrl = TextEditingController();
  String? intensity;
  String? objective;
  int? coachId;
  List<Coach> coaches = [];
  bool loadingCoaches = true;
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay startTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 19, minute: 0);
  int? capacity;
  bool creating = false;

  @override
  void initState() {
    super.initState();
    _loadCoaches();
  }

  Future<void> _loadCoaches() async {
    final list = await CoachesService.instance.list();
    setState(() {
      coaches = list;
      loadingCoaches = false;
    });
  }

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2035));
    if (range != null) setState(() { startDate = range.start; endDate = range.end; });
  }

  Future<void> _createBatch() async {
    if (titleCtrl.text.trim().isEmpty || startDate == null || endDate == null) return;
    setState(() { creating = true; });
    await ClassesService.instance.addBatchDates(
      coachId: coachId,
      title: titleCtrl.text.trim(),
      intensity: intensity,
      objective: objective,
      startDate: startDate!,
      endDate: endDate!,
      startTime: startTime,
      endTime: endTime,
      capacity: capacity,
    );
    if (!mounted) return;
    setState(() { creating = false; });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Classes created across dates')));
  }

  Future<void> _createSingle() async {
    if (titleCtrl.text.trim().isEmpty || startDate == null) return;
    setState(() { creating = true; });
    final st = DateTime(startDate!.year, startDate!.month, startDate!.day, startTime.hour, startTime.minute);
    final et = DateTime(startDate!.year, startDate!.month, startDate!.day, endTime.hour, endTime.minute);
    await ClassesService.instance.add(
      coachId: coachId,
      title: titleCtrl.text.trim(),
      intensity: intensity,
      objective: objective,
      startTime: st,
      endTime: et,
      capacity: capacity,
    );
    if (!mounted) return;
    setState(() { creating = false; });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class created')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin • Batch Classes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: coachId,
            items: [
              for (final c in coaches) DropdownMenuItem(value: c.id, child: Text(c.name)),
            ],
            onChanged: (v) => setState(() => coachId = v),
            decoration: const InputDecoration(labelText: 'Coach'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: intensity,
            items: const [
              DropdownMenuItem(value: 'low', child: Text('Low')),
              DropdownMenuItem(value: 'medium', child: Text('Medium')),
              DropdownMenuItem(value: 'high', child: Text('High')),
            ],
            onChanged: (v) => setState(() => intensity = v),
            decoration: const InputDecoration(labelText: 'Intensity'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: objective,
            items: const [
              DropdownMenuItem(value: 'Cardio', child: Text('Cardio')),
              DropdownMenuItem(value: 'Muscle', child: Text('Muscle')),
              DropdownMenuItem(value: 'Fitness', child: Text('Fitness')),
            ],
            onChanged: (v) => setState(() => objective = v),
            decoration: const InputDecoration(labelText: 'Objective'),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: _pickRange, child: Text(startDate == null ? 'Pick date range' : '${startDate!.toLocal()} → ${endDate!.toLocal()}'))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () async { final t = await showTimePicker(context: context, initialTime: startTime); if (t != null) setState(() => startTime = t); }, child: Text('Start time: ${startTime.format(context)}'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: () async { final t = await showTimePicker(context: context, initialTime: endTime); if (t != null) setState(() => endTime = t); }, child: Text('End time: ${endTime.format(context)}'))),
          ]),
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Capacity (optional)'),
            onChanged: (v) => capacity = int.tryParse(v),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: creating ? null : _createSingle, child: creating ? const CircularProgressIndicator() : const Text('Create one class'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: creating ? null : _createBatch, child: creating ? const CircularProgressIndicator() : const Text('Create across dates'))),
          ]),
          const SizedBox(height: 12),
          const Text('Tip: After creating, members can rate these classes from the Classes screen.'),
        ],
      ),
    );
  }
}
