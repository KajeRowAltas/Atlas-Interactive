import 'package:flutter/material.dart';

import '../theme/atlas_theme_data.dart';
import '../widgets/atlas_card.dart';
import '../widgets/atlas_status_chip.dart';

class GoogleWorkspaceView extends StatelessWidget {
  const GoogleWorkspaceView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final services = _workspaceServices();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtlasCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google Workspace',
                        style: textTheme.displayLarge
                            ?.copyWith(color: scheme.onSurface, fontSize: 34),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bridge Atlas and Google services. Human and AI co-working surface with reserved space for automation.',
                        style: textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.74)),
                      ),
                      const SizedBox(height: 12),
                      const Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          AtlasStatusChip(
                              label: 'AI Ready',
                              icon: Icons.auto_awesome,
                              color: AtlasPalette.yellow),
                          AtlasStatusChip(
                              label: 'Drive',
                              color: AtlasPalette.teal,
                              icon: Icons.folder),
                          AtlasStatusChip(
                              label: 'Mail',
                              color: AtlasPalette.orange,
                              icon: Icons.mail),
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
                        Color.fromRGBO(233, 164, 48, 0.32),
                        Color.fromRGBO(31, 95, 91, 0.35),
                      ],
                    ),
                  ),
                  child: Icon(Icons.apps, color: scheme.primary, size: 32),
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
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _WorkspaceCard(data: service);
                },
              );
            },
          ),
          const SizedBox(height: 16),
          AtlasCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Suggestions',
                    style: textTheme.titleLarge
                        ?.copyWith(color: scheme.onSurface)),
                const SizedBox(height: 8),
                Text(
                  'Reserve this zone for agent-driven suggestions. Draft emails, summarize Drive folders, or prepare calendar recaps.',
                  style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.72)),
                ),
                const SizedBox(height: 14),
                const Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AtlasStatusChip(
                        label: 'Summarize Inbox',
                        icon: Icons.summarize,
                        color: AtlasPalette.teal),
                    AtlasStatusChip(
                        label: 'Draft Doc',
                        icon: Icons.description,
                        color: AtlasPalette.yellow),
                    AtlasStatusChip(
                        label: 'Schedule',
                        icon: Icons.event_available,
                        color: AtlasPalette.orange),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard({required this.data});

  final _WorkspaceService data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return AtlasCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: data.color.withValues(alpha: 0.32)),
                ),
                child: Icon(data.icon, color: data.color),
              ),
              const SizedBox(width: 10),
              Text(data.name,
                  style:
                      textTheme.titleMedium?.copyWith(color: scheme.onSurface)),
              const Spacer(),
              AtlasStatusChip(
                label: data.status,
                color: data.color,
                icon: data.statusIcon,
                subtle: data.status.toLowerCase() != 'connected',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.description,
            style: textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.72)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: scheme.primary, size: 16),
                    const SizedBox(width: 8),
                    Text('AI ready slot',
                        style: textTheme.labelMedium
                            ?.copyWith(color: scheme.onSurface)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  data.aiHook,
                  style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Text('Status: ',
                  style: textTheme.labelMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7))),
              Text(data.connectionDetail,
                  style:
                      textTheme.bodyMedium?.copyWith(color: scheme.onSurface)),
              const Spacer(),
              Icon(Icons.chevron_right,
                  color: scheme.onSurface.withValues(alpha: 0.4)),
            ],
          )
        ],
      ),
    );
  }
}

class _WorkspaceService {
  const _WorkspaceService({
    required this.name,
    required this.status,
    required this.statusIcon,
    required this.description,
    required this.aiHook,
    required this.connectionDetail,
    required this.icon,
    required this.color,
  });

  final String name;
  final String status;
  final IconData statusIcon;
  final String description;
  final String aiHook;
  final String connectionDetail;
  final IconData icon;
  final Color color;
}

List<_WorkspaceService> _workspaceServices() {
  return const [
    _WorkspaceService(
      name: 'Drive',
      status: 'Connected',
      statusIcon: Icons.cloud_done,
      description: 'Atlas folders mirrored and ready for summaries.',
      aiHook: 'Summaries and uploads can land here.',
      connectionDetail: 'Indexed weekly · latest sync today',
      icon: Icons.folder,
      color: AtlasPalette.teal,
    ),
    _WorkspaceService(
      name: 'Gmail',
      status: 'Not Connected',
      statusIcon: Icons.mail_outline,
      description: 'Authorize Atlas to triage and summarize inbox threads.',
      aiHook: 'Reserve quick triage + draft replies.',
      connectionDetail: 'Awaiting OAuth',
      icon: Icons.mail,
      color: AtlasPalette.orange,
    ),
    _WorkspaceService(
      name: 'Calendar',
      status: 'Syncing Soon',
      statusIcon: Icons.event,
      description: 'Calendar hooks for meeting prep and recaps.',
      aiHook: 'Oji will propose agendas and recaps.',
      connectionDetail: 'Scheduler placeholder',
      icon: Icons.calendar_today,
      color: AtlasPalette.yellow,
    ),
    _WorkspaceService(
      name: 'Docs',
      status: 'Connected',
      statusIcon: Icons.description,
      description: 'Docs bridge to host AI drafts and memory artifacts.',
      aiHook: 'Drafts can live-sync into a shared doc.',
      connectionDetail: 'Connected via Atlas service account',
      icon: Icons.description_outlined,
      color: AtlasPalette.teal,
    ),
    _WorkspaceService(
      name: 'Sheets',
      status: 'Planning',
      statusIcon: Icons.grid_on,
      description: 'Sheet sync reserved for metrics and automations.',
      aiHook: 'Oji can push tabular summaries here.',
      connectionDetail: 'Define schema soon',
      icon: Icons.grid_view,
      color: AtlasPalette.orange,
    ),
  ];
}
