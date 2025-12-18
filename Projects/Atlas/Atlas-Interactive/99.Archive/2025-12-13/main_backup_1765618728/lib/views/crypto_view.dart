import 'package:flutter/material.dart';

import '../theme/atlas_theme_data.dart';
import '../widgets/atlas_card.dart';
import '../widgets/atlas_status_chip.dart';

class CryptoView extends StatelessWidget {
  const CryptoView({super.key});

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
                  style:
                      textTheme.titleMedium?.copyWith(color: scheme.onSurface)),
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
                  style:
                      textTheme.bodyMedium?.copyWith(color: scheme.onSurface)),
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
