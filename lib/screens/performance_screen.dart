import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Tracking',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Detailed analytics and statistics',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Performance Cards
            _buildPerformanceCard(
              context,
              title: 'Attendance Rate',
              value: '87%',
              change: '+5%',
              isPositive: true,
              icon: Icons.people,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            _buildPerformanceCard(
              context,
              title: 'Monthly Revenue',
              value: '12,450 DT',
              change: '+12%',
              isPositive: true,
              icon: Icons.attach_money,
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 16),
            _buildPerformanceCard(
              context,
              title: 'Client Satisfaction',
              value: '4.8/5',
              change: '+0.3',
              isPositive: true,
              icon: Icons.star,
              color: AppTheme.warningColor,
            ),
            const SizedBox(height: 16),
            _buildPerformanceCard(
              context,
              title: 'Cancellations',
              value: '8',
              change: '-2',
              isPositive: true,
              icon: Icons.cancel,
              color: AppTheme.errorColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(
    BuildContext context, {
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isPositive
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                change,
                style: TextStyle(
                  color: isPositive
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
