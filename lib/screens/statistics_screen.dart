import 'package:flutter/material.dart';
import '../services/statistics_service.dart';
import '../theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    final stats = await StatisticsService.instance.getOverallStatistics();
    final roleDistribution = await StatisticsService.instance.getRoleDistribution();
    final unassignedClients = await StatisticsService.instance.getUnassignedClientsCount();
    
    setState(() {
      _stats = {
        ...stats,
        'roleDistribution': roleDistribution,
        'unassignedClients': unassignedClients,
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Overview Cards
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Total Users',
                            _stats['totalUsers']?.toString() ?? '0',
                            Icons.people,
                            AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Coaches',
                            _stats['totalCoaches']?.toString() ?? '0',
                            Icons.fitness_center,
                            AppTheme.accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Clients',
                            _stats['totalClients']?.toString() ?? '0',
                            Icons.person,
                            AppTheme.successColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Unassigned',
                            _stats['unassignedClients']?.toString() ?? '0',
                            Icons.person_off,
                            AppTheme.warningColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Age Statistics
                    Text(
                      'Client Age Statistics',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildStatRow(
                              context,
                              'Average Age',
                              '${(_stats['averageAge'] ?? 0).toStringAsFixed(1)} years',
                              Icons.calculate,
                            ),
                            const Divider(),
                            _buildStatRow(
                              context,
                              'Youngest Client',
                              '${_stats['minAge'] ?? 0} years',
                              Icons.child_care,
                            ),
                            const Divider(),
                            _buildStatRow(
                              context,
                              'Oldest Client',
                              '${_stats['maxAge'] ?? 0} years',
                              Icons.elderly,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Coach Statistics
                    Text(
                      'Coach Performance',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildStatRow(
                              context,
                              'Active Coaches',
                              _stats['coachesWithClients']?.toString() ?? '0',
                              Icons.verified,
                            ),
                            const Divider(),
                            _buildStatRow(
                              context,
                              'Avg Clients per Coach',
                              (_stats['averageClientsPerCoach'] ?? 0)
                                  .toStringAsFixed(1),
                              Icons.groups,
                            ),
                            if (_stats['mostPopularCoach'] != null) ...[
                              const Divider(),
                              _buildMostPopularCoach(context),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Role Distribution
                    Text(
                      'Role Distribution',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildRoleDistributionBar(
                              context,
                              'Admins',
                              (_stats['roleDistribution']?['admin'] ?? 0) as int,
                              _stats['totalUsers'] as int,
                              AppTheme.errorColor,
                            ),
                            const SizedBox(height: 12),
                            _buildRoleDistributionBar(
                              context,
                              'Coaches',
                              (_stats['roleDistribution']?['coach'] ?? 0) as int,
                              _stats['totalUsers'] as int,
                              AppTheme.primaryColor,
                            ),
                            const SizedBox(height: 12),
                            _buildRoleDistributionBar(
                              context,
                              'Clients',
                              (_stats['roleDistribution']?['client'] ?? 0) as int,
                              _stats['totalUsers'] as int,
                              AppTheme.accentColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMostPopularCoach(BuildContext context) {
    final coach = _stats['mostPopularCoach'] as Map<String, dynamic>;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top Coach',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  '${coach['firstName']} ${coach['name']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${coach['clientCount']} clients',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDistributionBar(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '$count (${percentage.toStringAsFixed(1)}%)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
