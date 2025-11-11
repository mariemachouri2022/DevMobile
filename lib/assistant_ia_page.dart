import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AssistantIAPage extends StatefulWidget {
  const AssistantIAPage({super.key});

  @override
  State<AssistantIAPage> createState() => _AssistantIAPageState();
}

class _AssistantIAPageState extends State<AssistantIAPage> {
  final TextEditingController _controller = TextEditingController();
  String _response = "";
  bool _isLoading = false;

  // ✅ Configuration Azure OpenAI
  final String apiKey = "your_api_key"; // Remplacez par votre clé API Azure OpenAI
  final String endpoint =
       "your_azure_key"; // Remplacez par votre endpoint Azure OpenAI

  Future<void> sendMessageToAI(String userMessage) async {
    setState(() {
      _isLoading = true;
      _response = "";
    });

    try {
      final res = await http.post(
        Uri.parse(endpoint),
        headers: {
          "Content-Type": "application/json",
          "api-key": apiKey,
        },
        body: jsonEncode({
          "messages": [
            {
              "role": "system",
              "content":
              "Tu es un assistant technique pour une salle de sport. Aide à diagnostiquer les pannes des équipements sportifs (tapis de course, vélo, rameur, etc.)."
            },
            {"role": "user", "content": userMessage}
          ],
          "max_tokens": 200,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _response = data["choices"][0]["message"]["content"];
        });
      } else {
        setState(() {
          _response =
          "Erreur ${res.statusCode}: ${res.reasonPhrase ?? 'Réponse invalide.'}\n${res.body}";
        });
      }
    } catch (e) {
      setState(() {
        _response = "Erreur de connexion : $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B008B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B008B),
        title: const Text(
          "🤖 Assistant IA",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Décrivez le problème rencontré...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () {
                if (_controller.text.isNotEmpty) {
                  sendMessageToAI(_controller.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B008B),
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.send),
              label: const Text(
                "Envoyer à l’IA",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (_response.isNotEmpty && !_isLoading)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _response,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
