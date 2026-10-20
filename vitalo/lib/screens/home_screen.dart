import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';

/// LAYAR 02 - Home Dashboard (ringkasan harian).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onAdd});

  final VoidCallback onAdd;

  static const _days = ['SENIN', 'SELASA', 'RABU', 'KAMIS', 'JUMAT', 'SABTU', 'MINGGU'];

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final day = _days[DateTime.now().weekday - 1];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('$day, HARI INI', style: kLabelStyle),
          const SizedBox(height: 4),
          const Text('Halo, kamu siap?', style: kTitleStyle),
          const SizedBox(height: 20),
          VCard(
            child: Row(
              children: [
                ProgressRing(
                  value: s.waterRatio,
                  size: 96,
                  stroke: 10,
                  color: VColors.teal,
                  child: Text(
                    '${s.waterGlasses}',
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
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.bedtime_rounded,
                  title: 'Tidur',
                  value: fmtDuration(s.sleep),
                  caption: 'Semalam',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  icon: Icons.directions_walk_rounded,
                  title: 'Aktivitas',
                  value: fmtInt(s.steps),
                  caption: 'langkah',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          VCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progres hari ini', style: TextStyle(fontWeight: FontWeight.w700, color: VColors.ink)),
                    Text(
                      '${(s.overallProgress * 100).round()}%',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: VColors.orange),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: s.overallProgress,
                    minHeight: 10,
                    backgroundColor: VColors.border,
                    color: VColors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.title,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final String title;
  final String value;
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
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: VColors.ink),
          ),
          Text(caption, style: kMutedStyle),
        ],
      ),
    );
  }
}
