import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'assistant_ia_page.dart';
import 'report_issue_page.dart';
import 'ListeEquipements.dart';
import 'equipment_history_page.dart';
import 'services/db_helper.dart';
class DashboardIntelligentPage extends StatefulWidget {
  const DashboardIntelligentPage({super.key});

  @override
  State<DashboardIntelligentPage> createState() => _DashboardIntelligentPageState();
}

class _DashboardIntelligentPageState extends State<DashboardIntelligentPage> {
  int totalEquipements = 0;
  int equipementsEnPanne = 0;
  int equipementsActifs = 0;
  Map<String, int> typeCount = {}; // pour graphique à barres
  List<Map<String, dynamic>> dernieresInterventions = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final db = DatabaseHelper(); // au lieu de DatabaseHelper.instance
    final allEquipements = await db.getEquipments();


    setState(() {
      totalEquipements = allEquipements.length;
      equipementsEnPanne = allEquipements
          .where((e) => (e['etat'] ?? '').toLowerCase().contains('panne'))
          .length;

      equipementsActifs = allEquipements
          .where((e) => (e['etat'] ?? '').toLowerCase().contains('fonctionnel'))
          .length;

      // Répartition par type
      typeCount.clear();
      for (var e in allEquipements) {
        final type = e['type'] ?? 'Général';
        typeCount[type] = (typeCount[type] ?? 0) + 1;
      }
    });
    print("DEBUG: Tous les équipements => $allEquipements");
    print("DEBUG: En panne => ${allEquipements.where((e) => e['etat'] == 'en panne').toList()}");
    print("DEBUG: Fonctionnels => ${allEquipements.where((e) => e['etat'] == 'fonctionnel').toList()}");

    List<Map<String, dynamic>> hist = [];
    for (var e in allEquipements) {
      final h = await db.getHistoriqueByEquipement(e['id']);
      hist.addAll(h);
    }
    hist.sort((a, b) => b['dateChangement'].compareTo(a['dateChangement']));
    setState(() {
      dernieresInterventions = hist.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B008B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B008B),
        title: const Text(
          "📊 Tableau de bord intelligent",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Statistiques générales",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StatCard(title: "Équipements", value: "$totalEquipements", color: Colors.purple),
                  StatCard(title: "En Panne", value: "$equipementsEnPanne", color: Colors.red),
                  StatCard(title: "Actifs", value: "$equipementsActifs", color: Colors.green),
                ],
              ),
              const SizedBox(height: 25),

              // ---- Graphique circulaire ----
              const Text("Répartition des statuts",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      if (equipementsActifs > 0)
                        PieChartSectionData(
                          value: equipementsActifs.toDouble(),
                          title: 'Actifs',
                          color: Colors.green,
                          radius: 50,
                        ),
                      if (equipementsEnPanne > 0)
                        PieChartSectionData(
                          value: equipementsEnPanne.toDouble(),
                          title: 'En panne',
                          color: Colors.red,
                          radius: 50,
                        ),
                    ],
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // ---- Graphique à barres ----
              const Text("Utilisation par type d’équipement",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final labels = typeCount.keys.toList();
                            return Text(labels[value.toInt() % labels.length]);
                          },
                        ),
                      ),
                    ),
                    barGroups: typeCount.entries.map((entry) {
                      final index = typeCount.keys.toList().indexOf(entry.key);
                      return BarChartGroupData(
                        x: index,
                        barRods: [BarChartRodData(toY: entry.value.toDouble(), color: Colors.purple)],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // ---- Historique ----


              // ---- Raccourcis vers autres pages ----
              const Text("Accès rapide",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ShortcutButton(
                    label: "Liste équipements",
                    icon: Icons.fitness_center,
                    color: Colors.purple,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ListeEquipementsPage())),
                  ),
                  ShortcutButton(
                    label: "Signalement",
                    icon: Icons.report_problem,
                    color: Colors.red,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ReportIssuePage(equipementId: 1)),
                    ),
                  ),
                  ShortcutButton(
                    label: "Assistant IA",
                    icon: Icons.smart_toy,
                    color: Colors.indigo,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AssistantIAPage())),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// 🟣 Carte de statistique
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300, blurRadius: 5, offset: const Offset(2, 2))
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }
}

// 🟣 Bouton raccourci
class ShortcutButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const ShortcutButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon),
      label: Text(label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      onPressed: onTap,
    );
  }
}
