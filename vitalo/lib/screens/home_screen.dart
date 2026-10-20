import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';

/// LAYAR 02 - Home Dashboard (ringkasan harian).
/// Animasi: kartu muncul berurutan, cincin terisi, angka count-up,
/// bar progres bergerak halus.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onAdd});

  final VoidCallback onAdd;

  static const _days = ['SENIN', 'SELASA', 'RABU', 'KAMIS', 'JUMAT', 'SABTU', 'MINGGU'];

  static const _bigNumber = TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: VColors.ink);

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final day = _days[DateTime.now().weekday - 1];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Staggered(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$day, HARI INI', style: kLabelStyle),
                const SizedBox(height: 4),
                const Text('Halo, kamu siap?', style: kTitleStyle),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Staggered(
            delay: const Duration(milliseconds: 100),
            child: VCard(
              child: Row(
                children: [
                  ProgressRing(
                    value: s.waterRatio,
                    size: 96,
                    stroke: 10,
                    color: VColors.teal,
                    child: CountUpText(
                      value: s.waterGlasses,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: VColors.ink),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Air minum', style: kLabelStyle),
                        const SizedBox(height: 4),
                        Text(
                          '${s.waterGlasses} / ${s.waterTarget} gelas',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: VColors.ink),
                        ),
                        const SizedBox(height: 4),
                        Text(s.waterStatus, style: kMutedStyle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Staggered(
            delay: const Duration(milliseconds: 200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _MiniStat(
                    icon: Icons.bedtime_rounded,
                    title: 'Tidur',
                    caption: 'Semalam',
                    number: CountUpText(
                      value: s.sleep.inMinutes,
                      formatter: (n) => fmtDuration(Duration(minutes: n)),
                      style: _bigNumber,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    icon: Icons.directions_walk_rounded,
                    title: 'Aktivitas',
                    caption: 'langkah',
                    number: CountUpText(
                      value: s.steps,
                      formatter: fmtInt,
                      style: _bigNumber,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Staggered(
            delay: const Duration(milliseconds: 300),
            child: VCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progres hari ini', style: TextStyle(fontWeight: FontWeight.w700, color: VColors.ink)),
                      CountUpText(
                        value: (s.overallProgress * 100).round(),
                        suffix: '%',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: VColors.orange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: s.overallProgress),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => LinearProgressIndicator(
                        value: v,
                        minHeight: 10,
                        backgroundColor: VColors.border,
                        color: VColors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Staggered(
            delay: const Duration(milliseconds: 400),
            child: Column(
              children: [
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Tambah catatan'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Satu layar, tiga jawaban: sudah cukup minum, cukup tidur, dan cukup bergerak?',
                  textAlign: TextAlign.center,
                  style: kMutedStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.title,
    required this.number,
    required this.caption,
  });

  final IconData icon;
  final String title;
  final Widget number;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return VCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: VColors.forest),
          const SizedBox(height: 10),
          Text(title, style: kLabelStyle),
          const SizedBox(height: 2),
          number,
          Text(caption, style: kMutedStyle),
        ],
      ),
    );
  }
}
