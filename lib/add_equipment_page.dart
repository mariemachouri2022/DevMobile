import 'package:flutter/material.dart';

class AddEquipmentPage extends StatefulWidget {
  const AddEquipmentPage({super.key});

  @override
  State<AddEquipmentPage> createState() => _AddEquipmentPageState();
}

class _AddEquipmentPageState extends State<AddEquipmentPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  String _selectedStatus = 'Fonctionnel';
  String? _selectedImage;

  final List<String> _statusList = [
    'Fonctionnel',
    'En panne',
    'En maintenance',
  ];

  final List<String> _imageOptions = [
    'assets/images/bike.jpg',
    'assets/images/treadmill.jpg',
    'assets/images/elliptical.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B008B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B008B),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "➕ Ajouter un équipement",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              // Nom de l’équipement
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nom de l’équipement",
                  prefixIcon: const Icon(Icons.fitness_center),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Statut
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: _statusList
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Statut",
                  prefixIcon: const Icon(Icons.info_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Sélection d’image
              DropdownButtonFormField<String>(
                value: _selectedImage,
                hint: const Text("Sélectionner une image"),
                items: _imageOptions
                    .map((path) => DropdownMenuItem(
                  value: path,
                  child: Row(
                    children: [
                      Image.asset(path, height: 40, width: 40),
                      const SizedBox(width: 10),
                      Text(path.split('/').last),
                    ],
                  ),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedImage = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Image",
                  prefixIcon: const Icon(Icons.image),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Bouton Enregistrer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Veuillez sélectionner une image."),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // 🔹 Simulation de l’enregistrement
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Équipement ajouté avec succès 🎉"),
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text(
                    "Enregistrer",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B008B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
