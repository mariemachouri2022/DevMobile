import 'package:flutter/material.dart';
import 'services/db_helper.dart';

class AddEditEquipmentPage extends StatefulWidget {
  final bool isEditing;
  final int? equipmentId;
  final String? initialName;
  final String? initialStatus;

  const AddEditEquipmentPage({
    super.key,
    this.isEditing = false,
    this.equipmentId,
    this.initialName,
    this.initialStatus,
  });

  @override
  State<AddEditEquipmentPage> createState() => _AddEditEquipmentPageState();
}

class _AddEditEquipmentPageState extends State<AddEditEquipmentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String _status = "Fonctionnel";

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _nameController.text = widget.initialName ?? "";
      _status = widget.initialStatus ?? "Fonctionnel";
    }
  }

  Future<void> _saveEquipment() async {
    final db = DatabaseHelper();

    if (_formKey.currentState!.validate()) {
      final data = {
        'nom': _nameController.text,
        'etat': _status,
        'type': 'N/A', // tu peux adapter selon ton modèle
        'localisation': 'Salle 1', // ou un champ supplémentaire du formulaire
        'dateAjout': DateTime.now().toIso8601String(),
        'derniereModification': DateTime.now().toIso8601String(),
      };

      if (widget.isEditing && widget.equipmentId != null) {
        // ✅ Mise à jour
        await db.updateEquipment(widget.equipmentId!, data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Équipement mis à jour ✅")),
        );
      } else {
        // ✅ Ajout
        await db.addEquipment(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Équipement ajouté ✅")),
        );
      }

      Navigator.pop(context, true); // retourne un signal de succès
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B008B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B008B),
        elevation: 0,
        title: Text(widget.isEditing
            ? "Modifier le matériel"
            : "Ajouter un matériel"),
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nom de l’équipement",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? "Veuillez entrer un nom" : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "État",
                  border: OutlineInputBorder(),
                ),
                value: _status,
                items: const [
                  DropdownMenuItem(value: "Fonctionnel", child: Text("Fonctionnel")),
                  DropdownMenuItem(value: "En panne", child: Text("En panne")),
                  DropdownMenuItem(value: "En maintenance", child: Text("En maintenance")),
                ],
                onChanged: (value) => setState(() => _status = value!),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B008B),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _saveEquipment,
                child: Text(widget.isEditing ? "Mettre à jour" : "Ajouter"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
