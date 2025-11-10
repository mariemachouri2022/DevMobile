import 'package:flutter/material.dart';
import '../models/planning.dart';
import '../services/database_helper.dart';

class ModifierSeancePage extends StatefulWidget {
  final Planning seance;

  const ModifierSeancePage({super.key, required this.seance});

  @override
  State<ModifierSeancePage> createState() => _ModifierSeancePageState();
}

class _ModifierSeancePageState extends State<ModifierSeancePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descController = TextEditingController();

  String? coach;
  String? client;
  String? salle;
  String? typeSeance;
  TimeOfDay? heureDebut;
  TimeOfDay? heureFin;
  DateTime? dateSeance;

  // Listes mises à jour pour correspondre à vos données
  final List<String> coaches = ['Coach Ahmed', 'Coach Sara', 'Coach Mohamed'];
  final List<String> clients = ['Client 1', 'Client 2', 'Client 3'];
  final List<String> salles = ['Salle A', 'Salle B', 'Salle C'];
  final List<String> types = ['Cardio', 'Musculation', 'Yoga', 'CrossFit', 'Pilates'];

  @override
  void initState() {
    super.initState();
    _initialiserDonnees();
  }

  void _initialiserDonnees() {
    // Initialiser avec les données existantes de la séance
    // Vérifier si les valeurs existent dans les listes, sinon utiliser la première valeur
    coach = _getValidValue(widget.seance.nomCoach, coaches);
    client = _getValidValue(widget.seance.nomClient, clients);
    salle = _getValidValue(widget.seance.salle, salles);
    typeSeance = _getValidValue(widget.seance.typeSeance, types);
    _descController.text = widget.seance.description ?? '';

    // Parser la date et l'heure existantes
    try {
      final parts = widget.seance.heureDebut.split(' ');
      if (parts.length == 2) {
        final dateParts = parts[0].split('-');
        final timeParts = parts[1].split(':');

        if (dateParts.length == 3 && timeParts.length == 2) {
          dateSeance = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
          );

          heureDebut = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
      }

      final finParts = widget.seance.heureFin.split(' ');
      if (finParts.length == 2) {
        final timeParts = finParts[1].split(':');
        if (timeParts.length == 2) {
          heureFin = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
      }
    } catch (e) {
      print('Erreur parsing date: $e');
      // Si erreur de parsing, utiliser l'heure actuelle
      heureDebut = TimeOfDay.now();
      heureFin = TimeOfDay.now().replacing(minute: TimeOfDay.now().minute + 30);
    }
  }

  // Méthode pour s'assurer que la valeur existe dans la liste
  String _getValidValue(String value, List<String> validList) {
    if (validList.contains(value)) {
      return value;
    } else if (validList.isNotEmpty) {
      return validList.first;
    }
    return '';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateSeance ?? DateTime.now(),
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
      initialTime: isDebut ? (heureDebut ?? TimeOfDay.now()) : (heureFin ?? TimeOfDay.now()),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isDebut) {
          heureDebut = picked;
          if (heureFin != null && _isTimeBefore(picked, heureFin!)) {
            heureFin = null;
          }
        } else {
          if (heureDebut != null && _isTimeBefore(picked, heureDebut!)) {
            _showErrorDialog('L\'heure de fin doit être après l\'heure de début');
            return;
          }
          heureFin = picked;
        }
      });
    }
  }

  bool _isTimeBefore(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour < time2.hour) return true;
    if (time1.hour == time2.hour && time1.minute < time2.minute) return true;
    return false;
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

  Future<void> _updateSeance() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (dateSeance == null) {
      _showErrorDialog('Veuillez sélectionner une date');
      return;
    }

    if (heureDebut == null || heureFin == null) {
      _showErrorDialog('Veuillez sélectionner l\'heure de début et de fin');
      return;
    }

    if (_isTimeBefore(heureFin!, heureDebut!)) {
      _showErrorDialog('L\'heure de fin doit être après l\'heure de début');
      return;
    }

    try {
      final dateFormat = '${dateSeance!.year}-${dateSeance!.month.toString().padLeft(2, '0')}-${dateSeance!.day.toString().padLeft(2, '0')}';
      final heureDebutStr = '${heureDebut!.hour.toString().padLeft(2, '0')}:${heureDebut!.minute.toString().padLeft(2, '0')}';
      final heureFinStr = '${heureFin!.hour.toString().padLeft(2, '0')}:${heureFin!.minute.toString().padLeft(2, '0')}';

      final planning = Planning(
        id: widget.seance.id,
        nomCoach: coach!,
        nomClient: client!,
        salle: salle!,
        typeSeance: typeSeance!,
        heureDebut: '$dateFormat $heureDebutStr',
        heureFin: '$dateFormat $heureFinStr',
        dateSeance: dateSeance!,

        description: _descController.text.isEmpty ? null : _descController.text,
      );

      final dbHelper = DatabaseHelper();
      final result = await dbHelper.updatePlanning(planning);

      if (result > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Séance modifiée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        if (mounted) {
          _showErrorDialog('Erreur lors de la modification');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erreur: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la séance'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateSeance,
            tooltip: 'Sauvegarder les modifications',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Coach Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Coach *',
                  border: OutlineInputBorder(),
                ),
                value: coach,
                items: coaches.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => coach = v),
                validator: (v) => v == null ? 'Ce champ est obligatoire' : null,
              ),
              const SizedBox(height: 16),

              // Client Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Client *',
                  border: OutlineInputBorder(),
                ),
                value: client,
                items: clients.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => client = v),
                validator: (v) => v == null ? 'Ce champ est obligatoire' : null,
              ),
              const SizedBox(height: 16),

              // Salle Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Salle *',
                  border: OutlineInputBorder(),
                ),
                value: salle,
                items: salles.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => salle = v),
                validator: (v) => v == null ? 'Ce champ est obligatoire' : null,
              ),
              const SizedBox(height: 16),

              // Type de séance Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Type de séance *',
                  border: OutlineInputBorder(),
                ),
                value: typeSeance,
                items: types.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => typeSeance = v),
                validator: (v) => v == null ? 'Ce champ est obligatoire' : null,
              ),
              const SizedBox(height: 20),

              // Date et heure
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date et heure *',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      // Date
                      ElevatedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          dateSeance == null
                              ? 'Sélectionner la date'
                              : '${dateSeance!.day}/${dateSeance!.month}/${dateSeance!.year}',
                        ),
                        onPressed: () => _selectDate(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnelle)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 30),

              // Bouton de mise à jour
              ElevatedButton(
                onPressed: _updateSeance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Mettre à jour la séance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}