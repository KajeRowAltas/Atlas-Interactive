import 'dart:convert';

import 'package:http/http.dart' as http;

class TradingBotApi {
  TradingBotApi({required this.baseUrl, required this.token});

  final String baseUrl;
  final String token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-Atlas-Token': token,
      };

  Uri _uri(String path, {Map<String, dynamic>? queryParameters}) {
    return Uri.parse(baseUrl).replace(path: path, queryParameters: queryParameters);
  }

  Future<Map<String, dynamic>> status() async {
    final res = await http.get(_uri('/trading/status'), headers: _headers);
    _ensureOk(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getOpenTrades({String? symbol}) async {
    final res = await http.get(
      _uri(
        '/trading/open-trades',
        queryParameters: symbol != null ? {'symbol': symbol} : null,
      ),
      headers: _headers,
    );
    _ensureOk(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getIndicatorSettings() async {
    final res =
        await http.get(_uri('/trading/indicator-settings'), headers: _headers);
    _ensureOk(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> setIndicatorSettings(
      Map<String, dynamic> settings) async {
    final res = await http.post(
      _uri('/trading/indicator-settings'),
      headers: _headers,
      body: jsonEncode(settings),
    );
    _ensureOk(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> start({
    required String symbol,
    required int leverage,
    bool dryRun = true,
    bool enableAnalysis = true,
    double pollIntervalS = 2,
    Map<String, dynamic>? indicatorSettings,
  }) async {
    final payload = <String, dynamic>{
      'bot_id': 'alpha',
      'symbol': symbol,
      'market_type': 'swap',
      'dry_run': dryRun,
      'enable_analysis': enableAnalysis,
      'poll_interval_s': pollIntervalS,
      'leverage': leverage,
    };
    if (indicatorSettings != null) {
      payload['indicator_settings'] = indicatorSettings;
    }

    final res = await http.post(
      _uri('/trading/start'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    _ensureOk(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> stop() async {
    final res = await http.post(
      _uri('/trading/stop'),
      headers: _headers,
      body: jsonEncode({'bot_id': 'alpha'}),
    );
    _ensureOk(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static void _ensureOk(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }
}

