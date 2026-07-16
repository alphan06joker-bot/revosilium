import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/revosilium_theme.dart';

/// Fond animé avec particules néon
class ParticleBackground extends StatefulWidget {
  final Widget child;
  const ParticleBackground({super.key, required this.child});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  final List<_Particle> _particles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    for (int i = 0; i < 30; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: 1.5 + _rng.nextDouble() * 2.5,
        speed: 0.02 + _rng.nextDouble() * 0.06,
        opacity: 0.1 + _rng.nextDouble() * 0.3,
        phase: _rng.nextDouble() * 2 * pi,
      ));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(decoration: const BoxDecoration(gradient: R.gradientBg)),
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            return CustomPaint(
              size: Size.infinite,
              painter: _ParticlePainter(
                particles: _particles,
                time: _ctrl.value,
              ),
            );
          },
        ),
        CustomPaint(
          size: Size.infinite,
          painter: _GridPainter(),
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  final double x, y, size, speed, opacity, phase;
  _Particle({
    required this.x, required this.y, required this.size,
    required this.speed, required this.opacity, required this.phase,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double time;

  _ParticlePainter({required this.particles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = (p.y + time * p.speed) % 1.0;
      final x = p.x + sin(time * 2 * pi + p.phase) * 0.03;
      final paint = Paint()
        ..color = R.pri.withOpacity(p.opacity * (1.0 - y * 0.5))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = R.pri.withOpacity(0.02)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => false;
}
