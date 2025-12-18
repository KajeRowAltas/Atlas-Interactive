import 'package:flutter/material.dart';

import '../theme/atlas_theme_data.dart';

class AtlasCard extends StatelessWidget {
  const AtlasCard({
    super.key,
    this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget? child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AtlasPalette.beige.withValues(alpha: 0.85), // Mirrors .card background base
        borderRadius: BorderRadius.circular(AtlasRadii.card),
        border: Border.all(
          color: AtlasPalette.deepTeal.withValues(alpha: 0.08),
        ),
        boxShadow: const [
          // Mirrors .card shadow from styles.css
          BoxShadow(
            color: Color.fromRGBO(233, 164, 48, 0.25),
            blurRadius: 42,
            offset: Offset(0, 24),
          ),
          BoxShadow(
            color: Color.fromRGBO(31, 95, 91, 0.08),
            blurRadius: 8,
            offset: Offset(0, 0),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AtlasGradients.cardHighlight,
              ),
            ),
          ),
          Positioned.fill(child: AtlasSurfaces.grain(opacity: 0.22)),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}
