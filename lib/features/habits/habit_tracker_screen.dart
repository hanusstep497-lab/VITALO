import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/habit_tile.dart';
import '../../widgets/section_title.dart';
import '../../widgets/stat_card.dart';

/// Tab Kebiasaan: ringkasan (selesai & streak) + daftar kebiasaan hari ini.
/// Ketuk baris untuk menandai selesai / belum.
class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  /// Target streak mingguan untuk progress kartu streak.
  static const int _streakTarget = 7;

  /// Status selesai tiap kebiasaan; diawali dari DummyData.
  final List<bool> _done = [for (final h in DummyData.habits) h.done];

  void _setDone(int index, bool value) => setState(() => _done[index] = value);

  void _reset() => setState(() {
        for (var i = 0; i < _done.length; i++) {
          _done[i] = false;
        }
      });

  @override
  Widget build(BuildContext context) {
    final habits = DummyData.habits;
    final total = habits.length;
    final doneCount = _done.where((d) => d).length;

    return ListView(
      // Padding bawah ekstra supaya baris terakhir tidak tertutup tombol Catat.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        96,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StatCard(
                title: 'Selesai',
                value: '$doneCount',
                unit: '/ $total',
                icon: Icons.task_alt_rounded,
                progress: total == 0 ? 0 : doneCount / total,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: StatCard(
                title: 'Streak',
                value: '${DummyData.streakDays}',
                unit: 'hari',
                icon: Icons.local_fire_department_rounded,
                progress: DummyData.streakDays / _streakTarget,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionTitle(
          'Kebiasaan hari ini',
          actionLabel: 'Reset',
          onAction: _reset,
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < total; i++) ...[
                if (i > 0) const Divider(height: 1, indent: AppSpacing.md),
                HabitTile(
                  title: habits[i].title,
                  subtitle: _done[i] ? 'Selesai' : 'Belum selesai',
                  icon: habits[i].icon,
                  done: _done[i],
                  onChanged: (value) => _setDone(i, value),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}