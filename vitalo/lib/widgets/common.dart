import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Transisi antar halaman: fade halus (dipakai login <-> halaman utama).
Route<T> fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondary) => page,
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondary, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

/// Kartu putih dengan border tipis. Perubahan warna dianimasikan halus.
class VCard extends StatelessWidget {
  const VCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final Color color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VColors.border),
      ),
      child: child,
    );
  }
}

/// Cincin progres. Terisi dari 0 saat pertama tampil dan bergerak halus
/// setiap nilainya berubah.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.size,
    required this.stroke,
    required this.color,
    this.child,
  });

  final double value;
  final double size;
  final double stroke;
  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0).toDouble()),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, v, inner) {
        return CustomPaint(
          painter: _RingPainter(value: v, stroke: stroke, color: color),
          child: inner,
        );
      },
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.stroke, required this.color});

  final double value;
  final double stroke;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = VColors.border;
    canvas.drawCircle(center, radius, track);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    final sweep = 2 * math.pi * value.clamp(0.0, 1.0).toDouble();
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color || old.stroke != stroke;
}

/// Angka yang "berhitung naik" dari 0 (atau dari nilai sebelumnya).
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    required this.style,
    this.formatter,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 900),
  });

  final int value;
  final TextStyle style;
  final String Function(int)? formatter;
  final String prefix;
  final String suffix;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        final n = v.round();
        final text = formatter != null ? formatter!(n) : '$n';
        return Text('$prefix$text$suffix', style: style);
      },
    );
  }
}

/// Animasi masuk berurutan (staggered): fade + geser (+ opsional membesar).
/// [delay] menentukan urutan muncul; tanpa Timer sehingga aman untuk test.
class Staggered extends StatefulWidget {
  const Staggered({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.slide = const Offset(0, 0.08),
    this.scaleFrom = 1.0,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slide;
  final double scaleFrom;

  @override
  State<Staggered> createState() => _StaggeredState();
}

class _StaggeredState extends State<Staggered> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<double> _move;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    final total = widget.delay + widget.duration;
    _c = AnimationController(vsync: this, duration: total);
    final start = widget.delay.inMilliseconds / total.inMilliseconds;
    _fade = CurvedAnimation(parent: _c, curve: Interval(start, 1.0, curve: Curves.easeOut));
    _move = CurvedAnimation(parent: _c, curve: Interval(start, 1.0, curve: Curves.easeOutCubic));
    _scale = CurvedAnimation(parent: _c, curve: Interval(start, 1.0, curve: Curves.easeOutBack));
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: Tween<Offset>(begin: widget.slide, end: Offset.zero).animate(_move),
        child: ScaleTransition(
          scale: Tween<double>(begin: widget.scaleFrom, end: 1.0).animate(_scale),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Denyut membesar-mengecil beberapa kali lalu berhenti (tidak berulang
/// selamanya, jadi tidak menghambat test).
class Pulse extends StatefulWidget {
  const Pulse({super.key, required this.child, this.cycles = 3});

  final Widget child;
  final int cycles;

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _c.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _c.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _count++;
        if (_count < widget.cycles) _c.forward();
      }
    });
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.25)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}

/// Kontrol - [nilai] + ; angka berganti dengan animasi fade + skala.
class ValueStepper extends StatelessWidget {
  const ValueStepper({
    super.key,
    required this.label,
    required this.valueText,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final String valueText;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return VCard(
      child: Column(
        children: [
          Text(label, style: kMutedStyle),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filledTonal(
                onPressed: onMinus,
                icon: const Icon(Icons.remove_rounded),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(scale: anim, child: child),
                ),
                child: Text(
                  valueText,
                  key: ValueKey<String>(valueText),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: VColors.ink,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: onPlus,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
