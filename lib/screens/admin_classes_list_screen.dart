import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/class_session.dart';
import '../models/coach.dart';
import '../services/classes_service.dart';
import '../services/coaches_service.dart';
import '../theme/app_theme.dart';

class AdminClassesListScreen extends StatefulWidget {
  const AdminClassesListScreen({super.key});

  @override
  State<AdminClassesListScreen> createState() => _AdminClassesListScreenState();
}

class _AdminClassesListScreenState extends State<AdminClassesListScreen> {
  List<ClassSession> classes = [];
  Map<int, Coach> coachMap = {};
  bool loading = true;
  String? intensityFilter;
  String? objectiveFilter;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() { loading = true; });
      
      // Load classes with filters
      final classesList = await ClassesService.instance.list(
        intensity: intensityFilter,
        objective: objectiveFilter,
        from: fromDate,
        to: toDate,
      );
      
      // Load coaches
      final coachesList = await CoachesService.instance.list();
      final cMap = <int, Coach>{};
      for (final coach in coachesList) {
        if (coach.id != null) {
          cMap[coach.id!] = coach;
        }
      }
      
      if (mounted) {
        setState(() {
          classes = classesList;
          coachMap = cMap;
          loading = false;
        });
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
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (range != null) {
      setState(() {
        fromDate = range.start;
        toDate = range.end;
      });
      _load();
    }
  }

  void _clearFilters() {
    setState(() {
      intensityFilter = null;
      objectiveFilter = null;
      fromDate = null;
      toDate = null;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEE, MMM d • HH:mm');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes & Coaches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _clearFilters();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear Filters'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(12),
            color: AppTheme.backgroundColor,
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    DropdownButton<String>(
                      value: intensityFilter,
                      hint: const Text('Intensity'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All Intensity')),
                        DropdownMenuItem(value: 'low', child: Text('Low')),
                        DropdownMenuItem(value: 'medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'high', child: Text('High')),
                      ],
                      onChanged: (v) {
                        setState(() => intensityFilter = v);
                        _load();
                      },
                    ),
                    DropdownButton<String>(
                      value: objectiveFilter,
                      hint: const Text('Objective'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All Objective')),
                        DropdownMenuItem(value: 'Cardio', child: Text('Cardio')),
                        DropdownMenuItem(value: 'Muscle', child: Text('Muscle')),
                        DropdownMenuItem(value: 'Fitness', child: Text('Fitness')),
                      ],
                      onChanged: (v) {
                        setState(() => objectiveFilter = v);
                        _load();
                      },
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickDateRange,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        fromDate == null || toDate == null
                            ? 'Date Range'
                            : '${DateFormat('MMM d').format(fromDate!)} - ${DateFormat('MMM d').format(toDate!)}',
                      ),
                    ),
                    if (intensityFilter != null || objectiveFilter != null || fromDate != null)
                      OutlinedButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Clear'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Classes list
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : classes.isEmpty
                    ? const Center(child: Text('No classes found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: classes.length,
                        itemBuilder: (context, index) {
                          final classSession = classes[index];
                          final coach = classSession.coachId != null
                              ? coachMap[classSession.coachId]
                              : null;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.fitness_center,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              title: Text(
                                classSession.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  if (coach != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.person, size: 16, color: AppTheme.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          coach.name,
                                          style: const TextStyle(color: AppTheme.textSecondary),
                                        ),
                                      ],
                                    ),
                                  if (coach != null) const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (classSession.objective != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            classSession.objective!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      if (classSession.intensity != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.accentColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            classSession.intensity!.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.accentColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        df.format(classSession.startTime),
                                        style: const TextStyle(color: AppTheme.textSecondary),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.schedule, size: 16, color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${DateFormat('HH:mm').format(classSession.startTime)} - ${DateFormat('HH:mm').format(classSession.endTime)}',
                                        style: const TextStyle(color: AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                  if (classSession.capacity != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.people, size: 16, color: AppTheme.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Capacity: ${classSession.capacity}',
                                          style: const TextStyle(color: AppTheme.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              isThreeLine: true,
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

