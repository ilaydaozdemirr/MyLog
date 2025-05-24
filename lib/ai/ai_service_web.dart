import 'dart:convert';
import 'package:http/http.dart' as http;

class AIServiceWeb {
  static const String apiUrl = 'http://localhost:8000/analyze';

  static Future<String> analyzeText(String text) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': text}),
    );

    print("✅ HTTP status: ${response.statusCode}");

    if (response.statusCode == 200) {
      // 🔄 UTF-8 fix burada
      final decodedBody = utf8.decode(response.bodyBytes);
      print("✅ Clean body: $decodedBody");

      final data = jsonDecode(decodedBody);
      return data['response'] ?? 'No analysis result.';
    } else {
      throw Exception("AI Error: ${response.body}");
    }
  }
}
