import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion du Store',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Produits, ventes et panier',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStoreCard(
                    context,
                    icon: Icons.shopping_bag,
                    title: 'Produits',
                    count: '45',
                    color: AppTheme.primaryColor,
                  ),
                  _buildStoreCard(
                    context,
                    icon: Icons.shopping_cart,
                    title: 'Commandes',
                    count: '12',
                    color: AppTheme.accentColor,
                  ),
                  _buildStoreCard(
                    context,
                    icon: Icons.inventory_2,
                    title: 'Stock',
                    count: '234',
                    color: AppTheme.successColor,
                  ),
                  _buildStoreCard(
                    context,
                    icon: Icons.attach_money,
                    title: 'Ventes',
                    count: '3.2K DT',
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
          // TODO: Add product
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau Produit'),
      ),
    );
  }

  Widget _buildStoreCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
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
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
