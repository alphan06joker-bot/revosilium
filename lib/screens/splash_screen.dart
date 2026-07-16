import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import '../theme/revosilium_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _glitchCtrl;

  @override
  void initState() {
    super.initState();
    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glitchCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _mainCtrl.forward();

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        HapticFeedback.lightImpact();
        _glitchCtrl.forward().then((_) {
          _glitchCtrl.reverse();
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 3400), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, a, __, c) {
              final curved = Curves.easeOutCubic.transform(a.value);
              return ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    R.pri.withOpacity(curved),
                    Colors.white.withOpacity(curved),
                    R.pri.withOpacity(curved),
                  ],
                ).createShader(bounds),
                child: c,
              );
            },
            transitionDuration: const Duration(milliseconds: 900),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    _glitchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: R.gradientBg),
        child: Center(
          child: AnimatedBuilder(
            animation: _mainCtrl,
            builder: (_, __) {
              final t = Curves.easeOutCubic.transform(
                (_mainCtrl.value).clamp(0.0, 1.0),
              );
              return Transform.scale(
                scale: 0.6 + 0.4 * t,
                child: Opacity(
                  opacity: t.clamp(0.0, 1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 48),
                      _buildTitle(),
                      const SizedBox(height: 14),
                      AnimatedBuilder(
                        animation: _mainCtrl,
                        builder: (_, __) {
                          final fadeIn = ((_mainCtrl.value - 0.3) / 0.7).clamp(0.0, 1.0);
                          return Opacity(
                            opacity: fadeIn,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - fadeIn)),
                              child: Text(
                                'COMMUNICATION DIRECTE',
                                style: TextStyle(
                                  color: R.pri.withOpacity(0.35),
                                  fontSize: 10,
                                  letterSpacing: 6,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, __) {
                          return Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: R.pri.withOpacity(0.2 + _pulseCtrl.value * 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: R.pri.withOpacity(0.1 + _pulseCtrl.value * 0.2),
                                  blurRadius: 10 + _pulseCtrl.value * 15,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: R.pri.withOpacity(0.6 + _pulseCtrl.value * 0.4),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'P2P · AES-256 · ZERO TRACE',
                        style: TextStyle(
                          color: R.txt2.withOpacity(0.3),
                          fontSize: 8,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseCtrl, _glitchCtrl]),
      builder: (_, __) {
        final pulse = _pulseCtrl.value;
        final glitch = _glitchCtrl.value;
        final offsetX = glitch > 0.5 ? (Random().nextDouble() - 0.5) * 8 * glitch : 0.0;
        final offsetY = glitch > 0.5 ? (Random().nextDouble() - 0.5) * 4 * glitch : 0.0;

        return Transform.translate(
          offset: Offset(offsetX, offsetY),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 130 + pulse * 30,
                height: 130 + pulse * 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: R.pri.withOpacity(0.15 + pulse * 0.1),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: R.pri.withOpacity(0.1 + pulse * 0.15),
                      blurRadius: 40 + pulse * 20,
                    ),
                  ],
                ),
              ),
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: R.pri.withOpacity(0.3 + pulse * 0.15),
                    width: 1.5,
                  ),
                ),
              ),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      R.pri.withOpacity(0.08 + pulse * 0.06),
                      R.pri.withOpacity(0.02),
                    ],
                  ),
                  border: Border.all(
                    color: R.pri.withOpacity(0.5),
                    width: 1.8,
                  ),
                  boxShadow: R.shadowGlow(blur: 25, opacity: 0.2 + pulse * 0.1),
                ),
                child: Center(
                  child: Text(
                    'R',
                    style: TextStyle(
                      color: R.pri,
                      fontSize: 38 + pulse * 4,
                      fontWeight: FontWeight.w100,
                      height: 1,
                    ),
                  ),
                ),
              ),
              if (glitch > 0.3)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            R.accent.withOpacity(glitch * 0.15),
                            Colors.transparent,
                            R.pri.withOpacity(glitch * 0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainCtrl, _glitchCtrl]),
      builder: (_, __) {
        final glitch = _glitchCtrl.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            if (glitch > 0.3)
              Transform.translate(
                offset: Offset(3 * glitch, -2 * glitch),
                child: Text(
                  'REVOSILIUM',
                  style: R.hero.copyWith(
                    color: R.err.withOpacity(glitch * 0.5),
                  ),
                ),
              ),
            if (glitch > 0.3)
              Transform.translate(
                offset: Offset(-3 * glitch, 2 * glitch),
                child: Text(
                  'REVOSILIUM',
                  style: R.hero.copyWith(
                    color: R.accent.withOpacity(glitch * 0.5),
                  ),
                ),
              ),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  R.pri,
                  R.priL,
                  R.pri,
                ],
              ).createShader(bounds),
              child: const Text('REVOSILIUM', style: R.hero),
            ),
          ],
        );
      },
    );
  }
}
