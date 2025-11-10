import 'package:flutter/material.dart';
import 'screens/planning_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TestPlanningApp());
}

class TestPlanningApp extends StatelessWidget {
  const TestPlanningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Planning Screen',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SmartFit Admin'),
          actions: [
            IconButton(icon: const Icon(Icons.person), onPressed: () {}),
            IconButton(icon: const Icon(Icons.logout), onPressed: () {}),
          ],
          bottom: TabBar(
            controller: null,
            isScrollable: true,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(icon: Icon(Icons.calendar_today), text: 'Planning'),
              Tab(icon: Icon(Icons.fitness_center), text: 'Matériels'),
              Tab(icon: Icon(Icons.trending_up), text: 'Performance'),
            ],
          ),
        ),
        body: const PlanningScreen(),
      ),
    );
  }
}
