import 'dart:convert';

import 'package:http/http.dart' as http;

class BackendService {
  final String baseUrl;

  BackendService({this.baseUrl = "http://localhost:8000"});

  Future<String> sendChat(String message) async {
    final uri = Uri.parse("$baseUrl/chat/");
    final resp = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"message": message}),
    );
    if (resp.statusCode != 200) {
      return "Backend error: ${resp.statusCode}";
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data["reply"] as String? ?? "No response";
  }
}
