import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class TradingBotWs {
  TradingBotWs({required this.baseUrl, required this.token});

  final String baseUrl;
  final String token;

  WebSocketChannel connect() {
    final uri = Uri.parse(baseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final wsUri = uri.replace(
      scheme: scheme,
      path: '/trading/ws',
      queryParameters: {
        ...uri.queryParameters,
        'token': token,
      },
    );
    return WebSocketChannel.connect(wsUri);
  }

  static Map<String, dynamic> decodeEvent(dynamic message) {
    if (message is String) {
      return jsonDecode(message) as Map<String, dynamic>;
    }
    return const <String, dynamic>{'type': 'unknown'};
  }
}

