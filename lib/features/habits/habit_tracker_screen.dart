import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/habit_tile.dart';
import '../../widgets/section_title.dart';

/// Tab Kebiasaan (Layar 04): konsistensi mingguan, target hari ini, dan streak.
/// Tanpa Scaffold sendiri (milik AppShell); seluruh layar satu ListView.
class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  /// Skor harian >= batas ini dianggap "tercapai".
  static const double _achievedThreshold = 0.6;

  /// Status selesai tiap kebiasaan (state lokal), diawali dari DummyData.
  late final List<bool> _done = [for (final h in DummyData.habits) h.done];

  /// Jumlah lingkaran hari yang sudah "dibuka" (0 saat tab tersembunyi).
  /// Naik satu per satu setelah tab tampil penuh -> terisi berurutan.
  int _revealedCount = 0;

  /// Status tab aktif terakhir (null = belum pernah dicek).
  bool? _tabActive;

  Timer? _revealTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // AppShell membangun semua tab sejak awal & menyembunyikan yang tak aktif
    // lewat TickerMode. Animasi baru dimulai saat tab ini benar-benar tampil.
    final active = TickerMode.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (active == _tabActive) return;
    _tabActive = active;
    _revealTimer?.cancel();

    if (!active) {
      // Reset agar animasi terulang setiap tab dibuka kembali.
      _revealedCount = 0;
      return;
    }
    if (reduce) {
      _revealedCount = DummyData.weeklyScore.length;
      return;
    }
    // Tunggu fade-in tab selesai, lalu isi lingkaran berurutan.
    _revealTimer = Timer(AppMotion.normal, () {
      _revealTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() => _revealedCount++);
        if (_revealedCount >= DummyData.weeklyScore.length) timer.cancel();
      });
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  void _toggle(int index, bool value) => setState(() => _done[index] = value);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Hormati pengaturan "kurangi animasi": durasi nol = tampil langsung.
    final reduce = MediaQuery.disableAnimationsOf(context);
    final duration = reduce ? Duration.zero : AppMotion.normal;

    final week = [
      for (final s in DummyData.weeklyScore) s >= _achievedThreshold,
    ];
    final weekCount = week.where((a) => a).length;

    final habits = DummyData.habits;
    final total = habits.length;
    final doneCount = _done.where((d) => d).length;
    final allDone = total > 0 && doneCount == total;

    return ListView(
      // Padding bawah 96 agar item terakhir tidak tertutup FAB "Catat".
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        96,
      ),
      children: [
        // 1) Judul + subjudul: Column rata kiri (teks dibaca dari kiri).
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kebiasaan saya', style: text.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Centang kecil hari ini, hasilnya terasa nanti.',
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // 2) Kartu konsistensi mingguan.
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konsistensi minggu ini: $weekCount dari 7 hari',
                  style: text.titleSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                // Expanded membagi lebar sama rata -> 7 penanda selalu muat
                // (360 px pun tidak overflow) dan sejajar dengan labelnya.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < week.length; i++)
                      Expanded(
                        child: _DayDot(
                          label: _dayLabels[i],
                          name: _dayNames[i],
                          achieved: i < _revealedCount && week[i],
                          duration: reduce ? Duration.zero : AppMotion.slow,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // 3) Judul bagian + hitungan "X dari Y selesai".
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: SectionTitle('Target hari ini')),
            AnimatedSwitcher(
              duration: duration,
              switchInCurve: AppMotion.curve,
              child: Text(
                '$doneCount dari $total selesai',
                key: ValueKey<int>(doneCount),
                style: text.labelLarge?.copyWith(color: scheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          // ListView di dalam ListView: shrinkWrap + tanpa scroll sendiri.
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: total,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, indent: AppSpacing.md),
            itemBuilder: (context, i) => HabitTile(
              title: habits[i].title,
              subtitle: _done[i] ? 'Selesai' : 'Ketuk untuk menyelesaikan',
              icon: habits[i].icon,
              done: _done[i],
              onChanged: (value) => _toggle(i, value),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 4) Banner streak -> berubah jadi ucapan selamat saat semua selesai.
        Semantics(
          liveRegion: true,
          child: AnimatedSwitcher(
            duration: duration,
            switchInCurve: AppMotion.curve,
            switchOutCurve: AppMotion.curve,
            child: _StreakBanner(
              key: ValueKey<bool>(allDone),
              allDone: allDone,
              days: allDone ? DummyData.streakDays + 1 : DummyData.streakDays,
            ),
          ),
        ),
      ],
    );
  }

  static const List<String> _dayLabels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
  static const List<String> _dayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
}

/// Satu penanda hari: lingkaran (terisi bila tercapai) + huruf hari.
class _DayDot extends StatelessWidget {
  final String label;
  final String name;
  final bool achieved;
  final Duration duration;

  const _DayDot({
    required this.label,
    required this.name,
    required this.achieved,
    required this.duration,
  });

  static const double _size = 32;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Semantics(
      label: '$name, ${achieved ? 'tercapai' : 'belum tercapai'}',
      excludeSemantics: true,
      child: Column(
        // Pusatkan lingkaran & huruf di tengah sel Expanded.
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: duration,
            curve: AppMotion.curve,
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: achieved ? scheme.primary : scheme.surfaceContainerHighest,
            ),
            child: AnimatedOpacity(
              duration: duration,
              curve: AppMotion.curve,
              opacity: achieved ? 1 : 0,
              child: Icon(
                Icons.check_rounded,
                size: 18,
                color: scheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Banner streak: ikon + teks + chip. Varian selamat saat [allDone].
class _StreakBanner extends StatelessWidget {
  final bool allDone;
  final int days;

  const _StreakBanner({super.key, required this.allDone, required this.days});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final background =
        allDone ? scheme.primaryContainer : scheme.tertiaryContainer;
    final foreground =
        allDone ? scheme.onPrimaryContainer : scheme.onTertiaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        // Ikon, teks, dan chip sejajar di tengah vertikal.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            allDone
                ? Icons.celebration_rounded
                : Icons.local_fire_department_rounded,
            size: 32,
            color: foreground,
          ),
          const SizedBox(width: AppSpacing.md),
          // Expanded: teks panjang membungkus, chip tetap di kanan.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  allDone ? 'Mantap, semua target selesai!' : 'Streak aktif',
                  style: text.titleSmall?.copyWith(color: foreground),
                ),
                Text(
                  allDone
                      ? 'Streak kamu naik jadi $days hari.'
                      : 'Selesaikan semua target untuk lanjut.',
                  style: text.bodySmall?.copyWith(color: foreground),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Chip(
            label: Text('$days hari'),
            visualDensity: VisualDensity.compact,
            backgroundColor: scheme.surface,
          ),
        ],
      ),
    );
  }
}