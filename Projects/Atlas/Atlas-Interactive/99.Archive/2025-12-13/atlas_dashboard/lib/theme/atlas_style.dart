import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AtlasColors {
  static const Color yellow = Color(0xFFE6A430);
  static const Color orange = Color(0xFFC94C1D);
  static const Color teal = Color(0xFF1F5F5B);
  static const Color deepTeal = Color(0xFF133735);
  static const Color deepTealAlt = Color(0xFF0F2423);
  static const Color beige = Color(0xFFF9F4E7);
  static const Color red = Color(0xFF9E2B1E);

  static const Color bgStep1 = Color(0xFF0F2423);
  static const Color bgStep2 = Color(0xFF132F2D);
  static const Color bgStep3 = Color(0xFF2B0F12);
}

class AtlasText {
  static TextTheme textTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.cormorantGaramond(
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
      displayMedium: GoogleFonts.cormorantGaramond(
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
      titleMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      bodyLarge: GoogleFonts.inter(),
      bodyMedium: GoogleFonts.inter(),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600),
    );
  }

  static TextStyle headingStyle({double size = 26, Color color = AtlasColors.beige}) {
    return GoogleFonts.cormorantGaramond(
      fontSize: size,
      fontWeight: FontWeight.w600,
      letterSpacing: 2,
      color: color,
    );
  }

  static TextStyle bodyStyle({double size = 14, Color color = AtlasColors.beige}) {
    return GoogleFonts.inter(
      fontSize: size,
      color: color,
      height: 1.5,
    );
  }
}
