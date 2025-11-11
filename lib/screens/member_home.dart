import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/class_session.dart';
import '../providers/auth_provider.dart';
import '../services/recommendation_service.dart';
import 'membership_screen.dart';
import 'payments_screen.dart';
import 'classes_screen.dart';
import 'member_coaches_screen.dart';
import 'gamification_screen.dart';
import 'chatbot_screen.dart';

class MemberHome extends StatelessWidget {
  const MemberHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${auth.currentUser?.name ?? ''}'),
        actions: [
          IconButton(onPressed: () => auth.logout(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: ListTile(title: const Text('My Membership'), subtitle: const Text('Type, status, QR access'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipScreen())))),
          const SizedBox(height: 12),
          Card(child: ListTile(title: const Text('Payments'), subtitle: const Text('Track payment history'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsScreen())))),
          const SizedBox(height: 12),
          Card(child: ListTile(title: const Text('Classes'), subtitle: const Text('Browse & filter classes by coach, schedule, intensity'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassesScreen())))),
          const SizedBox(height: 12),
          Card(child: ListTile(title: const Text('Coaches'), subtitle: const Text('Discover coaches and rate them once'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberCoachesScreen())))),
          const SizedBox(height: 12),
          Card(child: ListTile(title: const Text('Gamification'), subtitle: const Text('Points and badges'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GamificationScreen())))),
          const SizedBox(height: 12),
          Card(child: ListTile(title: const Text('Support Chat (Mock)'), subtitle: const Text('Get quick answers to FAQs'), trailing: const Icon(Icons.chat_bubble_outline), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen())))),
          const SizedBox(height: 16),
          const Text('Recommended for you', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (auth.currentUser != null)
            FutureBuilder<List<ClassSession>>(
              future: RecommendationService.instance.recommendFor(auth.currentUser!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()));
                }
                final recs = snapshot.data ?? [];
                if (recs.isEmpty) {
                  return const Card(child: ListTile(title: Text('No personalized recommendations yet.')));
                }
                return Column(
                  children: [
                    for (final c in recs)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.fitness_center),
                          title: Text(c.title),
                          subtitle: Text('${c.objective ?? '-'} • ${c.intensity ?? '-'} • ${c.startTime}'),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClassesScreen())), child: const Text('See all classes')),
                    )
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
