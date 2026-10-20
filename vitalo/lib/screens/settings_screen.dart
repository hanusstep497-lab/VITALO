import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';
import 'splash_login_screen.dart';

/// LAYAR 06 - Pengingat & Profil.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickTime(BuildContext context, AppState s, ReminderItem r) async {
    final picked = await showTimePicker(context: context, initialTime: r.time);
    if (picked != null) s.setReminderTime(r, picked);
  }

  void _manageProfile(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kelola profil'),
        content: const Text(
          'Pengeditan profil akan tersedia setelah backend terhubung pada tahap berikutnya.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Tutup')),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      fadeRoute<void>(const SplashLoginScreen()),
      (route) => false,
    );
  }

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
                Text('PENGINGAT & PROFIL', style: kLabelStyle),
                SizedBox(height: 4),
                Text('Pengaturan', style: kTitleStyle),
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
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: VColors.mint,
                      child: Icon(Icons.person_rounded, color: VColors.forest, size: 30),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Profil kesehatan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: VColors.ink)),
                          Text('Tujuan dan preferensi kamu', style: kMutedStyle),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('${s.waterTarget} gelas/hari')),
                    Chip(label: Text('Tidur ${s.sleepTarget.inHours} jam')),
                    Chip(label: Text('${fmtInt(s.stepsTarget)} langkah')),
                  ],
                ),
              ],
            ),
          ),
          ),
          const SizedBox(height: 20),
          const Text('Pengingat aktif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: VColors.ink)),
          const SizedBox(height: 10),
          for (var i = 0; i < s.reminders.length; i++) ...[
            Staggered(
              delay: Duration(milliseconds: 200 + i * 90),
              child: VCard(
                color: s.reminders[i].enabled ? Colors.white : const Color(0xFFE6E9E1),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Icon(
                    s.reminders[i].icon,
                    color: s.reminders[i].enabled ? VColors.forest : VColors.muted,
                  ),
                  title: Text(
                    '${s.reminders[i].label} · ${fmtTime(s.reminders[i].time)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Ketuk untuk ubah jam'),
                  onTap: () => _pickTime(context, s, s.reminders[i]),
                  trailing: Switch(
                    value: s.reminders[i].enabled,
                    activeColor: VColors.teal,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      s.setReminderEnabled(s.reminders[i], v);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          const Text('Akun dan privasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: VColors.ink)),
          const SizedBox(height: 10),
          FilledButton.tonal(
            onPressed: () => _manageProfile(context),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Kelola profil'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => _logout(context),
            child: const Text('Keluar'),
          ),
          const SizedBox(height: 10),
          const Text(
            'Pengingat yang membantu, bukan mengganggu.',
            textAlign: TextAlign.center,
            style: kMutedStyle,
          ),
        ],
      ),
    );
  }
}
