import 'package:flutter/material.dart';

import '../theme/atlas_theme_data.dart';
import '../widgets/atlas_card.dart';
import '../widgets/terminal_panel.dart';

class TerminalView extends StatelessWidget {
  const TerminalView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AtlasCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AtlasGradients.sidebar,
                  borderRadius: BorderRadius.circular(AtlasRadii.md),
                  boxShadow: AtlasShadows.glow,
                ),
                child: const Icon(Icons.terminal,
                    color: AtlasPalette.beige, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Terminal',
                      style: textTheme.titleLarge
                          ?.copyWith(color: scheme.onSurface)),
                  Text(
                    'Live logs and future n8n output. Styled with Atlas shell chrome.',
                    style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.72)),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Expanded(child: TerminalPanel()),
      ],
    );
  }
}
