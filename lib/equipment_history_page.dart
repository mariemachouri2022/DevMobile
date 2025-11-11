import 'package:flutter/material.dart';
import 'services/db_helper.dart'; // Assure-toi d'importer ta classe DatabaseService

class EquipmentHistoryPage extends StatefulWidget {
  final int equipementId; // L'id de l'équipement dont tu veux l'historique

  const EquipmentHistoryPage({super.key, required this.equipementId});

  @override
  State<EquipmentHistoryPage> createState() => _EquipmentHistoryPageState();
}

class _EquipmentHistoryPageState extends State<EquipmentHistoryPage> {
  List<Map<String, dynamic>> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      setState(() { isLoading = true; });

      final db = DatabaseHelper(); // <- factory singleton
      final data = await db.getHistoriqueByEquipement(widget.equipementId);

      setState(() {
        history = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() { isLoading = false; });
      debugPrint("Erreur lors du chargement de l'historique : $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B008B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B008B),
        elevation: 0,
        title: const Text("Historique du matériel"),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : history.isEmpty
            ? const Center(
          child: Text(
            "Aucun historique pour cet équipement",
            style: TextStyle(fontSize: 16),
          ),
        )
            : ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              child: ListTile(
                leading:
                const Icon(Icons.history, color: Colors.blue),
                title: Text(item["commentaire"] ?? item["nouvelEtat"] ?? ""),
                subtitle: Text(
                    "Date : ${item["dateChangement"] ?? "Non défini"}\nAncien état : ${item["ancienEtat"] ?? "-"}\nNouvel état : ${item["nouvelEtat"] ?? "-"}"),
              ),
            );
          },
        ),
      ),
    );
  }
}
