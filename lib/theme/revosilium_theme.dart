import 'package:flutter/material.dart';

/// Design System de REVOSILIUM — v2.0 Néomorphique + Glassmorphisme
class R {
  R._();

  // ═══════════════════════════════════════
  // PALETTE PROFONDE
  // ═══════════════════════════════════════
  static const Color bg      = Color(0xFF020202);
  static const Color bgAlt   = Color(0xFF060606);
  static const Color srf     = Color(0xFF0C0C0C);
  static const Color srfAlt  = Color(0xFF111111);
  static const Color pri     = Color(0xFF00FFAA);
  static const Color priD    = Color(0xFF00CC88);
  static const Color priL    = Color(0xFF66FFCC);
  static const Color priA    = Color(0xFF009966);
  static const Color err     = Color(0xFFFF3366);
  static const Color warn    = Color(0xFFFFAA00);
  static const Color txt     = Color(0xFFE8E8E8);
  static const Color txt2    = Color(0xFF6A6A6A);
  static const Color txt3    = Color(0xFF3A3A3A);
  static const Color accent  = Color(0xFF7000FF);
  static const Color ghost   = Color(0xFF00FF88);
  static const Color ghostD  = Color(0xFF00AA55);
  static const Color amber   = Color(0xFFFFD700);

  // ═══════════════════════════════════════
  // GRADIENTS AVANCÉS
  // ═══════════════════════════════════════
  static const LinearGradient gradientGhost = LinearGradient(
    colors: [ghost, Color(0xFF00FFAA), ghostD],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [pri, Color(0xFF00EECC), priD],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientAccent = LinearGradient(
    colors: [accent, Color(0xFFAA00FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientBg = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF020202), Color(0xFF061510), Color(0xFF020812), Color(0xFF020202)],
  );

  static LinearGradient gradientCard(Color c) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      c.withOpacity(0.08),
      c.withOpacity(0.03),
      c.withOpacity(0.06),
    ],
  );

  // ═══════════════════════════════════════
  // OMBRES NÉOMORPHIQUES
  // ═══════════════════════════════════════
  static List<BoxShadow> shadowOuter({double blur = 20, double opacity = 0.12}) => [
    BoxShadow(
      color: Colors.black.withOpacity(opacity * 1.5),
      blurRadius: blur,
      offset: Offset(blur * 0.3, blur * 0.3),
    ),
    BoxShadow(
      color: Colors.white.withOpacity(opacity * 0.15),
      blurRadius: blur * 0.5,
      offset: Offset(-blur * 0.1, -blur * 0.1),
    ),
  ];

  static List<BoxShadow> shadowInner({double blur = 10, double opacity = 0.2}) => [
    BoxShadow(
      color: Colors.black.withOpacity(opacity),
      blurRadius: blur * 0.5,
      offset: Offset(-blur * 0.05, -blur * 0.05),
    ),
    BoxShadow(
      color: Colors.white.withOpacity(opacity * 0.3),
      blurRadius: blur,
      offset: Offset(blur * 0.1, blur * 0.1),
    ),
  ];

  static List<BoxShadow> shadowGlow({double blur = 25, double opacity = 0.2}) => [
    BoxShadow(
      color: pri.withOpacity(opacity),
      blurRadius: blur,
      spreadRadius: blur * 0.08,
    ),
  ];

  static List<BoxShadow> shadowElevated = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 30,
      offset: const Offset(0, 15),
    ),
    BoxShadow(
      color: pri.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, -2),
    ),
  ];

  // ═══════════════════════════════════════
  // DÉCORATIONS
  // ═══════════════════════════════════════
  static BoxDecoration get cardNeo => BoxDecoration(
    color: srfAlt,
    borderRadius: BorderRadius.circular(20),
    boxShadow: shadowOuter(blur: 15, opacity: 0.1),
    border: Border.all(color: Colors.white.withOpacity(0.03)),
  );

  static BoxDecoration cardGlow({Color c = pri, double a = 0.08}) => BoxDecoration(
    gradient: gradientCard(c),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: c.withOpacity(a + 0.05)),
    boxShadow: [
      BoxShadow(color: c.withOpacity(a), blurRadius: 20, spreadRadius: 2),
    ],
  );

  static BoxDecoration get glassPanel => BoxDecoration(
    color: Colors.white.withOpacity(0.02),
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: Colors.white.withOpacity(0.06)),
  );

  static BoxDecoration get glowCircle => BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: pri.withOpacity(0.4), width: 1.5),
    boxShadow: shadowGlow(blur: 30, opacity: 0.25),
  );

  static BoxDecoration inputDecoration({bool focused = false}) => BoxDecoration(
    color: srfAlt,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: focused ? pri.withOpacity(0.3) : Colors.white.withOpacity(0.04),
      width: focused ? 1.2 : 0.8,
    ),
    boxShadow: focused
        ? shadowGlow(blur: 12, opacity: 0.1)
        : shadowInner(blur: 6, opacity: 0.15),
  );

  // ═══════════════════════════════════════
  // TYPOGRAPHIE
  // ═══════════════════════════════════════
  static TextStyle get hero => const TextStyle(
    color: pri, fontSize: 28, fontWeight: FontWeight.w200, letterSpacing: 16, height: 1.1,
  );
  static TextStyle get h1 => const TextStyle(
    color: pri, fontSize: 20, fontWeight: FontWeight.w300, letterSpacing: 10,
  );
  static TextStyle get h2 => const TextStyle(
    color: pri, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 4,
  );
  static TextStyle get body => const TextStyle(
    color: txt, fontSize: 14, height: 1.5, fontWeight: FontWeight.w400,
  );
  static TextStyle get bodySmall => const TextStyle(
    color: txt2, fontSize: 12, height: 1.4,
  );
  static TextStyle get caption => const TextStyle(
    color: txt2, fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.w500,
  );
  static TextStyle get monoLg => const TextStyle(
    color: pri, fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 2,
  );
  static TextStyle get monoMd => const TextStyle(
    color: pri, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 1,
  );
  static TextStyle get monoSm => const TextStyle(
    color: txt2, fontSize: 11, fontWeight: FontWeight.w400, letterSpacing: 1,
  );
  static TextStyle get btn => const TextStyle(
    color: Color(0xFF0A0A0A), fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 3,
  );
  static TextStyle get badge => const TextStyle(
    color: pri, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2,
  );

  // ═══════════════════════════════════════
  // DIMENSIONS
  // ═══════════════════════════════════════
  static const double rXs = 8.0;
  static const double rSm = 12.0;
  static const double rMd = 16.0;
  static const double rLg = 20.0;
  static const double rXl = 24.0;
  static const double r2xl = 32.0;
  static const double rFull = 999.0;

  static const double pad = 20.0;
  static const double iconSize = 20.0;
  static const double iconSm = 16.0;
  static const double iconLg = 28.0;

  // ═══════════════════════════════════════
  // ANIMATIONS
  // ═══════════════════════════════════════
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMed = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 700);
  static const Duration animGlacial = Duration(milliseconds: 1500);

  static const Curve curveSpring = Curves.easeOutBack;
  static const Curve curveSmooth = Curves.easeOutCubic;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveDecel = Curves.decelerate;

  // ═══════════════════════════════════════
  // DECORATIONS GHOST
  // ═══════════════════════════════════════
  static BoxDecoration get cardGhost => BoxDecoration(
    gradient: gradientCard(ghost),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: ghost.withOpacity(0.2)),
    boxShadow: [
      BoxShadow(
        color: ghost.withOpacity(0.1),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ],
  );
}
