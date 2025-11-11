import 'package:flutter/material.dart';
import 'services/db_helper.dart'; // Assure-toi d'importer ton service SQLite

class ReportIssuePage extends StatefulWidget {
  final int equipementId; // Id de l'équipement pour lequel on signale la panne
  const ReportIssuePage({super.key, required this.equipementId});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  List<Map<String, dynamic>> _signalements = [];

  @override
  void initState() {
    super.initState();
    _loadSignalements();
  }

  // 🔹 Charger les signalements de la base
// 🔹 Charger les signalements de la base
  Future<void> _loadSignalements() async {
    try {
      final db = DatabaseHelper();
      final signalements = await db.getTousLesSignalements();
      setState(() {
        _signalements = signalements
            .where((s) => s['equipementId'] == widget.equipementId)
            .toList()
            .reversed
            .toList();
      });
    } catch (e) {
      debugPrint("Erreur load signalements: $e");
    }
  }

// 🔹 Ajouter un signalement
  Future<void> _reportIssue() async {
    if (_formKey.currentState!.validate()) {
      final db = DatabaseHelper();
      await db.signalerPanne(widget.equipementId, _descriptionController.text);

      // Reset formulaire
      _descriptionController.clear();

      // Reload signalements
      await _loadSignalements();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Panne signalée avec succès ✅")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B008B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B008B),
        elevation: 0,
        title: const Text("Signaler une panne"),
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    "Décrivez la panne rencontrée :",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: "Ex: le tapis de course ne démarre plus...",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    validator: (v) =>
                    v!.isEmpty ? "Veuillez entrer une description" : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _reportIssue,
                    child: const Text("Envoyer"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              "📋 Historique des signalements",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 12),
            // Liste des signalements
            Expanded(
              child: _signalements.isEmpty
                  ? const Center(
                child: Text("Aucun signalement pour cet équipement",
                    style: TextStyle(fontSize: 16)),
              )
                  : ListView.builder(
                itemCount: _signalements.length,
                itemBuilder: (context, index) {
                  final s = _signalements[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.report, color: Colors.red),
                      title: Text(s['description']),
                      subtitle: Text(
                          "Statut : ${s['statut']} | Date : ${s['dateSignalement'].substring(0, 10)}"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
