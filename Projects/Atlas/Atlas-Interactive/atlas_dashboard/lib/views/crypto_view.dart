import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../theme/atlas_theme_data.dart';
import '../services/trading_bot_api.dart';
import '../services/trading_bot_ws.dart';
import '../widgets/atlas_card.dart';
import '../widgets/atlas_status_chip.dart';

class CryptoView extends StatefulWidget {
  const CryptoView({super.key});

  @override
  State<CryptoView> createState() => _CryptoViewState();
}

class _CryptoViewState extends State<CryptoView> {
  final _baseUrlController =
      TextEditingController(text: 'http://127.0.0.1:8000');
  final _tokenController = TextEditingController();
  final _symbolController = TextEditingController(text: 'PEPE/USDT:USDT');
  final _leverageController = TextEditingController(text: '50');

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSub;

  Map<String, dynamic>? _status;
  Map<String, dynamic>? _lastTick;
  Map<String, dynamic>? _lastAnalysis;
  String? _error;
  bool _connecting = false;
  Map<String, dynamic>? _indicatorSettings;
  List<dynamic>? _openTrades;

  @override
  void initState() {
    super.initState();
    _fetchIndicatorSettings();
    _fetchOpenTrades();
  }

  @override
  void dispose() {
    _channelSub?.cancel();
    _channel?.sink.close();
    _baseUrlController.dispose();
    _tokenController.dispose();
    _symbolController.dispose();
    _leverageController.dispose();
    super.dispose();
  }

  TradingBotApi _api() {
    return TradingBotApi(
      baseUrl: _baseUrlController.text.trim(),
      token: _tokenController.text.trim(),
    );
  }

  TradingBotWs _ws() {
    return TradingBotWs(
      baseUrl: _baseUrlController.text.trim(),
      token: _tokenController.text.trim(),
    );
  }

  Future<void> _fetchIndicatorSettings() async {
    try {
      final settings = await _api().getIndicatorSettings();
      setState(() {
        _indicatorSettings = settings;
      });
    } catch (e, s) {
      log('Failed to fetch indicator settings', error: e, stackTrace: s);
      setState(() => _error = e.toString());
    }
  }

  Future<void> _fetchOpenTrades() async {
    try {
      final trades = await _api().getOpenTrades();
      setState(() {
        _openTrades = trades;
      });
    } catch (e, s) {
      log('Failed to fetch open trades', error: e, stackTrace: s);
      setState(() => _error = e.toString());
    }
  }

  Future<void> _connectWs() async {
    setState(() {
      _error = null;
      _connecting = true;
    });

    await _channelSub?.cancel();
    await _channel?.sink.close();

    try {
      final channel = _ws().connect();
      final sub = channel.stream.listen(
        (message) {
          final event = TradingBotWs.decodeEvent(message);
          final type = event['type'];
          setState(() {
            if (type == 'tick') _lastTick = event;
            if (type == 'analysis') _lastAnalysis = event;
            if (type == 'heartbeat')
              _status = event['status'] as Map<String, dynamic>?;
          });
        },
        onError: (e, s) {
          log('WebSocket error', error: e, stackTrace: s);
          setState(() => _error = e.toString());
        },
        onDone: () {
          log('WebSocket connection closed');
          setState(() => _channel = null);
        },
        cancelOnError: false,
      );

      setState(() {
        _channel = channel;
        _channelSub = sub;
      });
    } catch (e, s) {
      log('Failed to connect to WebSocket', error: e, stackTrace: s);
      setState(() => _error = e.toString());
    } finally {
      setState(() => _connecting = false);
    }
  }

  Future<void> _refreshStatus() async {
    try {
      final status = await _api().status();
      setState(() => _status = status);
    } catch (e, s) {
      log('Failed to refresh status', error: e, stackTrace: s);
      setState(() => _error = e.toString());
    }
  }

  Future<void> _startBot() async {
    try {
      final leverage = int.tryParse(_leverageController.text.trim()) ?? 50;
      final status = await _api().start(
        symbol: _symbolController.text.trim(),
        leverage: leverage,
        dryRun: true,
        enableAnalysis: true,
        indicatorSettings: _indicatorSettings,
      );
      log('Bot started: $status');
      setState(() => _status = status);
      await _connectWs();
    } catch (e, s) {
      log('Failed to start bot', error: e, stackTrace: s);
      setState(() => _error = e.toString());
    }
  }

  Future<void> _stopBot() async {
    try {
      final status = await _api().stop();
      setState(() => _status = status);
    } catch (e, s) {
      log('Failed to stop bot', error: e, stackTrace: s);
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final markets = _marketCards();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          AtlasCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Crypto',
                          style: textTheme.displayLarge?.copyWith(
                              color: scheme.onSurface, fontSize: 34)),
                      const SizedBox(height: 8),
                      Text(
                        'Atlas market surface for upcoming feeds. Styled for charts, tickers, and AI overlays.',
                        style: textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(height: 12),
                      const Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          AtlasStatusChip(label: 'Warm'),
                          AtlasStatusChip(
                              label: 'Crypto Ready',
                              color: AtlasPalette.teal,
                              icon: Icons.currency_bitcoin),
                          AtlasStatusChip(
                              label: 'AI link',
                              color: AtlasPalette.yellow,
                              icon: Icons.auto_awesome),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Trading Bot (Bitget Futures)',
                          style: textTheme.titleLarge
                              ?.copyWith(color: scheme.onSurface)),
                      const SizedBox(height: 10),
                      _BotControls(
                        baseUrlController: _baseUrlController,
                        tokenController: _tokenController,
                        symbolController: _symbolController,
                        leverageController: _leverageController,
                        onStart: _startBot,
                        onStop: _stopBot,
                        onStatus: _refreshStatus,
                        connecting: _connecting,
                        status: _status,
                        lastTick: _lastTick,
                        lastAnalysis: _lastAnalysis,
                        error: _error,
                      ),
                      const SizedBox(height: 16),
                      if (_indicatorSettings != null)
                        _IndicatorSettings(
                          settings: _indicatorSettings!,
                          onChanged: (newSettings) {
                            setState(() {
                              _indicatorSettings = newSettings;
                            });
                          },
                          onSave: () async {
                            try {
                              await _api()
                                  .setIndicatorSettings(_indicatorSettings!);
                            } catch (e, s) {
                              log('Failed to save indicator settings',
                                  error: e, stackTrace: s);
                              setState(() => _error = e.toString());
                            }
                          },
                        ),
                      const SizedBox(height: 16),
                      _OpenTradesDisplay(
                        openTrades: _openTrades,
                        onRefresh: _fetchOpenTrades,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: scheme.outline.withValues(alpha: 0.12)),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromRGBO(31, 95, 91, 0.45),
                        Color.fromRGBO(233, 164, 48, 0.25),
                      ],
                    ),
                  ),
                  child:
                      Icon(Icons.show_chart, color: scheme.primary, size: 32),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 1400
                  ? 3
                  : constraints.maxWidth > 980
                      ? 2
                      : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: markets.length,
                itemBuilder: (context, index) {
                  final market = markets[index];
                  return _MarketCard(data: market);
                },
              );
            },
          ),
          const SizedBox(height: 16),
          AtlasCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upcoming Feeds',
                    style: textTheme.titleLarge
                        ?.copyWith(color: scheme.onSurface)),
                const SizedBox(height: 8),
                Text(
                  'TradingView or WebSocket feeds will land here. Keep the container ready for charts without losing Atlas warmth.',
                  style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 14),
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: scheme.outline.withValues(alpha: 0.12)),
                  ),
                  child: const Center(
                    child: Text('Live feed placeholder'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BotControls extends StatelessWidget {
  const _BotControls({
    required this.baseUrlController,
    required this.tokenController,
    required this.symbolController,
    required this.leverageController,
    required this.onStart,
    required this.onStop,
    required this.onStatus,
    required this.connecting,
    required this.status,
    required this.lastTick,
    required this.lastAnalysis,
    required this.error,
  });

  final TextEditingController baseUrlController;
  final TextEditingController tokenController;
  final TextEditingController symbolController;
  final TextEditingController leverageController;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onStatus;
  final bool connecting;
  final Map<String, dynamic>? status;
  final Map<String, dynamic>? lastTick;
  final Map<String, dynamic>? lastAnalysis;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    String statusText() {
      if (status == null) return 'No status';
      final state = status!['state'];
      final dryRun = status!['dry_run'];
      final symbol = status!['symbol'];
      final lev = status!['leverage'];
      return 'state=$state | dry_run=$dryRun | $symbol | lev=$lev';
    }

    String tickText() {
      if (lastTick == null) return '—';
      return '${lastTick!['symbol']} last=${lastTick!['last_price']}';
    }

    String analysisText() {
      if (lastAnalysis == null) return '—';
      final tfs = lastAnalysis!['timeframes'] as Map<String, dynamic>?;
      final one = tfs?['1m'] as Map<String, dynamic>?;
      final rsi = one?['rsi'];
      return '1m rsi=$rsi';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                controller: baseUrlController,
                decoration: const InputDecoration(
                  labelText: 'Backend URL',
                  hintText: 'http://127.0.0.1:8000',
                ),
              ),
            ),
            SizedBox(
              width: 320,
              child: TextField(
                controller: tokenController,
                decoration: const InputDecoration(
                  labelText: 'ATLAS_TRADING_TOKEN',
                  hintText: 'Paste token from backend/.env',
                ),
              ),
            ),
            SizedBox(
              width: 220,
              child: TextField(
                controller: symbolController,
                decoration: const InputDecoration(
                  labelText: 'Symbol',
                  hintText: 'PEPE/USDT:USDT',
                ),
              ),
            ),
            SizedBox(
              width: 140,
              child: TextField(
                controller: leverageController,
                decoration: const InputDecoration(
                  labelText: 'Leverage',
                  hintText: '50',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: connecting ? null : onStart,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start (dry-run)'),
            ),
            OutlinedButton.icon(
              onPressed: onStop,
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
            ),
            OutlinedButton.icon(
              onPressed: onStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('Status'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bot', style: textTheme.titleSmall),
              const SizedBox(height: 6),
              Text(statusText(),
                  style: textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.8))),
              const SizedBox(height: 8),
              Text('Tick: ${tickText()}',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.8))),
              Text('Analysis: ${analysisText()}',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.8))),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error!,
                  style:
                      textTheme.bodyMedium?.copyWith(color: AtlasPalette.red),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _IndicatorSettings extends StatelessWidget {
  const _IndicatorSettings({
    required this.settings,
    required this.onChanged,
    required this.onSave,
  });

  final Map<String, dynamic> settings;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Indicator Settings', style: textTheme.titleLarge),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildRsiSettings(),
            _buildBBandsSettings(),
            _buildMarketStructureSettings(),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onSave,
          icon: const Icon(Icons.save),
          label: const Text('Save Settings'),
        ),
      ],
    );
  }

  Widget _buildRsiSettings() {
    final rsi = settings['rsi'] as Map<String, dynamic>;
    return _SettingCard(
      title: 'RSI',
      child: Column(
        children: [
          _SettingField(
            label: 'Period',
            value: rsi['period'].toString(),
            onChanged: (value) {
              final newSettings =
                  json.decode(json.encode(settings)) as Map<String, dynamic>;
              newSettings['rsi']['period'] = int.tryParse(value) ?? 14;
              onChanged(newSettings);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBBandsSettings() {
    final bbands = settings['bbands'] as Map<String, dynamic>;
    return _SettingCard(
      title: 'Bollinger Bands',
      child: Column(
        children: [
          _SettingField(
            label: 'Period',
            value: bbands['period'].toString(),
            onChanged: (value) {
              final newSettings =
                  json.decode(json.encode(settings)) as Map<String, dynamic>;
              newSettings['bbands']['period'] = int.tryParse(value) ?? 20;
              onChanged(newSettings);
            },
          ),
          const SizedBox(height: 8),
          _SettingField(
            label: 'Std Dev',
            value: bbands['std_dev'].toString(),
            onChanged: (value) {
              final newSettings =
                  json.decode(json.encode(settings)) as Map<String, dynamic>;
              newSettings['bbands']['std_dev'] =
                  double.tryParse(value) ?? 2.0;
              onChanged(newSettings);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMarketStructureSettings() {
    final marketStructure =
        settings['market_structure'] as Map<String, dynamic>;
    return _SettingCard(
      title: 'Market Structure',
      child: Column(
        children: [
          _SettingField(
            label: 'Swing Points',
            value: marketStructure['swing_points'].toString(),
            onChanged: (value) {
              final newSettings =
                  json.decode(json.encode(settings)) as Map<String, dynamic>;
              newSettings['market_structure']['swing_points'] =
                  int.tryParse(value) ?? 10;
              onChanged(newSettings);
            },
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleSmall),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _SettingField extends StatelessWidget {
  const _SettingField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
      ),
      keyboardType: TextInputType.number,
    );
  }
}

class _MarketCardData {
  const _MarketCardData(this.pair, this.change, this.status, this.color);
  final String pair;
  final String change;
  final String status;
  final Color color;
}

class _MarketCard extends StatelessWidget {
  const _MarketCard({required this.data});

  final _MarketCardData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final bool positive = data.change.startsWith('+');

    return AtlasCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: data.color.withValues(alpha: 0.35)),
                ),
                child:
                    Icon(Icons.currency_bitcoin, color: data.color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(data.pair,
                  style: textTheme.titleMedium
                      ?.copyWith(color: scheme.onSurface)),
              const Spacer(),
              AtlasStatusChip(
                  label: data.status, color: data.color, subtle: true),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data.change,
            style: textTheme.displayLarge?.copyWith(
              color: positive ? data.color : AtlasPalette.red,
              fontSize: 36,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '24h change with Atlas glass overlay. Ready for ticker embeds.',
            style: textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.7)),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.timeline, color: scheme.primary),
              const SizedBox(width: 8),
              Text('Stable connectivity',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurface)),
            ],
          )
        ],
      ),
    );
  }
}

List<_MarketCardData> _marketCards() {
  return const [
    _MarketCardData('BTC / USD', '+2.4%', 'Tracking', AtlasPalette.teal),
    _MarketCardData('ETH / USD', '+1.1%', 'Tracking', AtlasPalette.yellow),
    _MarketCardData('SOL / USD', '-0.8%', 'Cooling', AtlasPalette.orange),
    _MarketCardData('ATOM / USD', '+0.4%', 'Research', AtlasPalette.teal),
    _MarketCardData('AURORA / USD', '+3.1%', 'Watch', AtlasPalette.yellow),
    _MarketCardData('INDEX / USD', '+0.2%', 'Watch', AtlasPalette.orange),
  ];
}
