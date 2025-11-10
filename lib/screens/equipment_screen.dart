import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Equipment Management',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Manage gym equipment',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _buildEquipmentCard(
                    context,
                    icon: Icons.fitness_center,
                    title: 'Equipment',
                    count: '24',
                    color: AppTheme.primaryColor,
                  ),
                  _buildEquipmentCard(
                    context,
                    icon: Icons.build,
                    title: 'Maintenance',
                    count: '3',
                    color: AppTheme.warningColor,
                  ),
                  _buildEquipmentCard(
                    context,
                    icon: Icons.inventory,
                    title: 'Stock',
                    count: '156',
                    color: AppTheme.successColor,
                  ),
                  _buildEquipmentCard(
                    context,
                    icon: Icons.warning,
                    title: 'Out of Service',
                    count: '2',
                    color: AppTheme.errorColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add equipment
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Equipment'),
      ),
    );
  }

  Widget _buildEquipmentCard(
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
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
