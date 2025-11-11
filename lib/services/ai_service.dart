import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  AIService._();
  static final AIService instance = AIService._();

  // Groq API configuration
  static const String _groqApiKey = 'your_groq_api_key'; // Remplacez par votre clé API Groq
  static const String _groqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _groqModel = 'llama-3.3-70b-versatile';

  Future<String?> chat(String userMessage, {List<Map<String, String>> history = const []}) async {
    try {
      final messages = [
        {
          'role': 'system',
          'content': 'You are a helpful gym assistant for SmartFit. You help users with information about memberships, subscriptions, classes, schedules, payments, coaches, and gym policies. Be friendly and concise. Respond in the same language as the user.'
        },
        ...history.map((m) => {'role': m['role'], 'content': m['content']}),
        {'role': 'user', 'content': userMessage},
      ];

      final response = await http.post(
        Uri.parse(_groqEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': _groqModel,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices.first['message'] as Map<String, dynamic>?;
          final content = message?['content'] as String?;
          if (content != null && content.isNotEmpty) {
            return content;
          }
        }
        return 'Sorry, I could not generate a response.';
      } else {
        // Fallback to mock response on API error
        return _getMockResponse(userMessage);
      }
    } catch (e) {
      // Fallback to mock response on connection error
      return _getMockResponse(userMessage);
    }
  }

  String _getMockResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    // Membership/Subscription related
    if (lowerMessage.contains('abonnement') || lowerMessage.contains('membership') || lowerMessage.contains('subscription')) {
      return 'You can manage your membership in the "My Subscription" section. You can view your active membership, renew it, or check payment history.';
    }
    
    // Payment related
    if (lowerMessage.contains('payment') || lowerMessage.contains('paiement') || lowerMessage.contains('pay')) {
      return 'You can view your payment history in the Payments section. Payments are linked to your membership subscription.';
    }
    
    // Classes related
    if (lowerMessage.contains('class') || lowerMessage.contains('cours') || lowerMessage.contains('session')) {
      return 'You can browse classes by coach, schedule, intensity, and objective in the Classes section. You can also rate classes after attending.';
    }
    
    // Hours/Schedule
    if (lowerMessage.contains('hour') || lowerMessage.contains('heure') || lowerMessage.contains('open') || lowerMessage.contains('schedule')) {
      return 'We are open Mon-Fri 6:00-22:00, Sat-Sun 8:00-20:00. You can check your personal schedule in the Planning section.';
    }
    
    // Coach related
    if (lowerMessage.contains('coach') || lowerMessage.contains('trainer')) {
      return 'You can discover coaches and rate them in the Coaches section. Each coach has ratings and reviews from members.';
    }
    
    // Greetings
    if (lowerMessage.contains('bonjour') || lowerMessage.contains('hello') || lowerMessage.contains('hi') || lowerMessage.contains('salut')) {
      return 'Hello! I\'m your gym assistant. I can help you with information about hours, memberships, classes, payments, and coaches. What would you like to know?';
    }
    
    // Default response
    return 'I can help you with information about:\n• Membership and subscriptions\n• Payment history\n• Classes and schedules\n• Coaches\n• Gym hours\n\nWhat would you like to know?';
  }

  // Returns a map with optional 'objective' and 'intensity' inferred by AI
  Future<Map<String, String>?> recommendFilters({required int? age, required String? goals}) async {
    try {
      final prompt = 'Given age=$age and goals="$goals", choose one objective from [Cardio, Muscle, Fitness] and one intensity from [low, medium, high]. Respond as JSON {"objective":"...","intensity":"..."} without extra text.';
      
      final response = await http.post(
        Uri.parse(_groqEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': _groqModel,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.1,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode != 200) return null;
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) return null;
      
      final message = choices.first['message'] as Map<String, dynamic>?;
      final text = message?['content'] as String?;
      if (text == null) return null;
      
      try {
        final j = jsonDecode(text);
        final obj = (j['objective'] as String?)?.trim();
        final inten = (j['intensity'] as String?)?.trim();
        final result = <String, String>{};
        if (obj != null && (obj == 'Cardio' || obj == 'Muscle' || obj == 'Fitness')) {
          result['objective'] = obj;
        }
        if (inten != null && (inten == 'low' || inten == 'medium' || inten == 'high')) {
          result['intensity'] = inten;
        }
        return result.isEmpty ? null : result;
      } catch (_) {
        return null;
      }
    } catch (_) {
      return null;
    }
  }
}
