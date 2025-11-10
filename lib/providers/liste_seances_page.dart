import 'package:flutter/material.dart';
import '../models/planning.dart';
import '../services/database_helper.dart';
import 'modifier_seance_page.dart';
import 'creer_seance_page.dart'; // AJOUTER CET IMPORT

class ListeSeancesPage extends StatefulWidget {
  const ListeSeancesPage({super.key});

  @override
  State<ListeSeancesPage> createState() => _ListeSeancesPageState();
}

class _ListeSeancesPageState extends State<ListeSeancesPage> {
  List<Planning> _seances = [];
  List<Planning> _seancesFiltrees = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSeances();
    _searchController.addListener(_filtrerSeances);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSeances() async {
    try {
      final dbHelper = DatabaseHelper();
      final seances = await dbHelper.getAllPlannings();
      setState(() {
        _seances = seances;
        _seancesFiltrees = seances;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Erreur de chargement: $e');
    }
  }

  // AJOUTER CETTE MÉTHODE POUR LA CRÉATION
  void _navigateToCreation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreerSeancePage(),
      ),
    ).then((_) {
      // Rafraîchir la liste après création
      _loadSeances();
    });
  }

  void _filtrerSeances() {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        _seancesFiltrees = _seances;
      });
      return;
    }

    setState(() {
      _seancesFiltrees = _seances.where((seance) {
        return seance.nomCoach.toLowerCase().contains(query) ||
            seance.nomClient.toLowerCase().contains(query) ||
            seance.salle.toLowerCase().contains(query) ||
            seance.typeSeance.toLowerCase().contains(query) ||
            (seance.description != null &&
                seance.description!.toLowerCase().contains(query)) ||
            seance.heureDebut.toLowerCase().contains(query) ||
            seance.heureFin.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _seancesFiltrees = _seances;
    });
  }

  Future<void> _deleteSeance(int id) async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.deletePlanning(id);
      _loadSeances(); // Recharger la liste
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Séance supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Erreur de suppression: $e');
    }
  }

  void _showDeleteDialog(Planning seance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
            'Voulez-vous vraiment supprimer la séance de ${seance.nomClient} avec ${seance.nomCoach} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSeance(seance.id!);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _navigateToModification(Planning seance) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModifierSeancePage(seance: seance),
      ),
    ).then((_) {
      // Rafraîchir la liste après modification
      _loadSeances();
    });
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher une séance...',
            prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: _clearSearch,
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (_) => _filtrerSeances(),
        ),
      ),
    );
  }

  Widget _buildSeanceCard(Planning seance) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    seance.typeSeance,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icône de modification
                    IconButton(
                      onPressed: () => _navigateToModification(seance),
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Modifier la séance',
                    ),
                    // Icône de suppression
                    IconButton(
                      onPressed: () => _showDeleteDialog(seance),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Supprimer la séance',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow('👤 Coach:', seance.nomCoach),
            _buildInfoRow('🧑 Client:', seance.nomClient),
            _buildInfoRow('🏢 Salle:', seance.salle),
            _buildInfoRow('⏰ Horaires:', '${seance.heureDebut} - ${seance.heureFin}'),
            if (seance.description != null && seance.description!.isNotEmpty)
              _buildInfoRow('📝 Description:', seance.description!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Aucune séance planifiée',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Créez votre première séance !',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          // AJOUTER LE BOUTON DANS L'ÉTAT VIDE
          ElevatedButton(
            onPressed: _navigateToCreation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Créer une séance'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Aucune séance trouvée pour "${_searchController.text}"',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Essayez avec d\'autres termes',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _clearSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Effacer la recherche'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AJOUTER L'APPBAR AVEC BOUTON +
      appBar: AppBar(
        title: const Text('📅 Planning des Séances'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          // BOUTON + POUR CRÉER UNE SÉANCE
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreation,
            tooltip: 'Nouvelle séance',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _seances.isEmpty
                ? _buildEmptyState()
                : _seancesFiltrees.isEmpty
                ? _buildSearchEmptyState()
                : RefreshIndicator(
              onRefresh: _loadSeances,
              child: ListView.builder(
                itemCount: _seancesFiltrees.length,
                itemBuilder: (context, index) {
                  return _buildSeanceCard(_seancesFiltrees[index]);
                },
              ),
            ),
          ),
        ],
      ),
      // AJOUTER LE FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreation,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}