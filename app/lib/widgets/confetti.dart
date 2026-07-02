/// Tiny confetti burst — used for achievement unlock + lesson-complete.
///
/// We don't use a heavyweight package. Just a simple AnimationController +
/// a few colored dots that fall and fade.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Confetti extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final int particleCount;
  final Duration duration;

  const Confetti({
    super.key,
    required this.child,
    this.trigger = false,
    this.particleCount = 18,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  final List<_Particle> _particles = [];
  final _rand = math.Random();

  @override
  void initState() {
    super.initState();
    _particles.addAll(List.generate(widget.particleCount, (i) => _Particle.random(_rand)));
    if (widget.trigger) _ctrl.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant Confetti old) {
    super.didUpdateWidget(old);
    if (widget.trigger && !old.trigger) {
      _ctrl.forward(from: 0);
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
      alignment: Alignment.center,
      children: [
        widget.child,
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              if (_ctrl.value == 0) return const SizedBox.shrink();
              return CustomPaint(
                size: Size.infinite,
                painter: _ParticlePainter(_particles, _ctrl.value),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Particle {
  double dx, dy;
  double vx, vy;
  Color color;
  double size;

  _Particle(this.dx, this.dy, this.vx, this.vy, this.color, this.size);

  factory _Particle.random(math.Random r) {
    final colors = [
      AppColors.accent,
      AppColors.accent.withValues(alpha: 0.7),
      AppColors.ink.withValues(alpha: 0.5),
      const Color(0xFFD4A574),
      const Color(0xFFA8B89A),
    ];
    final angle = r.nextDouble() * math.pi * 2;
    final speed = 1.0 + r.nextDouble() * 1.5;
    return _Particle(
      0.5,
      0.5,
      math.cos(angle) * speed,
      math.sin(angle) * speed - 0.4, // bias upward
      colors[r.nextInt(colors.length)],
      4.0 + r.nextDouble() * 4.0,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t; // 0..1
  _ParticlePainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final fade = (1.0 - t).clamp(0.0, 1.0);
    for (final p in particles) {
      final cx = size.width * (p.dx + p.vx * t * 0.4);
      final cy = size.height * (p.dy + p.vy * t * 0.5 + 0.5 * t * t);
      final paint = Paint()
        ..color = p.color.withValues(alpha: fade)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), p.size * (1.0 - t * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.t != t;
}