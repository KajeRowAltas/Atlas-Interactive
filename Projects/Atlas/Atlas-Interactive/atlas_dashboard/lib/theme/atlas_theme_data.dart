import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Canonical Atlas palette translated from css/styles.css :root tokens.
class AtlasPalette {
  static const Color yellow = Color(0xFFE6A430); // Mirrors --atlas-yellow in styles.css
  static const Color orange = Color(0xFFC94C1D); // Mirrors --atlas-orange in styles.css
  static const Color red = Color(0xFF9E2B1E); // Mirrors --atlas-red in styles.css
  static const Color deepRed = Color(0xFF6C1C19); // Mirrors --atlas-deep-red in styles.css
  static const Color teal = Color(0xFF1F5F5B); // Mirrors --atlas-teal in styles.css
  static const Color deepTeal = Color(0xFF133735); // Mirrors --atlas-deep-teal in styles.css
  static const Color beige = Color(0xFFF9F4E7); // Mirrors --atlas-beige in styles.css

  // Body gradient anchors from dark.css (body.dark background stops).
  static const Color midnightTeal = Color(0xFF0F2423);
  static const Color obsidianTeal = Color(0xFF132F2D);
  static const Color ember = Color(0xFF2B0F12);
}

/// Border radii defined in css/styles.css root tokens.
class AtlasRadii {
  static const double pill = 999; // --radius-pill
  static const double lg = 34; // --radius-lg
  static const double md = 22; // --radius-md
  static const double sm = 14; // --radius-sm
  static const double pageShell = 48; // page-shell border-radius: 48px 0 0 48px;
  static const double header = 28; // .header-inner border-radius
  static const double card = 28; // .card border-radius
  static const double navItem = 24; // .nav-links a border-radius
}

/// Shadows lifted from :root atlas shadows.
class AtlasShadows {
  static const List<BoxShadow> warm = [
    // --atlas-warm-shadow
    BoxShadow(
      color: Color.fromRGBO(156, 60, 24, 0.28),
      offset: Offset(0, 28),
      blurRadius: 52,
    ),
  ];

  static const List<BoxShadow> soft = [
    // --atlas-soft-shadow
    BoxShadow(
      color: Color.fromRGBO(19, 55, 53, 0.24),
      offset: Offset(0, 18),
      blurRadius: 38,
    ),
  ];

  static const List<BoxShadow> glow = [
    // --atlas-glow
    BoxShadow(
      color: Color.fromRGBO(233, 202, 156, 0.28),
      blurRadius: 0,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: Color.fromRGBO(233, 164, 48, 0.28),
      offset: Offset(0, 18),
      blurRadius: 40,
    ),
  ];
}

/// Gradients and overlays mapped from the reference CSS.
class AtlasGradients {
  const AtlasGradients._();

  // Body background mirrors body background layers (styles.css).
  static const LinearGradient appBackdrop = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AtlasPalette.midnightTeal,
      AtlasPalette.obsidianTeal,
      AtlasPalette.ember,
    ],
  );

  static const LinearGradient appWash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AtlasPalette.yellow,
      AtlasPalette.orange,
      AtlasPalette.red,
    ],
    stops: [0.0, 0.55, 1.0],
  ); // Matches body linear-gradient(120deg, var(--atlas-yellow)...)

  static const LinearGradient sidebar = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(31, 95, 91, 0.95),
      Color.fromRGBO(158, 43, 30, 0.9),
      Color.fromRGBO(201, 76, 29, 0.96),
    ],
  ); // Mirrors .sidebar gradient in styles.css

  static const LinearGradient headerRibbon = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.fromRGBO(31, 95, 91, 0.25),
      Color.fromRGBO(233, 164, 48, 0.45),
      Color.fromRGBO(201, 76, 29, 0.35),
    ],
  ); // Mirrors .header-inner::before

  static const LinearGradient cardHighlight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromRGBO(249, 244, 231, 0.9),
      Color.fromRGBO(233, 164, 48, 0.25),
    ],
  ); // Mirrors .card background mix

  static const LinearGradient pill = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AtlasPalette.yellow, AtlasPalette.orange],
  ); // Mirrors .status-pill / .top-nav__cta
}

/// Typography scale recreated from styles.css.
class AtlasTypography {
  static TextTheme textTheme() {
    final baseSans = GoogleFonts.inter(
      height: 1.6, // body line-height: 1.6
      color: AtlasPalette.deepTeal,
    );
    final serif = GoogleFonts.cormorantGaramond(
      color: AtlasPalette.deepTeal,
      height: 1.2,
      fontWeight: FontWeight.w600,
    );

    return TextTheme(
      displayLarge: serif.copyWith(fontSize: 44, letterSpacing: 5.12), // brand-name letter-spacing 0.32em
      headlineMedium: serif.copyWith(fontSize: 40),
      titleLarge: serif.copyWith(fontSize: 32),
      titleMedium: baseSans.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 3.2, // header-eyebrow letter-spacing 0.2em
        textBaseline: TextBaseline.alphabetic,
      ),
      bodyLarge: baseSans.copyWith(fontSize: 16),
      bodyMedium: baseSans.copyWith(fontSize: 14),
      labelLarge: baseSans.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.92, // status-pill letter-spacing 0.12em
      ),
      labelMedium: baseSans.copyWith(
        fontSize: 12,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static TextStyle eyebrow(Color color) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 3.2, // .header-eyebrow letter-spacing: 0.2em
        color: color,
      );

  static TextStyle serifDisplay(Color color) => GoogleFonts.cormorantGaramond(
        fontSize: 44, // 2.75rem h1
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: color,
      );

  static TextStyle body(Color color) => GoogleFonts.inter(
        fontSize: 14,
        height: 1.6,
        color: color,
      );

  static TextStyle navLabel(bool active) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.32,
        color: active
            ? AtlasPalette.beige
            : AtlasPalette.beige.withValues(alpha: 0.82),
      );
}

/// Provides glass and grain utilities to mirror the CSS blur and SVG noise.
class AtlasSurfaces {
  static Widget glass({
    required Widget child,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(AtlasRadii.header)),
    double opacity = 0.8,
    double blurSigma = 12,
    List<BoxShadow> shadows = AtlasShadows.soft,
    Color tint = const Color.fromRGBO(249, 244, 231, 0.8),
  }) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: opacity),
                  boxShadow: shadows,
                  border: Border.all(
                    color: AtlasPalette.deepTeal.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }

  static Widget grain({double opacity = 0.35}) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GrainPainter(opacity: opacity),
      ),
    );
  }
}

/// Flutter ThemeData aligned to the Atlas site system.
class AtlasTheme {
  static ThemeData light() {
    final textTheme = AtlasTypography.textTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AtlasPalette.teal,
        secondary: AtlasPalette.yellow,
        surface: AtlasPalette.beige,
        tertiary: AtlasPalette.orange,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AtlasPalette.beige.withValues(alpha: 0.9),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AtlasPalette.deepTeal.withValues(alpha: 0.6),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AtlasRadii.md),
          borderSide: BorderSide(
            color: AtlasPalette.teal.withValues(alpha: 0.18),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AtlasRadii.md),
          borderSide: const BorderSide(color: AtlasPalette.orange, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AtlasRadii.md),
          ),
          backgroundColor: AtlasPalette.orange.withValues(alpha: 0.9),
          foregroundColor: AtlasPalette.beige,
          elevation: 0,
          shadowColor: AtlasPalette.orange.withValues(alpha: 0.35),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        selectedIconTheme: const IconThemeData(color: AtlasPalette.yellow),
        unselectedIconTheme: IconThemeData(
          color: AtlasPalette.beige.withValues(alpha: 0.85),
        ),
        selectedLabelTextStyle: textTheme.labelLarge?.copyWith(color: AtlasPalette.yellow),
        unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: AtlasPalette.beige.withValues(alpha: 0.86),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final textTheme = AtlasTypography.textTheme().apply(
      bodyColor: AtlasPalette.beige,
      displayColor: AtlasPalette.beige,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AtlasPalette.teal,
        secondary: AtlasPalette.yellow,
        surface: AtlasPalette.deepTeal,
        tertiary: AtlasPalette.orange,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AtlasPalette.deepTeal.withValues(alpha: 0.85),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AtlasPalette.beige.withValues(alpha: 0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AtlasRadii.md),
          borderSide: BorderSide(
            color: AtlasPalette.beige.withValues(alpha: 0.18),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AtlasRadii.md),
          borderSide: BorderSide(color: AtlasPalette.yellow.withValues(alpha: 0.9), width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AtlasRadii.md),
          ),
          backgroundColor: AtlasPalette.orange.withValues(alpha: 0.85),
          foregroundColor: AtlasPalette.beige,
          elevation: 0,
          shadowColor: AtlasPalette.orange.withValues(alpha: 0.45),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        selectedIconTheme: const IconThemeData(color: AtlasPalette.yellow),
        unselectedIconTheme: IconThemeData(
          color: AtlasPalette.beige.withValues(alpha: 0.8),
        ),
        selectedLabelTextStyle: textTheme.labelLarge?.copyWith(color: AtlasPalette.yellow),
        unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: AtlasPalette.beige.withValues(alpha: 0.86),
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  _GrainPainter({required this.opacity}) {
    // Seeded noise so the texture is stable while matching the SVG fractal noise vibe.
    final rand = Random(7);
    for (int i = 0; i < _density; i++) {
      _points.add(Offset(rand.nextDouble(), rand.nextDouble()));
    }
  }

  final double opacity;
  final List<Offset> _points = [];
  static const int _density = 900;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08 * opacity)
      ..strokeWidth = 0.6;

    for (final point in _points) {
      canvas.drawPoints(
        PointMode.points,
        [Offset(point.dx * size.width, point.dy * size.height)],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}
