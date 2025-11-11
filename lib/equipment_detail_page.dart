import 'package:flutter/material.dart';
import 'edit_equipment_page.dart';

class EquipmentDetailPage extends StatelessWidget {
  final String name;
  final String status;
  final String imagePath;

  const EquipmentDetailPage({
    super.key,
    required this.name,
    required this.status,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B008B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B008B),
        elevation: 0,
        title: const Text("Détails du matériel"),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset(imagePath, height: 120),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "État actuel : $status",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              "Dernière maintenance : 12/09/2025\nDurée d’utilisation : 345 heures\nTechnicien : Karim B.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditEquipmentPage(
                          name: name,
                          status: status,
                          imagePath: imagePath,
                        ),
                      ),
                    );

                    if (result != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "✅ Équipement mis à jour : ${result['name']} (${result['status']})",
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Modifier"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("🗑️ Équipement supprimé")),
                    );
                  },
                  child: const Text("Supprimer"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
