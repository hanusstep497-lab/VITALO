import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// Dialog singkat dengan centang beranimasi, menutup sendiri (~1,1 detik).
Future<void> showSuccessCheck(BuildContext context, String message) async {
  HapticFeedback.mediumImpact();
  final navigator = Navigator.of(context);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black26,
    builder: (_) => _SuccessDialog(message: message),
  );
  await Future<void>.delayed(const Duration(milliseconds: 1100));
  if (navigator.mounted) navigator.pop();
}

/// Perayaan target tercapai: confetti + badge, menutup sendiri (~2,2 detik).
Future<void> showCelebration(
  BuildContext context, {
  required String title,
  required String subtitle,
}) async {
  HapticFeedback.heavyImpact();
  final navigator = Navigator.of(context);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black38,
    builder: (_) => _CelebrationDialog(title: title, subtitle: subtitle),
  );
  await Future<void>.delayed(const Duration(milliseconds: 2200));
  if (navigator.mounted) navigator.pop();
}

// ------------------------------------------------------------ Centang
class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              builder: (context, v, _) {
                final circle = Curves.easeOutBack.transform((v * 2).clamp(0.0, 1.0).toDouble());
                final check = ((v - 0.4) / 0.6).clamp(0.0, 1.0).toDouble();
                return Transform.scale(
                  scale: circle,
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(color: VColors.teal, shape: BoxShape.circle),
                    child: CustomPaint(painter: _CheckPainter(check)),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: VColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.27, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.68)
      ..lineTo(size.width * 0.74, size.height * 0.36);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) => old.progress != progress;
}

// ----------------------------------------------------------- Confetti
class _CelebrationDialog extends StatefulWidget {
  const _CelebrationDialog({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _ConfettiPainter(_c)),
            ),
          ),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.3, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events_rounded, size: 60, color: VColors.orange),
                    const SizedBox(height: 10),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: VColors.ink),
                    ),
                    const SizedBox(height: 6),
                    Text(widget.subtitle, textAlign: TextAlign.center, style: kMutedStyle),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Particle {
  _Particle(this.angle, this.speed, this.color, this.size, this.spin);

  final double angle;
  final double speed;
  final Color color;
  final double size;
  final double spin;
}

List<_Particle> _makeParticles() {
  final rnd = math.Random(42);
  const colors = [VColors.teal, VColors.orange, VColors.forest, Color(0xFFFFC857), Color(0xFF7AD9D5)];
  return List.generate(48, (i) {
    return _Particle(
      -math.pi * (0.1 + rnd.nextDouble() * 0.8),
      260 + rnd.nextDouble() * 380,
      colors[i % colors.length],
      6 + rnd.nextDouble() * 8,
      rnd.nextDouble() * 8,
    );
  });
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;
  final List<_Particle> _particles = _makeParticles();

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final time = t * 1.6;
    final origin = Offset(size.width / 2, size.height * 0.55);
    final opacity = (1 - t).clamp(0.0, 1.0).toDouble();

    for (final p in _particles) {
      final x = origin.dx + math.cos(p.angle) * p.speed * time;
      final y = origin.dy + math.sin(p.angle) * p.speed * time + 0.5 * 900 * time * time;
      final paint = Paint()..color = p.color.withAlpha((opacity * 255).round());
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * t * 3);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => true;
}
