import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';

/// Layar 01 - Splash & Login (milik Anggota 2 / T2).
///
/// Satu AnimationController menggerakkan seluruh timeline:
///   0 ms     - 690 ms   logo: fade + scale halus
///   500 ms   - 1.050 ms tagline: fade
///   1.800 ms - 2.300 ms panel login: slide up + fade (AppMotion.slow)
///   1.800 ms - 2.300 ms logo naik sedikit memberi ruang untuk panel
/// Total 2,3 detik (<= 2,5 detik). Ketuk layar saat splash = lewati animasi.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const _panelDelay = Duration(milliseconds: 1800);
  static const _logoDuration = Duration(milliseconds: 690);
  static const _taglineStart = Duration(milliseconds: 500);
  static const _taglineDuration = Duration(milliseconds: 550);

  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _taglineFade;
  late final Animation<double> _panelFade;
  late final Animation<Offset> _panelSlide;
  late final Animation<double> _logoShift;

  bool _navigating = false;
  bool _checkedReduceMotion = false;

  Duration get _total => _panelDelay + AppMotion.slow;

  /// Ubah rentang waktu absolut menjadi Interval 0..1 pada controller.
  Animation<double> _interval(Duration start, Duration length) {
    final s = start.inMilliseconds / _total.inMilliseconds;
    final e = (start + length).inMilliseconds / _total.inMilliseconds;
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(s, e, curve: AppMotion.curve),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _total);

    final logo = _interval(Duration.zero, _logoDuration);
    _logoFade = logo;
    _logoScale = Tween<double>(begin: 0.85, end: 1).animate(logo);
    _taglineFade = _interval(_taglineStart, _taglineDuration);

    final panel = _interval(_panelDelay, AppMotion.slow);
    _panelFade = panel;
    _panelSlide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(panel);
    _logoShift = panel;

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hormati pengaturan "kurangi animasi" dari sistem.
    if (!_checkedReduceMotion) {
      _checkedReduceMotion = true;
      if (MediaQuery.disableAnimationsOf(context)) _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _skipSplash() {
    if (_controller.value < 1) _controller.value = 1;
  }

  bool get _panelInteractive => _controller.value >= _panelDelay.inMilliseconds / _total.inMilliseconds;

  void _enter() {
    if (_navigating) return;
    _navigating = true;
    Navigator.pushReplacementNamed(context, AppRoutes.shell);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.primary,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _skipSplash,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Logo naik sedikit saat panel muncul; aman untuk layar 360x640.
            final maxShift = math.min(constraints.maxHeight * 0.14, 96.0);
            return Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _logoShift,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, -maxShift * _logoShift.value),
                      child: child,
                    ),
                    child: Center(child: _LogoBlock(
                      logoFade: _logoFade,
                      logoScale: _logoScale,
                      taglineFade: _taglineFade,
                    )),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) => IgnorePointer(
                      ignoring: !_panelInteractive,
                      child: child,
                    ),
                    child: FadeTransition(
                      opacity: _panelFade,
                      child: SlideTransition(
                        position: _panelSlide,
                        child: _LoginPanel(onEnter: _enter),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LogoBlock extends StatelessWidget {
  const _LogoBlock({
    required this.logoFade,
    required this.logoScale,
    required this.taglineFade,
  });

  final Animation<double> logoFade;
  final Animation<double> logoScale;
  final Animation<double> taglineFade;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: logoFade,
            child: ScaleTransition(
              scale: logoScale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: cs.onPrimary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(Icons.spa_rounded, size: 48, color: cs.onPrimary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Vitalo',
                    style: text.displaySmall?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FadeTransition(
            opacity: taglineFade,
            child: Text(
              'Sehat, sedikit demi sedikit.',
              textAlign: TextAlign.center,
              style: text.bodyLarge?.copyWith(
                color: cs.onPrimary.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({required this.onEnter});

  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PressScale(
                    child: FilledButton.icon(
                      onPressed: onEnter,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
                      label: const Text('Masuk dengan Google'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PressScale(
                    child: OutlinedButton.icon(
                      onPressed: onEnter,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      icon: const Icon(Icons.mail_outline_rounded),
                      label: const Text('Masuk dengan email'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Mulai catat kebiasaanmu hari ini',
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Feedback tekan: skala 0.97 saat jari menyentuh tombol.
/// Memakai AnimatedScale (implisit) sehingga tidak menambah AnimationController.
class _PressScale extends StatefulWidget {
  const _PressScale({required this.child});

  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.curve,
        child: widget.child,
      ),
    );
  }
}