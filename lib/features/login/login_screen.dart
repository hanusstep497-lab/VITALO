import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';

/// Layar 01 - Splash & Login (milik Anggota 2 / T2).
///
/// Satu AnimationController menggerakkan seluruh timeline (total 1,4 detik):
///   0     - 690 ms    logo: fade + scale halus
///   500   - 1.050 ms  tagline: fade
///   900   - 1.400 ms  tombol "Masuk dengan email": fade + slide up
/// Ketuk layar saat splash = lewati animasi.
///
/// Masuk dengan email tanpa backend: email apa pun yang tidak kosong
/// langsung membawa ke halaman utama dengan transisi fade.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const _buttonDelay = Duration(milliseconds: 900);
  static const _total = Duration(milliseconds: 1400);

  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _taglineFade;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  bool _navigating = false;
  bool _checkedReduceMotion = false;

  /// Ubah rentang waktu absolut (ms) menjadi Interval 0..1 pada controller.
  Animation<double> _interval(int startMs, int lengthMs) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(
        startMs / _total.inMilliseconds,
        (startMs + lengthMs) / _total.inMilliseconds,
        curve: AppMotion.curve,
      ),
    );
  }

  Animation<Offset> _rise(Animation<double> parent, double from) =>
      Tween<Offset>(begin: Offset(0, from), end: Offset.zero).animate(parent);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _total);

    final logo = _interval(0, 690);
    _logoFade = logo;
    _logoScale = Tween<double>(begin: 0.85, end: 1).animate(logo);
    _taglineFade = _interval(500, 550);

    final button = _interval(
      _buttonDelay.inMilliseconds,
      AppMotion.slow.inMilliseconds,
    );
    _buttonFade = button;
    _buttonSlide = _rise(button, 0.6);

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

  bool get _buttonInteractive =>
      _controller.value >= _buttonDelay.inMilliseconds / _total.inMilliseconds;

  /// Masuk ke halaman utama (AppShell) dengan transisi fade halus.
  /// Tetap memakai builder dari `AppRoutes.routes` agar kontrak route utuh.
  void _enter() {
    if (_navigating) return;
    _navigating = true;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final duration = reduce ? Duration.zero : AppMotion.slow;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder<void>(
        settings: const RouteSettings(name: AppRoutes.shell),
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        pageBuilder: (context, animation, secondaryAnimation) =>
            AppRoutes.routes[AppRoutes.shell]!(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: AppMotion.curve),
          child: child,
        ),
      ),
    );
  }

  /// Sheet input email. Email apa pun diterima (tanpa backend), lalu masuk.
  Future<void> _openEmailSheet() async {
    if (_navigating) return;
    final email = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => const _EmailSheet(),
    );
    if (email != null && mounted) _enter();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.primary,
      // Keyboard milik bottom sheet; jangan ikut menggeser layar ini.
      resizeToAvoidBottomInset: false,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primary,
              Color.lerp(cs.primary, cs.tertiary, 0.45)!,
              cs.tertiary,
            ],
            stops: const [0, 0.55, 1],
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _skipSplash,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  _Decoration(fade: _logoFade),

                  // Logo + tagline: tetap di tengah layar.
                  Positioned.fill(
                    child: Center(
                      child: _LogoBlock(
                        logoFade: _logoFade,
                        logoScale: _logoScale,
                        taglineFade: _taglineFade,
                      ),
                    ),
                  ),

                  // Tombol masuk di bagian bawah halaman awal.
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.xl,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) => IgnorePointer(
                              ignoring: !_buttonInteractive,
                              child: child,
                            ),
                            child: FadeTransition(
                              opacity: _buttonFade,
                              child: SlideTransition(
                                position: _buttonSlide,
                                child: _EmailButton(onPressed: _openEmailSheet),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Lingkaran + gelembung ikon dekoratif di latar (statis, tidak berulang).
class _Decoration extends StatelessWidget {
  const _Decoration({required this.fade});

  final Animation<double> fade;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.onPrimary;
    final safeTop = MediaQuery.paddingOf(context).top;

    Widget circle(double size, double alpha) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.withValues(alpha: alpha),
          ),
        );

    // Gelembung ikon: tidur, air, gerak (tiga pilar Vitalo).
    Widget bubble(IconData icon, double size, double angle) => Transform.rotate(
          angle: angle,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(size * 0.32),
              border: Border.all(color: c.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, size: size * 0.5, color: c.withValues(alpha: 0.75)),
          ),
        );

    return FadeTransition(
      opacity: fade,
      child: Stack(
        children: [
          Positioned(top: -80, right: -70, child: circle(240, 0.08)),
          Positioned(top: 190, left: -60, child: circle(120, 0.06)),
          Positioned(bottom: 260, right: -40, child: circle(100, 0.06)),
          Positioned(
            top: safeTop + 24,
            left: 24,
            child: bubble(Icons.water_drop_rounded, 40, -0.2),
          ),
          Positioned(
            top: safeTop + 32,
            right: 28,
            child: bubble(Icons.directions_walk_rounded, 36, 0.2),
          ),
          Positioned(
            top: safeTop + 96,
            left: 12,
            child: bubble(Icons.bedtime_rounded, 28, 0.15),
          ),
        ],
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
                  // Cincin glow lembut di belakang kotak logo.
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.onPrimary.withValues(alpha: 0.10),
                        ),
                      ),
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: cs.onPrimary.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: cs.onPrimary.withValues(alpha: 0.32),
                          ),
                        ),
                        child: Icon(
                          Icons.spa_rounded,
                          size: 48,
                          color: cs.onPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Vitalo',
                    style: text.displaySmall?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
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

/// Tombol "Masuk dengan email" di halaman awal. Warna dibalik (onPrimary)
/// agar kontras di atas latar gradasi primary.
class _EmailButton extends StatelessWidget {
  const _EmailButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return _PressScale(
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: cs.onPrimary,
          foregroundColor: cs.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.mail_outline_rounded),
        label: const Text('Masuk dengan email'),
      ),
    );
  }
}

/// Bottom sheet masuk dengan email. Tanpa backend: teks apa pun diterima
/// (tidak ada validasi format), hanya tidak boleh kosong.
class _EmailSheet extends StatefulWidget {
  const _EmailSheet();

  @override
  State<_EmailSheet> createState() => _EmailSheetState();
}

class _EmailSheetState extends State<_EmailSheet> {
  final _email = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Isi emailmu dulu ya');
      return;
    }
    Navigator.pop(context, email);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      // Naik mengikuti keyboard agar field tidak tertutup.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread_rounded,
                  size: 28,
                  color: cs.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Masuk dengan email',
              textAlign: TextAlign.center,
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Masukkan emailmu untuk melanjutkan.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _email,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'nama@email.com',
                errorText: _error,
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                prefixIcon: const Icon(Icons.alternate_email_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _PressScale(
              child: FilledButton.icon(
                onPressed: _submit,
                iconAlignment: IconAlignment.end,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Masuk'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Mode demo: email apa pun bisa dipakai.',
              textAlign: TextAlign.center,
              style: text.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
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