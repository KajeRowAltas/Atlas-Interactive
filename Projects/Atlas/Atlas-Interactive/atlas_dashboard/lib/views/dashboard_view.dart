import 'package:flutter/material.dart';

import '../theme/atlas_theme_data.dart';
import '../widgets/atlas_card.dart';
import '../widgets/atlas_status_chip.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardHeader(scheme: scheme, textTheme: textTheme),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final int columns = width > 1440
                  ? 3
                  : width > 980
                      ? 2
                      : 1;
              final cards = _DashboardCardData.demo();
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: width > 1280 ? 1.4 : 1.1,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final data = cards[index];
                  if (data.integrationRows != null) {
                    return _IntegrationCard(
                        data: data, scheme: scheme, textTheme: textTheme);
                  }
                  return AtlasCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: textTheme.titleLarge
                              ?.copyWith(color: scheme.onSurface),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          data.description,
                          style: textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: FilledButton(
                            onPressed: () {},
                            child: Text(data.cta),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.scheme, required this.textTheme});

  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 64,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AtlasGradients
                    .headerRibbon, // Mirrors .header-inner::before from styles.css
              ),
            ),
          ),
          Positioned.fill(child: AtlasSurfaces.grain(opacity: 0.18)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Atlas Command',
                      style: AtlasTypography.eyebrow(scheme.primary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Dashboard',
                      style: textTheme.displayLarge?.copyWith(
                        color: scheme.onSurface,
                        letterSpacing: 0,
                        fontSize: 38,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Monitoring surreal workflows, shared drive signals, and the warm-to-cool palette balance.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.76),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      children: [
                        AtlasStatusChip(label: 'Live'),
                        SizedBox(width: 10),
                        AtlasStatusChip(
                          label: 'Signal clear',
                          color: AtlasPalette.teal,
                          subtle: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromRGBO(249, 244, 231, 0.65),
                      Color.fromRGBO(233, 164, 48, 0.35),
                    ],
                  ),
                  boxShadow: AtlasShadows.glow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/images/Atlas_Logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.auto_awesome,
                      color: scheme.primary,
                      size: 42,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardCardData {
  const _DashboardCardData(
    this.title,
    this.description,
    this.cta, {
    this.integrationRows,
  });

  final String title;
  final String description;
  final String cta;
  final List<_IntegrationRow>? integrationRows;

  static List<_DashboardCardData> demo() {
    return const [
      _DashboardCardData(
        'Conversation Velocity',
        'Track how quickly Oji cycles through Atlas projects. Ideal cadence is 7.3 exchanges per hour.',
        'Open Insight',
      ),
      _DashboardCardData(
        'Context Memory',
        'Review anchors, to-dos, and surreal cues being stored for upcoming sessions.',
        'Review Memory',
      ),
      _DashboardCardData(
        'Integration Health',
        'Live checks across Atlas services.',
        'View Services',
        integrationRows: [
          _IntegrationRow('n8n Webhook', 'Operational', AtlasPalette.teal),
          _IntegrationRow('Trello TODO Sync', 'Planned', AtlasPalette.orange),
          _IntegrationRow('Memory Graph DB', 'Planned', AtlasPalette.yellow),
        ],
      ),
      _DashboardCardData(
        'Warmth Balance',
        'Ensure the 60/40 warm-to-cool palette ratio holds. Adjust gradients to maintain Atlas glow.',
        'Adjust Palette',
      ),
    ];
  }
}

class _IntegrationCard extends StatelessWidget {
  const _IntegrationCard({
    required this.data,
    required this.scheme,
    required this.textTheme,
  });

  final _DashboardCardData data;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 10),
          Text(
            data.description,
            style: textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 14),
          ...data.integrationRows!.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.service,
                      style: textTheme.bodyLarge
                          ?.copyWith(color: scheme.onSurface),
                    ),
                  ),
                  AtlasStatusChip(
                    label: row.status,
                    color: row.color,
                    subtle: row.status.toLowerCase() == 'planned',
                  ),
                ],
              ),
            );
          }),
          const Spacer(),
          Align(
            alignment: Alignment.bottomLeft,
            child: FilledButton(
              onPressed: () {},
              child: Text(data.cta),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntegrationRow {
  const _IntegrationRow(this.service, this.status, this.color);

  final String service;
  final String status;
  final Color color;
}
