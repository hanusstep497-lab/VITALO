import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../data/dummy_data.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/section_title.dart';
import '../../widgets/stat_card.dart';

/// Layar 02 - Home Dashboard (T3a).
///
/// Tab screen: tanpa Scaffold (Scaffold dimiliki `AppShell`), scrollable,
/// dengan padding bawah 96 agar konten terakhir tidak tertutup FAB "Catat".
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _bottomPadding = 96;
  static const String _headerAsset = 'assets/images/t3a_home_header.png';
  static const String _headerLabel =
      'Ilustrasi header Vitalo: kebiasaan sehat setiap hari';

  /// Target tidur 8 jam. DummyData belum punya target tidur, jadi ditaruh
  /// di sini hanya untuk mengisi progress bar kartu Tidur.
  static const int _sleepTargetMinutes = 480;

  // Nama hari manual (tanpa package intl). Indeks 0 = Senin = weekday 1.
  static const List<String> _dayNames = [
    'SENIN',
    'SELASA',
    'RABU',
    'KAMIS',
    'JUMAT',
    'SABTU',
    'MINGGU',
  ];

  /// "4280" -> "4.280" (pemisah ribuan gaya Indonesia, tanpa intl).
  static String _formatThousands(int n) {
    final digits = n.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// 440 -> "7j 20m".
  static String _formatSleep(int minutes) => '${minutes ~/ 60}j ${minutes % 60}m';

  // Buka layar tambah catatan; tampilkan SnackBar jika hasilnya true
  // (perilaku yang sama dengan tombol FAB "Catat" di AppShell).
  Future<void> _openAddEntry(BuildContext context) async {
    final saved = await Navigator.pushNamed<bool>(context, AppRoutes.addEntry);
    if (!context.mounted || saved != true) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Catatan tersimpan')));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final dayLabel =
        '${_dayNames[DateTime.now().weekday - 1]}, HARI INI';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        _bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1 + 2. Header hari dan sapaan: fade-in ringan.
          _FadeIn(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayLabel,
                  style: text.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                RichText(
                  textScaler: MediaQuery.textScalerOf(context),
                  text: TextSpan(
                    style: text.headlineSmall?.copyWith(
                      color: scheme.onSurface,
                    ),
                    children: [
                      const TextSpan(text: 'Halo, '),
                      TextSpan(
                        text: DummyData.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                      const TextSpan(text: ', kamu siap?'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 3. Ilustrasi header (aman walau asset belum ada).
          const _HeaderImage(asset: _headerAsset, semanticLabel: _headerLabel),
          const SizedBox(height: AppSpacing.md),

          // 4. Ringkasan tiga kebiasaan. Angka dan progress terisi bergiliran
          // (air -> tidur -> langkah) setelah transisi masuk dari login
          // selesai, supaya animasinya benar-benar terlihat.
          _StagedProgress(
            builder: (context, stage) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CountUp(
                  end: stage >= 1 ? DummyData.waterGlasses : 0,
                  builder: (context, value) => Semantics(
                    container: true,
                    excludeSemantics: true,
                    label: 'Air minum, ${DummyData.waterGlasses} dari '
                        '${DummyData.waterTarget} gelas',
                    child: StatCard(
                      title: 'Air minum',
                      value: '$value',
                      unit: '/ ${DummyData.waterTarget} gelas',
                      icon: Icons.water_drop_rounded,
                      progress: stage >= 1
                          ? DummyData.waterGlasses / DummyData.waterTarget
                          : 0,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _CountUp(
                        end: stage >= 2 ? DummyData.sleepMinutes : 0,
                        builder: (context, minutes) => Semantics(
                          container: true,
                          excludeSemantics: true,
                          label: 'Tidur semalam, '
                              '${_formatSleep(DummyData.sleepMinutes)}',
                          child: StatCard(
                            title: 'Tidur',
                            value: _formatSleep(minutes),
                            unit: 'semalam',
                            icon: Icons.bedtime_rounded,
                            progress: stage >= 2
                                ? DummyData.sleepMinutes / _sleepTargetMinutes
                                : 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _CountUp(
                        end: stage >= 3 ? DummyData.steps : 0,
                        builder: (context, steps) => Semantics(
                          container: true,
                          excludeSemantics: true,
                          label: 'Aktivitas, '
                              '${_formatThousands(DummyData.steps)} langkah',
                          child: StatCard(
                            title: 'Aktivitas',
                            value: _formatThousands(steps),
                            unit: 'langkah',
                            icon: Icons.directions_walk_rounded,
                            progress: stage >= 3
                                ? DummyData.steps / DummyData.stepTarget
                                : 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Kalimat target muncul (fade) setelah kartu air mulai terisi.
                AnimatedOpacity(
                  opacity: stage >= 1 ? 1 : 0,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : AppMotion.slow,
                  curve: AppMotion.curve,
                  child: _TargetSummary(
                    glasses: DummyData.waterGlasses,
                    target: DummyData.waterTarget,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 5. Judul bagian + tombol tambah catatan.
          const SectionTitle('Progres hari ini'),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openAddEntry(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah catatan'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fade-in ringan satu kali saat pertama tampil. Jika pengguna mematikan
/// animasi sistem, konten langsung tampil penuh.
class _FadeIn extends StatelessWidget {
  const _FadeIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: reduceMotion ? 1 : 0, end: 1),
      duration: reduceMotion ? Duration.zero : AppMotion.normal,
      curve: AppMotion.curve,
      builder: (context, opacity, child) =>
          Opacity(opacity: opacity, child: child),
      child: child,
    );
  }
}

/// Mengatur tahap animasi progress di Home: 0 = kosong, 1 = air, 2 = tidur,
/// 3 = langkah. Tahap baru dimulai setelah animasi transisi route (fade dari
/// layar login) selesai, lalu naik satu tahap tiap 160 ms. Hanya berjalan
/// sekali saat Home pertama dibuat, jadi tidak berulang. Jika animasi sistem
/// dimatikan, semua tahap langsung penuh.
class _StagedProgress extends StatefulWidget {
  const _StagedProgress({required this.builder});

  final Widget Function(BuildContext context, int stage) builder;

  @override
  State<_StagedProgress> createState() => _StagedProgressState();
}

class _StagedProgressState extends State<_StagedProgress> {
  static const int _lastStage = 3;
  static const Duration _gap = Duration(milliseconds: 160);

  int _stage = 0;
  bool _started = false;
  Timer? _timer;
  Animation<double>? _routeAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    if (MediaQuery.disableAnimationsOf(context)) {
      _stage = _lastStage;
      return;
    }

    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.status == AnimationStatus.completed) {
      _begin();
    } else {
      _routeAnimation = animation..addStatusListener(_onRouteStatus);
    }
  }

  void _onRouteStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _routeAnimation = null;
    _begin();
  }

  void _begin() {
    _timer = Timer.periodic(_gap, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _stage++);
      if (_stage >= _lastStage) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _stage);
}

/// Menghitung naik dari 0 ke [end] satu kali saat pertama tampil. Karena
/// [end] tidak berubah, animasi tidak diulang pada rebuild berikutnya.
class _CountUp extends StatelessWidget {
  const _CountUp({required this.end, required this.builder});

  final int end;
  final Widget Function(BuildContext context, int value) builder;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: reduceMotion ? end.toDouble() : 0,
        end: end.toDouble(),
      ),
      duration: reduceMotion ? Duration.zero : AppMotion.slow,
      curve: AppMotion.curve,
      builder: (context, value, _) => builder(context, value.round()),
    );
  }
}

/// Ilustrasi header. Memakai [Image.asset]; bila file belum ada, tampil
/// fallback gradient + ikon sehingga layar tetap jalan.
class _HeaderImage extends StatelessWidget {
  const _HeaderImage({required this.asset, required this.semanticLabel});

  final String asset;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          semanticLabel: semanticLabel,
          errorBuilder: (context, error, stackTrace) =>
              _HeaderFallback(semanticLabel: semanticLabel),
        ),
      ),
    );
  }
}

class _HeaderFallback extends StatelessWidget {
  const _HeaderFallback({required this.semanticLabel});

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticLabel,
      image: true,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primaryContainer, scheme.secondaryContainer],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.spa_rounded,
            size: 64,
            color: scheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

/// Kalimat ringkasan target harian; angkanya dicetak tebal lewat RichText.
class _TargetSummary extends StatelessWidget {
  const _TargetSummary({required this.glasses, required this.target});

  final int glasses;
  final int target;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final base = text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);
    final bold = TextStyle(
      fontWeight: FontWeight.w700,
      color: scheme.onSurface,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.flag_rounded, size: 20, color: scheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: RichText(
            textScaler: MediaQuery.textScalerOf(context),
            text: TextSpan(
              style: base,
              children: [
                const TextSpan(text: 'Target harian hampir tercapai: '),
                TextSpan(text: '$glasses', style: bold),
                const TextSpan(text: ' dari '),
                TextSpan(text: '$target', style: bold),
                const TextSpan(text: ' gelas air, tinggal '),
                TextSpan(text: '${target - glasses}', style: bold),
                const TextSpan(text: ' gelas lagi.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}