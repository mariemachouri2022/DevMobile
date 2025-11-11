import 'package:flutter/material.dart';
import 'add_edit_equipment_page.dart';
import 'services/db_helper.dart';
import 'equipment_detail_page.dart';

class ListeEquipementsPage extends StatefulWidget {
  const ListeEquipementsPage({super.key});

  @override
  State<ListeEquipementsPage> createState() => _ListeEquipementsPageState();
}

class _ListeEquipementsPageState extends State<ListeEquipementsPage> {
  List<Map<String, dynamic>> equipments = [];

  @override
  void initState() {
    super.initState();
    _loadEquipments();
  }

  Future<void> _loadEquipments() async {
    final data = await DatabaseHelper().getEquipments(); // ou DatabaseService.instance.getTousLesEquipements()
    setState(() {
      equipments = data;
    });
  }

  Future<void> _deleteEquipment(int id) async {
    await DatabaseHelper().deleteEquipment(id); // supprime depuis SQLite
    _loadEquipments(); // recharge la liste pour mettre à jour l'UI
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B008B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B008B),
        elevation: 0,
        title: const Text(
          "📋 Liste des équipements",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddEditEquipmentPage(),
                    ),
                  );
                  if (result == true) _loadEquipments();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B008B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "➕ Ajouter un équipement",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: equipments.length,
                itemBuilder: (context, index) {
                  final eq = equipments[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    elevation: 2,
                    child: ListTile(
                      leading: eq['imagePath'] != null
                          ? Image.asset(eq['imagePath'], height: 50, width: 50)
                          : const Icon(Icons.fitness_center, size: 50),
                      title: Text(
                        eq['name'] ?? eq['nom'], // selon ton champ
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(eq['status'] ?? eq['etat']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.deepPurple),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditEquipmentPage(
                                    isEditing: true,
                                    equipmentId: eq['id'],
                                    initialName: eq['name'] ?? eq['nom'],
                                    initialStatus: eq['status'] ?? eq['etat'],
                                  ),
                                ),
                              );
                              if (result == true) _loadEquipments();
                            },
                          ),

                        ],
                      ),
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
