import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenRouterService {
  static const String _apiKey = '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';
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  static Future<String> getAIResponse(String userMessage, List<Map<String, String>> conversationHistory) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://yourdomain.com', // Optionnel mais recommandé
          'X-Title': 'SmartFit App', // Optionnel
        },
        body: jsonEncode({
          'model': 'mistralai/mistral-7b-instruct:free', // Modèle gratuit
          'messages': [
            {
              'role': 'system',
              'content': '''Tu es un assistant de réservation pour une salle de sport appelée SmartFit. 
              Ton rôle est d'aider les clients à réserver des séances de sport avec des coachs.

              INFORMATIONS DISPONIBLES :
              - Coachs : Coach Ahmed, Coach Sara, Coach Mohamed
              - Types de séance : Cardio, Musculation, Yoga, CrossFit, Pilates
              - Salles : Salle A, Salle B, Salle C
              - Horaires : Lundi-Vendredi 6h-22h, Samedi 8h-20h, Dimanche 9h-18h

              TON RÔLE :
              1. Aider à réserver des séances
              2. Proposer des coachs selon le type de sport
              3. Indiquer les disponibilités
              4. Donner des informations sur les tarifs
              5. Être friendly et professionnel

              TARIFS :
              - Séance simple : 25€
              - Pack 10 séances : 200€
              - Abonnement mensuel : 80€

              Réponds en français, sois concis et utile. Pose des questions pour préciser la réservation.'''
            },
            ...conversationHistory,
            {'role': 'user', 'content': userMessage},
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Erreur API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // En cas d'erreur, utiliser le chatbot de secours
      return _getFallbackResponse(userMessage);
    }
  }

  static String _getFallbackResponse(String userMessage) {
    String lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('bonjour') || lowerMessage.contains('salut')) {
      return 'Bonjour ! 👋 Je suis votre assistant SmartFit. Je peux vous aider à réserver des séances avec nos coachs.';
    }

    if (lowerMessage.contains('réserver') || lowerMessage.contains('reserver')) {
      return 'Je peux vous aider à réserver une séance ! 🏋️\n\nQuel type d\'entraînement souhaitez-vous ?\n• Cardio\n• Musculation\n• Yoga\n• CrossFit\n• Pilates';
    }

    if (lowerMessage.contains('cardio')) {
      return 'Excellent choix pour le cardio ! ❤️\n\nAvec quel coach préférez-vous travailler ?\n• Coach Ahmed\n• Coach Sara\n• Coach Mohamed';
    }

    if (lowerMessage.contains('musculation')) {
      return 'Parfait pour la musculation ! 💪\n\nQuel coach vous intéresse ?\n• Coach Ahmed (Spécialiste force)\n• Coach Sara (Spécialiste technique)\n• Coach Mohamed (Spécialiste bodybuilding)';
    }

    if (lowerMessage.contains('coach')) {
      return 'Nos coachs sont disponibles ! 🏆\n\nQuand souhaitez-vous réserver ?\nEx: "Demain 10h", "Vendredi 16h"';
    }

    if (lowerMessage.contains('prix') || lowerMessage.contains('tarif')) {
      return 'Nos tarifs :\n• Séance simple: 25€\n• Pack 10 séances: 200€\n• Abonnement mensuel: 80€\n\nSouhaitez-vous réserver une séance ?';
    }

    if (lowerMessage.contains('horaire') || lowerMessage.contains('heure')) {
      return 'Nos horaires :\n• Lundi-Vendredi: 6h-22h\n• Samedi: 8h-20h\n• Dimanche: 9h-18h\n\nQuand souhaitez-vous venir ?';
    }

    return 'Je comprends que vous dites: "$userMessage". 🤔\n\nJe peux vous aider avec les réservations, les coachs, les horaires et les tarifs. Que souhaitez-vous faire ?';
  }
}