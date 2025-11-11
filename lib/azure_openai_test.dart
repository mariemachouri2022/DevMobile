import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiKey = "your_api_key"; // Remplacez par votre clé API Azure OpenAI
const String endpoint = "your_azure_endpoint"; // Remplacez par votre endpoint Azure OpenAI
const String deployment = "gpt-4o";
const String apiVersion = "2024-12-01-preview";

Future<void> sendPrompt(String prompt) async {
  final url = Uri.parse("$endpoint/openai/deployments/$deployment/chat/completions?api-version=$apiVersion");

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "api-key": apiKey,
    },
    body: jsonEncode({
      "messages": [
        {"role": "user", "content": prompt}
      ],
      "max_tokens": 100,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print("✅ Réponse : ${data['choices'][0]['message']['content']}");
  } else {
    print("❌ Erreur ${response.statusCode}: ${response.body}");
  }
}

void main() {
  sendPrompt("Bonjour Azure OpenAI !");
}
