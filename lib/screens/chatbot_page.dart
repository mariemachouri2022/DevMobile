import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../chatbot/service.dart';
import '../models/planning.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/database_helper.dart';
import '../providers/auth_provider.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  List<UserModel> _coaches = [];
  List<String> _salles = ['Salle A', 'Salle B', 'Salle C'];
  List<String> _typesSeance = ['Cardio', 'Musculation', 'Yoga', 'CrossFit', 'Pilates'];

  Map<String, dynamic> _reservationData = {};

  @override
  void initState() {
    super.initState();
    _loadCoachesFromDatabase();
    _addBotMessage(
      '👋 Bonjour ! Je suis votre assistant SmartFit.\n'
          'Je peux vous aider à réserver des séances avec nos coachs professionnels 💪.\n'
          'Que souhaitez-vous faire ?',
    );
  }

  Future<void> _loadCoachesFromDatabase() async {
    try {
      final dbService = DatabaseService.instance;
      final coaches = await dbService.getUsersByRole(UserRole.coach);

      setState(() => _coaches = coaches);

      if (_coaches.isNotEmpty) {
        _addBotMessage(
            'Voici nos coachs disponibles 🧑‍🏫 :\n${_coaches.map((c) => '• ${c.firstName} ${c.name}').join('\n')}\n\n'
                '💡 **Découvrez une séance**\n'
                '👥 **Voir les coachs**\n'
                '📅 **Réserver une séance**'
        );
      }
    } catch (e) {
      _addBotMessage('Désolé, je ne peux pas charger la liste des coachs pour le moment 😕.');
    }
  }

  void _sendMessage() async {
    String text = _textController.text.trim();
    if (text.isEmpty) return;

    _addUserMessage(text);
    _textController.clear();

    setState(() => _isLoading = true);
    await _processMessage(text);
    setState(() => _isLoading = false);
  }

  Future<void> _processMessage(String message) async {
    // D'abord analyser pour la réservation
    _analyzeForReservation(message);

    // Ensuite obtenir la réponse AI seulement si pas de réservation en cours
    if (!_isReservationInProgress()) {
      await _getAIResponse(message);
    }
  }

  void _handleDateTimeInput(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('demain') ||
        lowerMessage.contains('lundi') ||
        lowerMessage.contains('mardi') ||
        lowerMessage.contains('mercredi') ||
        lowerMessage.contains('jeudi') ||
        lowerMessage.contains('vendredi') ||
        lowerMessage.contains('samedi') ||
        lowerMessage.contains('dimanche') ||
        RegExp(r'\d{1,2}h').hasMatch(lowerMessage)) {

      _reservationData['dateTime'] = message;
      _completeReservation();
    } else {
      _addBotMessage(
          '❌ Je n\'ai pas bien compris la date/heure.\n'
              'Veuillez préciser comme : "Demain 10h" ou "Vendredi 15h"'
      );
    }
  }

  Future<void> _completeReservation() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        _addBotMessage('❌ Vous devez être connecté pour réserver.');
        return;
      }

      // Créer l'objet Planning
      final planning = Planning(
        nomCoach: _reservationData['coach'],
        nomClient: currentUser.fullName,
        salle: _reservationData['salle'],
        typeSeance: _reservationData['typeSeance'],
        heureDebut: _extractTime(_reservationData['dateTime']),
        heureFin: _calculateEndTime(_extractTime(_reservationData['dateTime'])),
        dateSeance: _extractDate(_reservationData['dateTime']),
        description: 'Réservé via Assistant SmartFit',
      );

      // Sauvegarder dans la base de données
      final dbHelper = DatabaseHelper();
      await dbHelper.insertPlanning(planning);

      _addBotMessage(
          '🎉 Réservation confirmée !\n\n'
              '✅ Votre séance a été ajoutée à votre planning.\n'
              '• Type: ${_reservationData['typeSeance']}\n'
              '• Coach: ${_reservationData['coach']}\n'
              '• Salle: ${_reservationData['salle']}\n'
              '• Date: ${_reservationData['dateTime']}\n\n'
              'Vous pouvez la voir dans votre calendrier 📅'
      );

      // Réinitialiser les données de réservation
      _reservationData = {};

    } catch (e) {
      _addBotMessage('❌ Erreur lors de la réservation: ${e.toString()}');
    }
  }

  String _extractTime(String dateTimeText) {
    final timeMatch = RegExp(r'(\d{1,2})h').firstMatch(dateTimeText);
    if (timeMatch != null) {
      final hour = timeMatch.group(1);
      return '${hour!.padLeft(2, '0')}:00';
    }
    return '10:00';
  }

  String _calculateEndTime(String startTime) {
    final hour = int.parse(startTime.split(':')[0]);
    final endHour = (hour + 1) % 24;
    return '${endHour.toString().padLeft(2, '0')}:00';
  }

  DateTime _extractDate(String dateTimeText) {
    if (dateTimeText.toLowerCase().contains('demain')) {
      return DateTime.now().add(const Duration(days: 1));
    }
    return DateTime.now();
  }

  void _analyzeForReservation(String message) {
    String lowerMessage = message.toLowerCase();

    // Si nous avons déjà les infos de base, traiter la date/heure
    if (_reservationData.containsKey('typeSeance') &&
        _reservationData.containsKey('coach') &&
        _reservationData.containsKey('salle') &&
        !_reservationData.containsKey('dateTime')) {
      _handleDateTimeInput(message);
      return;
    }

    // Analyse du type de séance
    for (String type in _typesSeance) {
      if (lowerMessage.contains(type.toLowerCase())) {
        _reservationData['typeSeance'] = type;
        break;
      }
    }

    // Analyse du coach
    for (UserModel coach in _coaches) {
      String fullName = '${coach.firstName} ${coach.name}';
      if (lowerMessage.contains(coach.firstName.toLowerCase()) ||
          lowerMessage.contains(coach.name.toLowerCase()) ||
          lowerMessage.contains(fullName.toLowerCase())) {
        _reservationData['coach'] = fullName;
        _reservationData['coachId'] = coach.id;
        break;
      }
    }

    // Analyse de la salle
    for (String salle in _salles) {
      if (lowerMessage.contains(salle.toLowerCase())) {
        _reservationData['salle'] = salle;
        break;
      }
    }

    _checkReservationCompletion();
  }

  void _checkReservationCompletion() {
    if (_reservationData.containsKey('typeSeance') &&
        _reservationData.containsKey('coach') &&
        _reservationData.containsKey('salle')) {
      _addBotMessage(
        '✅ Parfait !\n'
            '• Type: ${_reservationData['typeSeance']}\n'
            '• Coach: ${_reservationData['coach']}\n'
            '• Salle: ${_reservationData['salle']}\n\n'
            'Quand souhaitez-vous réserver ? (ex: Demain 10h, Vendredi 15h)',
      );
    } else {
      _suggestMissingInformation();
    }
  }

  void _suggestMissingInformation() {
    String missing = '';
    if (!_reservationData.containsKey('typeSeance')) {
      missing += '• Type de séance: ${_typesSeance.join(', ')}\n';
    }
    if (!_reservationData.containsKey('coach')) {
      missing += '• Coach: ${_coaches.map((c) => '${c.firstName} ${c.name}').join(', ')}\n';
    }
    if (!_reservationData.containsKey('salle')) {
      missing += '• Salle: ${_salles.join(', ')}\n';
    }

    if (missing.isNotEmpty && _reservationData.isNotEmpty) {
      _addBotMessage('🔎 Il me manque quelques infos :\n$missing\nPouvez-vous les préciser ?');
    }
  }

  Future<void> _getAIResponse(String userMessage) async {
    try {
      final conversationHistory = _messages
          .map((msg) => {'role': msg.isUser ? 'user' : 'assistant', 'content': msg.text})
          .toList();

      final response = await OpenRouterService.getAIResponse(userMessage, conversationHistory);
      _addBotMessage(response);
    } catch (e) {
      if (!_isReservationInProgress()) {
        _addBotMessage('😅 Désolé, un problème technique est survenu.');
      }
    }
  }

  bool _isReservationInProgress() {
    return _reservationData.isNotEmpty;
  }

  void _addUserMessage(String text) {
    setState(() => _messages.add(ChatMessage(text: text, isUser: true)));
    _scrollToBottom();
  }

  void _addBotMessage(String text) {
    setState(() => _messages.add(ChatMessage(text: text, isUser: false)));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildQuickReplies() {
    final quickReplies = [
      'Réserver une séance',
      'Voir les coachs',
      'Connaître les tarifs',
      'Horaires d\'ouverture',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: quickReplies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => Container(
          constraints: BoxConstraints(
            minWidth: 100,
          ),
          child: ElevatedButton(
            onPressed: () {
              _textController.text = quickReplies[i];
              _sendMessage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade50,
              foregroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              quickReplies[i],
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: '💬 Tapez votre message...',
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text('🤖 Assistant SmartFit', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFEDE7F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == _messages.length && _isLoading) {
                    return const ChatBubble(message: 'Assistant réfléchit...', isUser: false, isLoading: true);
                  }
                  final msg = _messages[i];
                  return ChatBubble(message: msg.text, isUser: msg.isUser);
                },
              ),
            ),
            _buildQuickReplies(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isLoading;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.deepPurple,
              child: Text('🤖', style: TextStyle(fontSize: 12)),
            ),
          if (!isUser) const SizedBox(width: 8),

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isUser ? Colors.deepPurple : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(1, 3),
                  ),
                ],
              ),
              child: isLoading
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Assistant réfléchit...', style: TextStyle(fontSize: 13)),
                ],
              )
                  : Text(
                message,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),

          if (isUser) const SizedBox(width: 8),
          if (isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }
}