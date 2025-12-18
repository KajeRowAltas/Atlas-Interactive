import 'package:flutter/material.dart';

import '../theme/atlas_theme_data.dart';

class AtlasCard extends StatelessWidget {
  const AtlasCard({
    super.key,
    this.child,
    this.padding = const EdgeInsets.all(20),
    this.background,
  });

  final Widget? child;
  final EdgeInsets padding;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseDecoration = AtlasSurfaces.card(isDark);
    final cardGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(31, 95, 91, 0.18),
              Color.fromRGBO(233, 164, 48, 0.08),
            ],
          )
        : AtlasGradients.cardHighlight;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: baseDecoration.copyWith(
        color: background ?? baseDecoration.color,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: cardGradient,
              ),
            ),
          ),
          Positioned.fill(
              child: AtlasSurfaces.grain(opacity: isDark ? 0.16 : 0.22)),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}
