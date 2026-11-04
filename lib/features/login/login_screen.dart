import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';

/// Layar 01 - Splash & Login (milik Anggota 2 / T2).
///
/// Satu AnimationController menggerakkan seluruh timeline (total 2,4 detik):
///   0     - 690 ms    logo: fade + scale halus
///   500   - 1.050 ms  tagline: fade
///   1.800 - 2.300 ms  panel login: slide up + fade (AppMotion.slow);
///                     logo mengecil & pindah ke atas
///   1.850 - 2.290 ms  kartu "Ringkasan hari ini": fade + slide
///   1.950 - 2.390 ms  chip streak & konsistensi: fade + slide
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
  static const _panelDelay = Duration(milliseconds: 1800);
  static const _total = Duration(milliseconds: 2400);

  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _taglineFade;
  late final Animation<double> _panelFade;
  late final Animation<Offset> _panelSlide;
  late final Animation<double> _logoShift;
  late final Animation<double> _previewFade;
  late final Animation<Offset> _previewSlide;
  late final Animation<double> _chipsFade;
  late final Animation<Offset> _chipsSlide;

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

    final panel = _interval(1800, AppMotion.slow.inMilliseconds);
    _panelFade = panel;
    _panelSlide = _rise(panel, 0.6);
    _logoShift = panel;

    final preview = _interval(1850, 440);
    _previewFade = preview;
    _previewSlide = _rise(preview, 0.25);

    final chips = _interval(1950, 440);
    _chipsFade = chips;
    _chipsSlide = _rise(chips, 0.4);

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

  bool get _panelInteractive =>
      _controller.value >= _panelDelay.inMilliseconds / _total.inMilliseconds;

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
    final safeTop = MediaQuery.paddingOf(context).top;

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
              // Posisi akhir logo: mengecil di bagian atas layar.
              final logoTargetY = safeTop + 64;
              final dy = logoTargetY - constraints.maxHeight / 2;

              return Stack(
                children: [
                  _Decoration(fade: _logoFade),

                  // Logo + tagline: di tengah saat splash, naik & mengecil
                  // saat panel login muncul.
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _logoShift,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, dy * _logoShift.value),
                        child: Transform.scale(
                          scale: 1 - 0.4 * _logoShift.value,
                          child: child,
                        ),
                      ),
                      child: Center(
                        child: _LogoBlock(
                          logoFade: _logoFade,
                          logoScale: _logoScale,
                          taglineFade: _taglineFade,
                        ),
                      ),
                    ),
                  ),

                  // Pratinjau isi aplikasi (data contoh).
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        safeTop + 128,
                        AppSpacing.lg,
                        0,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FadeTransition(
                              opacity: _previewFade,
                              child: SlideTransition(
                                position: _previewSlide,
                                child: const _PreviewCard(),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            FadeTransition(
                              opacity: _chipsFade,
                              child: SlideTransition(
                                position: _chipsSlide,
                                child: const _InfoChips(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Panel login.
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
                          child: _LoginPanel(onEmail: _openEmailSheet),
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

/// Kartu kaca "Ringkasan hari ini" - data contoh dari proposal.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.onPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.onPrimary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'RINGKASAN HARI INI',
            style: text.labelSmall?.copyWith(
              color: cs.onPrimary.withValues(alpha: 0.8),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: 5 / 8,
                        strokeWidth: 8,
                        color: cs.onPrimary,
                        backgroundColor: cs.onPrimary.withValues(alpha: 0.2),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '5/8',
                          style: text.titleMedium?.copyWith(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'gelas',
                          style: text.labelSmall?.copyWith(
                            color: cs.onPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MiniStat(
                      icon: Icons.water_drop_rounded,
                      label: 'Air minum',
                      value: '62%',
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _MiniStat(
                      icon: Icons.bedtime_rounded,
                      label: 'Tidur',
                      value: '7j 20m',
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _MiniStat(
                      icon: Icons.directions_walk_rounded,
                      label: 'Langkah',
                      value: '4.280',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: cs.onPrimary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: text.bodySmall?.copyWith(
              color: cs.onPrimary.withValues(alpha: 0.85),
            ),
          ),
        ),
        Text(
          value,
          style: text.bodyMedium?.copyWith(
            color: cs.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InfoChips extends StatelessWidget {
  const _InfoChips();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _InfoChip(
          icon: Icons.local_fire_department_rounded,
          label: 'Streak 4 hari',
        ),
        _InfoChip(
          icon: Icons.trending_up_rounded,
          label: '+23% lebih konsisten',
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: cs.onPrimary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: cs.onPrimary),
          ),
        ],
      ),
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({required this.onEmail});

  final VoidCallback onEmail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm + 4,
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
                  // Pegangan kecil khas bottom panel.
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cs.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Selamat datang',
                    textAlign: TextAlign.center,
                    style: text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Mulai catat kebiasaanmu hari ini.',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PressScale(
                    child: FilledButton.icon(
                      onPressed: onEmail,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: buttonShape,
                      ),
                      icon: const Icon(Icons.mail_outline_rounded),
                      label: const Text('Masuk dengan email'),
                    ),
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