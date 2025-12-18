import 'dart:convert';

import 'package:http/http.dart' as http;

class BackendService {
  final String baseUrl;

  BackendService({this.baseUrl = "https://n8n.srv1094917.hstgr.cloud/webhook-test/Oji_Atlas_App"});

  Future<String> sendChat(String message) async {
    final uri = Uri.parse(baseUrl);
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
