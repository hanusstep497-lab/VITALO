import 'package:flutter/material.dart';

import '../theme.dart';
import 'main_shell.dart';

/// LAYAR 01 - Splash & Login.
/// Tahap progress: tombol login hanya tampilan, langsung menuju Home.
class SplashLoginScreen extends StatelessWidget {
  const SplashLoginScreen({super.key});

  void _enter(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
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
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, v, child) => Opacity(opacity: v, child: child),
                child: Column(
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: const BoxDecoration(
                        color: VColors.teal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_rounded, size: 46, color: VColors.forest),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Vitalo',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sehat, sedikit demi sedikit.',
                      style: TextStyle(fontSize: 16, color: VColors.mint),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              FilledButton.icon(
                onPressed: () => _enter(context),
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
                onPressed: () => _enter(context),
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
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
