// ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _baseUrl =
      'http://10.0.2.2:8000'; // Android Emulator için
  static const String _endpoint = '/analyze';

  static Future<String> analyzeText(String prompt) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$_endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes))['response'];
    } else {
      throw Exception('AI analysis failed: ${response.body}');
    }
  }
}
