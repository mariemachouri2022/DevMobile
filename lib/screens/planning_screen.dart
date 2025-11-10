import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PlanningScreen extends StatelessWidget {
  const PlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion de Planning',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Gérer les séances et horaires',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9, // Ajustez ce ratio si nécessaire
                children: [
                  _buildFeatureCard(
                    context,
                    icon: Icons.calendar_today,
                    title: 'Calendrier',
                    subtitle: 'Vue d\'ensemble',
                    color: AppTheme.primaryColor,
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.schedule,
                    title: 'Horaires',
                    subtitle: 'Gestion des créneaux',
                    color: AppTheme.accentColor,
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.group,
                    title: 'Séances Groupe',
                    subtitle: 'Cours collectifs',
                    color: AppTheme.successColor,
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.person,
                    title: 'Séances Privées',
                    subtitle: 'Coaching individuel',
                    color: AppTheme.warningColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add new session
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Séance'),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
      }) {
    return Card(
      child: InkWell(
        onTap: () {
          // TODO: Navigate to feature
        },
        borderRadius: BorderRadius.circular(12), // Réduit le borderRadius
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 120, // Hauteur minimale
          ),
          padding: const EdgeInsets.all(16), // Padding réduit
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // IMPORTANT: Utilise min pour éviter l'expansion
            children: [
              Container(
                padding: const EdgeInsets.all(12), // Padding réduit
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color), // Taille d'icône réduite
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14, // Taille de police réduite
                ),
                textAlign: TextAlign.center,
                maxLines: 1, // Empêche le texte de prendre plusieurs lignes
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12, // Taille de police réduite
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Limite à 2 lignes maximum
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}