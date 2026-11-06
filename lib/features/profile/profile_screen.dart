import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/responsive.dart';
import '../../data/dummy_data.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/section_title.dart';

/// Data satu pengingat (hanya tampilan, tidak disimpan ke mana pun).
class _Reminder {
  final String title;
  final IconData icon;
  final TimeOfDay time;
  final bool enabled;

  const _Reminder({
    required this.title,
    required this.icon,
    required this.time,
    this.enabled = true,
  });

  _Reminder copyWith({TimeOfDay? time, bool? enabled}) => _Reminder(
        title: title,
        icon: icon,
        time: time ?? this.time,
        enabled: enabled ?? this.enabled,
      );
}

/// Tab Profil: kartu profil, pengingat aktif, dan menu akun.
///
/// Compact = 1 kolom. Medium/expanded atau landscape = 2 kolom
/// (profil kiri, pengingat kanan). Scaffold milik AppShell.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Ruang bawah agar konten tidak tertutup FAB.
  static const double _fabClearance = 96;
  // Lebar minimum agar 2 kolom di landscape tetap muat tanpa overflow.
  static const double _minTwoColumnWidth = 480;
  static const double _singleColumnMaxWidth = 600;
  static const double _twoColumnMaxWidth = 960;

  final List<_Reminder> _reminders = [
    const _Reminder(
      title: 'Minum air',
      icon: Icons.water_drop_rounded,
      time: TimeOfDay(hour: 10, minute: 0),
    ),
    const _Reminder(
      title: 'Tidur',
      icon: Icons.bedtime_rounded,
      time: TimeOfDay(hour: 21, minute: 30),
    ),
    const _Reminder(
      title: 'Jalan sore',
      icon: Icons.directions_walk_rounded,
      time: TimeOfDay(hour: 17, minute: 30),
      enabled: false,
    ),
  ];

  /// Ambil maksimal 2 huruf awal dari nama, mis. "Budi Santoso" -> "BS".
  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void _toggle(int i, bool value) {
    setState(() => _reminders[i] = _reminders[i].copyWith(enabled: value));
  }

  Future<void> _pickTime(int i) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminders[i].time,
      // Format 24 jam agar konsisten dengan teks "10:00" di daftar.
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked == null || !mounted) return;
    setState(() => _reminders[i] = _reminders[i].copyWith(time: picked));
  }

  void _showPlaceholder(String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label: hanya tampilan')));
  }

  Future<void> _confirmLogout() async {
    final ok = await showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: const Text('Keluar dari Vitalo?'),
        content: const Text('Kamu bisa masuk lagi kapan saja.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _ProfileCard(initials: _initials(DummyData.userName));
    final menu = _MenuCard(
      onAccount: () => _showPlaceholder('Akun dan privasi'),
      onManage: () => _showPlaceholder('Kelola profil'),
      onLogout: _confirmLogout,
    );
    final reminders = _RemindersSection(
      reminders: _reminders,
      formatTime: _formatTime,
      onToggle: _toggle,
      onPickTime: _pickTime,
    );

    // Satu kolom: profil, pengingat, menu.
    Widget oneColumn(BuildContext context, BoxConstraints c) => _scroll(
          maxWidth: _singleColumnMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              profile,
              const SizedBox(height: AppSpacing.lg),
              reminders,
              const SizedBox(height: AppSpacing.lg),
              menu,
            ],
          ),
        );

    // Dua kolom: profil + menu di kiri, pengingat di kanan.
    Widget twoColumns(BuildContext context, BoxConstraints c) => _scroll(
          maxWidth: _twoColumnMaxWidth,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    profile,
                    const SizedBox(height: AppSpacing.lg),
                    menu,
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: reminders),
            ],
          ),
        );

    return ResponsiveBuilder(
      // Compact tetap 2 kolom jika landscape dan cukup lebar.
      compact: (context, c) =>
          context.isLandscape && c.maxWidth >= _minTwoColumnWidth
              ? twoColumns(context, c)
              : oneColumn(context, c),
      medium: twoColumns,
      expanded: twoColumns,
    );
  }

  Widget _scroll({required double maxWidth, required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        _fabClearance,
      ),
      child: MaxWidthBox(maxWidth: maxWidth, child: child),
    );
  }
}

/// Kartu profil: avatar, nama, dan keterangan singkat.
class _ProfileCard extends StatelessWidget {
  final String initials;
  const _ProfileCard({required this.initials});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            AppAvatar(initials: initials, radius: 32),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DummyData.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Profil kesehatan - Tujuan dan preferensi kamu',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Daftar "Pengingat aktif" dengan switch dan pemilih waktu.
class _RemindersSection extends StatelessWidget {
  final List<_Reminder> reminders;
  final String Function(TimeOfDay) formatTime;
  final void Function(int index, bool value) onToggle;
  final void Function(int index) onPickTime;

  const _RemindersSection({
    required this.reminders,
    required this.formatTime,
    required this.onToggle,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Pengingat aktif'),
        const SizedBox(height: AppSpacing.sm),
        Card.filled(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Column(
              children: [
                for (var i = 0; i < reminders.length; i++)
                  _ReminderTile(
                    reminder: reminders[i],
                    timeLabel: formatTime(reminders[i].time),
                    onChanged: (v) => onToggle(i, v),
                    onTapTime: () => onPickTime(i),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final _Reminder reminder;
  final String timeLabel;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTapTime;

  const _ReminderTile({
    required this.reminder,
    required this.timeLabel,
    required this.onChanged,
    required this.onTapTime,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    // Hormati pengaturan "kurangi animasi": tampil langsung.
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.normal;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Hanya bagian teks/waktu yang memudar; switch tetap jelas.
          Expanded(
            child: AnimatedOpacity(
              opacity: reminder.enabled ? 1 : 0.45,
              duration: duration,
              curve: AppMotion.curve,
              child: Row(
                children: [
                  Icon(reminder.icon, color: scheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      reminder.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyLarge,
                    ),
                  ),
                  TextButton(
                    // Waktu hanya bisa diubah saat pengingat aktif.
                    onPressed: reminder.enabled ? onTapTime : null,
                    child: Text(timeLabel),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Switch.adaptive(value: reminder.enabled, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Menu "Akun dan privasi", "Kelola profil", dan "Keluar" (hanya tampilan).
class _MenuCard extends StatelessWidget {
  final VoidCallback onAccount;
  final VoidCallback onManage;
  final VoidCallback onLogout;

  const _MenuCard({
    required this.onAccount,
    required this.onManage,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card.filled(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline_rounded),
            title: const Text('Akun dan privasi'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onAccount,
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Kelola profil'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onManage,
          ),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: scheme.error),
            title: Text('Keluar', style: TextStyle(color: scheme.error)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}