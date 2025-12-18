import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

String _normalizeOrCreateId(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return const Uuid().v4();
  }
  return trimmed;
}

class ChatResponse {
  final bool ok;
  final int statusCode;
  final String message;
  final String? errorBody;

  const ChatResponse({
    required this.ok,
    required this.statusCode,
    required this.message,
    this.errorBody,
  });
}

class BackendService {
  static const String _webhookUrl =
      "https://n8n.srv1094917.hstgr.cloud/webhook-test/Oji_Atlas_App";
  final String sessionId;
  int _turnId = 0;

  BackendService({String? sessionId})
      : sessionId = _normalizeOrCreateId(sessionId);

  Future<ChatResponse> sendChat(String message) async {
    final traceId = const Uuid().v4();
    _turnId += 1;
    final uri = Uri.parse(_webhookUrl);
    final resp = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "message": message,
        "timestamp": DateTime.now().toUtc().toIso8601String(),
        "session_id": sessionId,
        "sessionId": sessionId, // Back-compat for older n8n nodes/prompts.
        "trace_id": traceId,
        "traceId": traceId, // Back-compat for camelCase nodes.
        "turn_id": _turnId,
        "turnId": _turnId, // Back-compat for camelCase nodes.
      }),
    );
    if (resp.statusCode != 200) {
      return ChatResponse(
        ok: false,
        statusCode: resp.statusCode,
        message: "Backend error: ${resp.statusCode}",
        errorBody: resp.body,
      );
    }

    final decodedBody = jsonDecode(resp.body);

    Map<String, dynamic>? data;
    if (decodedBody is List && decodedBody.isNotEmpty) {
      data = decodedBody.first as Map<String, dynamic>;
    } else if (decodedBody is Map<String, dynamic>) {
      data = decodedBody;
    }

    if (data == null) {
      return const ChatResponse(
        ok: false,
        statusCode: 200, // Or another appropriate status code
        message: "Unexpected response format from backend.",
      );
    }

    final reply = data["output"] as String? ?? "No response";
    return ChatResponse(
      ok: true,
      statusCode: resp.statusCode,
      message: reply,
    );
  }
}
