import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion des Abonnements',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Plans et souscriptions',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    title: 'Actifs',
                    count: '156',
                    icon: Icons.check_circle,
                    color: AppTheme.successColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    title: 'Expirés',
                    count: '8',
                    icon: Icons.warning,
                    color: AppTheme.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              'Plans Disponibles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            _buildSubscriptionPlan(
              context,
              name: 'Plan Mensuel',
              price: '50 DT/mois',
              features: ['Accès illimité', 'Cours collectifs', '1 séance coaching'],
              subscribers: 45,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            _buildSubscriptionPlan(
              context,
              name: 'Plan Trimestriel',
              price: '135 DT/3 mois',
              features: ['Accès illimité', 'Cours collectifs', '3 séances coaching', '10% réduction'],
              subscribers: 67,
              color: AppTheme.accentColor,
            ),
            const SizedBox(height: 16),
            _buildSubscriptionPlan(
              context,
              name: 'Plan Annuel',
              price: '480 DT/an',
              features: ['Accès illimité', 'Cours collectifs', '12 séances coaching', '20% réduction', 'Suivi nutritionnel'],
              subscribers: 44,
              color: AppTheme.successColor,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add subscription plan
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau Plan'),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              count,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlan(
    BuildContext context, {
    required String name,
    required String price,
    required List<String> features,
    required int subscribers,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$subscribers abonnés',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check, size: 20, color: color),
                      const SizedBox(width: 8),
                      Text(feature),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
