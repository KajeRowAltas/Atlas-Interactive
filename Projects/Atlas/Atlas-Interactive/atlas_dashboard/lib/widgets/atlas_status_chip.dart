import 'package:flutter/material.dart';

import '../theme/atlas_theme_data.dart';

class AtlasStatusChip extends StatelessWidget {
  const AtlasStatusChip({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.subtle = false,
  });

  final String label;
  final Color? color;
  final IconData? icon;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = color ?? AtlasPalette.yellow;
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: subtle
          ? [
              base.withValues(alpha: 0.2),
              base.withValues(alpha: 0.08),
            ]
          : [
              base.withValues(alpha: 0.95),
              base.withValues(alpha: 0.65),
            ],
    );
    final textColor = subtle ? scheme.onSurface : AtlasPalette.beige;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AtlasRadii.pill),
        border: Border.all(
          color: base.withValues(alpha: subtle ? 0.35 : 0.55),
        ),
        boxShadow: subtle ? null : AtlasShadows.glow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: textColor,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
