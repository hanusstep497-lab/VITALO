import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// LAYAR 04 - Pelacak Kebiasaan.
/// Animasi: lingkaran hari "pop" berurutan, kartu kebiasaan berubah warna
/// + coretan saat dicentang, ikon streak berdenyut, badge muncul.
class HabitTrackerScreen extends StatelessWidget {
  const HabitTrackerScreen({super.key});

  static const _dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Staggered(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PELACAK KEBIASAAN', style: kLabelStyle),
                SizedBox(height: 4),
                Text('Kebiasaan saya', style: kTitleStyle),
                SizedBox(height: 8),
                Text(
                  'Pantau kebiasaan sehat, tandai progres harian, dan jaga ritme tanpa terasa rumit.',
                  style: kMutedStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Staggered(
            delay: const Duration(milliseconds: 100),
            child: VCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Konsistensi minggu ini', style: kLabelStyle),
                  const SizedBox(height: 4),
                  Text(
                    '${s.doneDays} dari 7 hari',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: VColors.ink),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < 7; i++)
                        Staggered(
                          delay: Duration(milliseconds: 250 + i * 70),
                          slide: Offset.zero,
                          scaleFrom: 0.4,
                          duration: const Duration(milliseconds: 450),
                          child: Column(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: s.weekDone[i] ? VColors.teal : VColors.bg,
                                  border: Border.all(
                                    color: s.weekDone[i] ? VColors.teal : VColors.border,
                                  ),
                                ),
                                child: s.weekDone[i]
                                    ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(height: 6),
                              Text(_dayLabels[i], style: const TextStyle(fontSize: 12, color: VColors.muted)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Staggered(
            delay: Duration(milliseconds: 200),
            child: Text('Target hari ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: VColors.ink)),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < s.habits.length; i++) ...[
            Staggered(
              delay: Duration(milliseconds: 250 + i * 80),
              child: _HabitTile(item: s.habits[i], state: s),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 6),
          Staggered(
            delay: const Duration(milliseconds: 650),
            child: VCard(
              color: VColors.forest,
              child: Row(
                children: [
                  const Pulse(
                    child: Icon(Icons.local_fire_department_rounded, color: VColors.orange, size: 32),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Streak aktif · ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  CountUpText(
                    value: s.streak,
                    suffix: ' hari',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Staggered(
            delay: const Duration(milliseconds: 750),
            child: VCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Badge', style: kLabelStyle),
                  const SizedBox(height: 10),
                  if (s.badges.isEmpty)
                    const Text('Belum ada badge. Capai target air 8 gelas untuk mendapatkannya!', style: kMutedStyle)
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final b in s.badges)
                          Chip(
                            avatar: const Icon(Icons.emoji_events_rounded, color: VColors.orange, size: 18),
                            label: Text(b),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Kebiasaan kecil. Progres yang terlihat.',
            textAlign: TextAlign.center,
            style: kMutedStyle,
          ),
        ],
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  const _HabitTile({required this.item, required this.state});

  final HabitItem item;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return VCard(
      color: item.done ? VColors.mint : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: CheckboxListTile(
        value: item.done,
        onChanged: (v) {
          HapticFeedback.selectionClick();
          state.toggleHabit(item, v ?? false);
        },
        controlAffinity: ListTileControlAffinity.trailing,
        activeColor: VColors.forest,
        secondary: Icon(item.icon, color: VColors.forest),
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: item.done ? VColors.muted : VColors.ink,
            decoration: item.done ? TextDecoration.lineThrough : TextDecoration.none,
          ),
          child: Text(item.title),
        ),
      ),
    );
  }
}
