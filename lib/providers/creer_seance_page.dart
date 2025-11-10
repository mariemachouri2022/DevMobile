import 'package:flutter/material.dart';
import '../models/planning.dart';
import '../models/user_model.dart';
import '../services/database_helper.dart';
import '../services/database_service.dart';

class CreerSeancePage extends StatefulWidget {
  const CreerSeancePage({super.key});

  @override
  State<CreerSeancePage> createState() => _CreerSeancePageState();
}

class _CreerSeancePageState extends State<CreerSeancePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descController = TextEditingController();

  String? coach;
  String? client;
  String? salle;
  String? typeSeance;
  TimeOfDay? heureDebut;
  TimeOfDay? heureFin;
  DateTime? dateSeance;

  // 🔹 Ces listes seront remplies depuis la BD
  List<UserModel> _coaches = [];
  List<UserModel> _clients = [];

  final List<String> salles = ['Salle A', 'Salle B', 'Salle C'];
  final List<String> types = ['Cardio', 'Musculation', 'Yoga', 'CrossFit', 'Pilates'];

  @override
  void initState() {
    super.initState();
    _loadUsersFromDB();
  }

  Future<void> _loadUsersFromDB() async {
    final dbService = DatabaseService.instance;
    final coaches = await dbService.getUsersByRole(UserRole.coach);
    final clients = await dbService.getUsersByRole(UserRole.client);

    setState(() {
      _coaches = coaches;
      _clients = clients;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => dateSeance = picked);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isDebut) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isDebut) {
          heureDebut = picked;
        } else {
          heureFin = picked;
        }
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSeance() async {
    if (!_formKey.currentState!.validate()) return;

    if (dateSeance == null || heureDebut == null || heureFin == null) {
      _showErrorDialog('Veuillez compléter tous les champs de date et heure');
      return;
    }

    final dateFormat =
        '${dateSeance!.year}-${dateSeance!.month.toString().padLeft(2, '0')}-${dateSeance!.day.toString().padLeft(2, '0')}';
    final heureDebutStr =
        '${heureDebut!.hour.toString().padLeft(2, '0')}:${heureDebut!.minute.toString().padLeft(2, '0')}';
    final heureFinStr =
        '${heureFin!.hour.toString().padLeft(2, '0')}:${heureFin!.minute.toString().padLeft(2, '0')}';

    final planning = Planning(
      nomCoach: coach!,
      nomClient: client!,
      salle: salle!,
      typeSeance: typeSeance!,
      heureDebut: '$dateFormat $heureDebutStr',
      heureFin: '$dateFormat $heureFinStr',
      dateSeance: dateSeance!, // PARAMÈTRE REQUIS AJOUTÉ ICI

      description: _descController.text.isEmpty ? null : _descController.text,
    );

    final dbHelper = DatabaseHelper();
    final result = await dbHelper.insertPlanning(planning);

    if (result > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Séance enregistrée avec succès')),
      );
      Navigator.pop(context);
    } else {
      _showErrorDialog('Erreur lors de l\'enregistrement');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une séance'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _coaches.isEmpty && _clients.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              // Coach
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Coach *',
                  border: OutlineInputBorder(),
                ),
                value: coach,
                items: _coaches
                    .map((u) => DropdownMenuItem(
                  value: '${u.firstName} ${u.name}',
                  child: Text('${u.firstName} ${u.name}'),
                ))
                    .toList(),
                onChanged: (v) => setState(() => coach = v),
                validator: (v) =>
                v == null ? 'Veuillez choisir un coach' : null,
              ),
              const SizedBox(height: 16),

              // Client
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Client *',
                  border: OutlineInputBorder(),
                ),
                value: client,
                items: _clients
                    .map((u) => DropdownMenuItem(
                  value: '${u.firstName} ${u.name}',
                  child: Text('${u.firstName} ${u.name}'),
                ))
                    .toList(),
                onChanged: (v) => setState(() => client = v),
                validator: (v) =>
                v == null ? 'Veuillez choisir un client' : null,
              ),
              const SizedBox(height: 16),

              // Salle
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Salle *',
                  border: OutlineInputBorder(),
                ),
                value: salle,
                items: salles
                    .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => salle = v),
                validator: (v) =>
                v == null ? 'Ce champ est obligatoire' : null,
              ),
              const SizedBox(height: 16),

              // Type de séance
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Type de séance *',
                  border: OutlineInputBorder(),
                ),
                value: typeSeance,
                items: types
                    .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => typeSeance = v),
                validator: (v) =>
                v == null ? 'Ce champ est obligatoire' : null,
              ),
              const SizedBox(height: 20),

              // Date
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  dateSeance == null
                      ? 'Sélectionner la date'
                      : '${dateSeance!.day}/${dateSeance!.month}/${dateSeance!.year}',
                ),
                onPressed: () => _selectDate(context),
              ),
              const SizedBox(height: 10),

              // Heures
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        heureDebut == null
                            ? 'Début'
                            : heureDebut!.format(context),
                      ),
                      onPressed: () => _selectTime(context, true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        heureFin == null
                            ? 'Fin'
                            : heureFin!.format(context),
                      ),
                      onPressed: () => _selectTime(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnelle)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              // Bouton Enregistrer
              ElevatedButton(
                onPressed: _saveSeance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Enregistrer la séance',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
