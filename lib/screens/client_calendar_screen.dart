// screens/client_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/planning.dart';
import '../services/database_helper.dart';
import 'chatbot_page.dart';

class ClientCalendarScreen extends StatefulWidget {
  const ClientCalendarScreen({super.key});

  @override
  State<ClientCalendarScreen> createState() => _ClientCalendarScreenState();
}

class _ClientCalendarScreenState extends State<ClientCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Planning> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser != null) {
      final dbHelper = DatabaseHelper();
      _sessions = await dbHelper.getClientSessions(currentUser.fullName);
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<Planning> _getSessionsForDate(DateTime date) {
    return _sessions.where((session) {
      return session.dateSeance.year == date.year &&
          session.dateSeance.month == date.month &&
          session.dateSeance.day == date.day;
    }).toList();
  }

  Widget _buildSessionCard(Planning session) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Container(
          width: 4,
          decoration: BoxDecoration(
            color: _getSessionColor(session.typeSeance),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          session.typeSeance,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${session.heureDebut} - ${session.heureFin}'),
            Text('Salle: ${session.salle}'),
            if (session.nomCoach.isNotEmpty)
              Text('Coach: ${session.nomCoach}'),
            if (session.description != null && session.description!.isNotEmpty)
              Text('Description: ${session.description!}'),
          ],
        ),
        trailing: Icon(
          _getSessionIcon(session.typeSeance),
          color: _getSessionColor(session.typeSeance),
        ),
      ),
    );
  }

  Color _getSessionColor(String typeSeance) {
    switch (typeSeance.toLowerCase()) {
      case 'cardio':
        return Colors.red;
      case 'yoga':
        return Colors.green;
      case 'musculation':
        return Colors.blue;
      case 'crossfit':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  IconData _getSessionIcon(String typeSeance) {
    switch (typeSeance.toLowerCase()) {
      case 'cardio':
        return Icons.directions_run;
      case 'yoga':
        return Icons.self_improvement;
      case 'musculation':
        return Icons.fitness_center;
      case 'crossfit':
        return Icons.sports;
      default:
        return Icons.schedule;
    }
  }

  Widget _buildDateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                    });
                  },
                ),
                Column(
                  children: [
                    Text(
                      _getFormattedDate(_selectedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getDayName(_selectedDate),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showDatePicker,
              child: const Text('Choisir une date'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
        });
      }
    });
  }

  String _getFormattedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDayName(DateTime date) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final dailySessions = _getSessionsForDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Planning'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy), // Icône du chatbot
            onPressed: () {
              // Navigation vers la page du chatbot
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ChatbotPage(),
                ),
              );
            },
            tooltip: 'Assistant SmartFit',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildDateSelector(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Séances du ${_getFormattedDate(_selectedDate)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${dailySessions.length} séance${dailySessions.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: dailySessions.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucune séance prévue',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Vous n\'avez pas de séance programmée pour cette date',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadSessions,
              child: ListView.builder(
                itemCount: dailySessions.length,
                itemBuilder: (context, index) {
                  return _buildSessionCard(dailySessions[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}