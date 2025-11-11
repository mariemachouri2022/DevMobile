import 'package:flutter/material.dart';
import '../../services/ai_service.dart';
import '../../services/settings_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final controller = TextEditingController();
  final keyController = TextEditingController(); // OpenAI key
  final rapidKeyController = TextEditingController(); // RapidAPI key
  final List<_Message> messages = [
    _Message(role: 'bot', text: 'Hi! I\'m your gym assistant. Ask me about hours, memberships, or classes.')
  ];

  final faqs = <String, String>{
    'hours': 'We are open Mon-Fri 6:00-22:00, Sat-Sun 8:00-20:00.',
    'membership': 'We offer Standard, Student, Family, and Premium plans. You can manage them in the app.',
    'classes': 'Browse classes by intensity and objective under Classes. You can also rate classes after attending.',
    'payment': 'Payments can be made by card. See the Payments section for history.',
    'cancel': 'You can cancel from Membership screen. Cancellation follows the terms of your plan.'
  };

  String? apiKey;
  String? rapidApiKey;
  bool thinking = false;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final k = await SettingsService.instance.getOpenAiKey();
    final rk = await SettingsService.instance.getRapidApiKey();
    setState(() { apiKey = k; rapidApiKey = rk; });
  }

  Future<void> _saveKey() async {
    final k = keyController.text.trim();
    if (k.isEmpty) return;
    await SettingsService.instance.setOpenAiKey(k);
    setState(() { apiKey = k; });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API key saved')));
  }

  Future<void> _saveRapidKey() async {
    final k = rapidKeyController.text.trim();
    if (k.isEmpty) return;
    await SettingsService.instance.setRapidApiKey(k);
    setState(() { rapidApiKey = k; });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('RapidAPI key saved')));
  }

  void _send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    setState(() { messages.add(_Message(role: 'user', text: text)); });
    controller.clear();
    _answer(text);
  }

  Future<void> _answer(String q) async {
    setState(() { thinking = true; });
    String reply;
    try {
      final hist = messages.map((m) => {'role': m.role == 'user' ? 'user' : 'assistant', 'content': m.text}).toList();
      final r = await AIService.instance.chat(q, history: hist);
      reply = (r == null || r.isEmpty) ? _faqFallback(q) : r;
    } catch (_) {
      reply = _faqFallback(q);
    }
    setState(() { thinking = false; messages.add(_Message(role: 'bot', text: reply)); });
  }

  String _faqFallback(String q) {
    final lq = q.toLowerCase();
    for (final key in faqs.keys) {
      if (lq.contains(key)) return faqs[key]!;
    }
    return 'I may not have an exact answer. Try keywords like: hours, membership, classes, payment, cancel.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support Chat')),
      body: Column(
        children: [
          // Key fields removed per request; chat is ready out of the box via hardcoded RapidAPI key.
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final m = messages[i];
                final isUser = m.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m.text, style: TextStyle(color: isUser ? Colors.white : Colors.black)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Type a message'))),
              thinking ? const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                       : IconButton(onPressed: _send, icon: const Icon(Icons.send))
            ]),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String role;
  final String text;
  _Message({required this.role, required this.text});
}
