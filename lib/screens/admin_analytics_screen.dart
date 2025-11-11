import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/analytics_service.dart';
import '../widgets/energetic_widgets.dart';


class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  int activeSubs = 0;
  double revenue = 0;
  int attendance = 0;
  List<Map<String, Object?>> topCoaches = [];
  double avgClassRating = 0;
  List<Map<String, Object?>> recentRatings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final a = await AnalyticsService.instance.activeSubscribers();
    final r = await AnalyticsService.instance.totalRevenue();
    final t = await AnalyticsService.instance.totalAttendance();
    final tc = await AnalyticsService.instance.topRatedCoaches();
    final ar = await AnalyticsService.instance.averageClassRating();
    final rr = await AnalyticsService.instance.recentClassRatings();
    setState(() {
      activeSubs = a;
      revenue = r;
      attendance = t;
      topCoaches = tc;
      avgClassRating = ar;
      recentRatings = rr;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(spacing: 12, runSpacing: 12, children: [
            SizedBox(width: 220, child: KpiCard(title: 'Active Subscribers', value: '$activeSubs', icon: Icons.people)),
            SizedBox(width: 220, child: KpiCard(title: 'Revenue', value: revenue.toStringAsFixed(2), icon: Icons.payments)),
            SizedBox(width: 220, child: KpiCard(title: 'Attendance', value: '$attendance', icon: Icons.qr_code_scanner)),
            SizedBox(width: 220, child: KpiCard(title: 'Avg Class Rating', value: avgClassRating.toStringAsFixed(1), icon: Icons.star_rate)),
          ]),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Top Rated Coaches', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= topCoaches.length) return const SizedBox.shrink();
                              final name = (topCoaches[i]['name'] as String?) ?? '';
                              return Padding(padding: const EdgeInsets.only(top: 6), child: Text(name, style: const TextStyle(fontSize: 10)));
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (int i = 0; i < topCoaches.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: ((topCoaches[i]['rating_avg'] as num?)?.toDouble() ?? 0),
                                width: 16,
                              ),
                            ],
                          )
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Recent Class Ratings', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (recentRatings.isEmpty)
                  const ListTile(title: Text('No ratings yet'))
                else
                  ...recentRatings.map((e) {
                    final stars = (e['stars'] as int?) ?? 0;
                    final title = (e['class_title'] as String?) ?? 'Class';
                    final date = (e['date'] as String?) ?? '';
                    final comment = (e['comment'] as String?) ?? '';
                    return ListTile(
                      leading: const Icon(Icons.fitness_center),
                      title: Text(title),
                      subtitle: Text(comment.isEmpty ? date : '$date\n$comment'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('$stars'),
                        ],
                      ),
                      isThreeLine: comment.isNotEmpty,
                    );
                  }),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
