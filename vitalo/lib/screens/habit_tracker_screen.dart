import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// LAYAR 04 - Pelacak Kebiasaan.
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
          const Text('PELACAK KEBIASAAN', style: kLabelStyle),
          const SizedBox(height: 4),
          const Text('Kebiasaan saya', style: kTitleStyle),
          const SizedBox(height: 8),
          const Text(
            'Pantau kebiasaan sehat, tandai progres harian, dan jaga ritme tanpa terasa rumit.',
            style: kMutedStyle,
          ),
          const SizedBox(height: 20),
          VCard(
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
                      Column(
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
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Target hari ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: VColors.ink)),
          const SizedBox(height: 10),
          for (final h in s.habits) ...[
            VCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: CheckboxListTile(
                value: h.done,
                onChanged: (v) => s.toggleHabit(h, v ?? false),
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: VColors.teal,
                secondary: Icon(h.icon, color: VColors.forest),
                title: Text(
                  h.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: h.done ? VColors.muted : VColors.ink,
                    decoration: h.done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 6),
          VCard(
            color: VColors.forest,
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, color: VColors.orange, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Streak aktif · ${s.streak} hari',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ],
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
