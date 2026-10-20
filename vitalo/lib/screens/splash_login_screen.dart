import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

/// LAYAR 01 - Splash & Login.
/// Animasi berurutan: logo membesar -> nama -> tagline -> tombol naik.
/// Tahap progress: tombol login hanya tampilan, langsung menuju Home.
class SplashLoginScreen extends StatefulWidget {
  const SplashLoginScreen({super.key});

  @override
  State<SplashLoginScreen> createState() => _SplashLoginScreenState();
}

class _SplashLoginScreenState extends State<SplashLoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _nameFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _buttonsFade;
  late final Animation<Offset> _buttonsSlide;

  Animation<double> _fadeIn(double begin, double end) => CurvedAnimation(
        parent: _c,
        curve: Interval(begin, end, curve: Curves.easeOut),
      );

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack)),
    );
    _logoFade = _fadeIn(0.0, 0.25);
    _nameFade = _fadeIn(0.25, 0.5);
    _taglineFade = _fadeIn(0.4, 0.65);
    _buttonsFade = _fadeIn(0.6, 0.9);
    _buttonsSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic)),
    );

    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _enter() {
    Navigator.of(context).pushReplacement(fadeRoute<void>(const MainShell()));
  }

  @override
  Widget build(BuildContext context) {
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    return Scaffold(
      backgroundColor: VColors.forest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 3),
              FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: const BoxDecoration(
                      color: VColors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_rounded, size: 46, color: VColors.forest),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _nameFade,
                child: const Text(
                  'Vitalo',
                  style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _taglineFade,
                child: const Text(
                  'Sehat, sedikit demi sedikit.',
                  style: TextStyle(fontSize: 16, color: VColors.mint),
                ),
              ),
              const Spacer(flex: 3),
              FadeTransition(
                opacity: _buttonsFade,
                child: SlideTransition(
                  position: _buttonsSlide,
                  child: Column(
                    children: [
                      FilledButton.icon(
                        onPressed: _enter,
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Masuk dengan Google'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: VColors.forest,
                          minimumSize: const Size.fromHeight(54),
                          shape: buttonShape,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _enter,
                        icon: const Icon(Icons.mail_outline_rounded),
                        label: const Text('Masuk dengan email'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: VColors.teal),
                          minimumSize: const Size.fromHeight(54),
                          shape: buttonShape,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Mulai catat kebiasaanmu hari ini',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tanpa formulir panjang. Hanya jalur masuk yang jelas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: VColors.mint),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
