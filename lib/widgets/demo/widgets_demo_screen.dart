import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../app_avatar.dart';
import '../habit_tile.dart';
import '../section_title.dart';
import '../stat_card.dart';

/// Entry point khusus demo (TIDAK didaftarkan di `routes.dart`).
///
/// Jalankan untuk screenshot:
/// `flutter run -t lib/widgets/demo/widgets_demo_screen.dart`
void main() => runApp(const _WidgetsDemoApp());

class _WidgetsDemoApp extends StatelessWidget {
  const _WidgetsDemoApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vitalo - Widgets Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const WidgetsDemoScreen(),
    );
  }
}

/// Halaman demo T3b: menampilkan tiap widget reusable dengan minimal
/// 3 variasi parameter. Semua data di sini literal (bukan `DummyData`)
/// untuk membuktikan widget tidak terikat sumber data tertentu.
class WidgetsDemoScreen extends StatefulWidget {
  const WidgetsDemoScreen({super.key});

  @override
  State<WidgetsDemoScreen> createState() => _WidgetsDemoScreenState();
}

class _WidgetsDemoScreenState extends State<WidgetsDemoScreen> {
  static const int _waterTarget = 8;

  int _glasses = 5;
  bool _walk = true;
  bool _water = false;
  bool _stretch = false;

  void _addGlass() =>
      setState(() => _glasses = _glasses >= _waterTarget ? 0 : _glasses + 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widgets Demo - T3b')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ---------------- SectionTitle ----------------
          const _Caption('SectionTitle - 3 variasi'),
          const SectionTitle('Hari ini'),
          SectionTitle(
            'Kebiasaan',
            actionLabel: 'Lihat semua',
            onAction: () => _snack(context, 'Lihat semua ditekan'),
          ),
          const SectionTitle(
            'Judul yang sangat panjang sekali untuk menguji pemotongan teks',
            actionLabel: 'Aksi',
          ),
          const _Gap(),

          // ---------------- StatCard ----------------
          const _Caption('StatCard - progres animasi (ketuk kartu air)'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: StatCard(
                  title: 'Air minum',
                  value: '$_glasses',
                  unit: 'gelas',
                  icon: Icons.water_drop_outlined,
                  progress: _glasses / _waterTarget,
                  onTap: _addGlass,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: StatCard(
                  title: 'Streak',
                  value: '4',
                  unit: 'hari',
                  icon: Icons.local_fire_department_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: StatCard(
                  title: 'Tidur',
                  value: '7j 20m',
                  icon: Icons.bedtime_outlined,
                  progress: 0.92,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatCard(
                  title: 'Target lewat',
                  value: '12.480',
                  unit: 'langkah',
                  icon: Icons.directions_walk,
                  progress: 1.4, // di-clamp ke 1.0
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _Caption('StatCard - uji lebar 160 px (tanpa overflow)'),
          const Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 160,
              child: StatCard(
                title: 'Langkah harian kamu',
                value: '12.480',
                unit: 'langkah',
                icon: Icons.directions_walk,
                progress: 0.85,
              ),
            ),
          ),
          const _Gap(),

          // ---------------- HabitTile ----------------
          const _Caption('HabitTile - ketuk untuk toggle'),
          HabitTile(
            title: 'Minum air 8 gelas',
            subtitle: 'Target harian',
            icon: Icons.water_drop_outlined,
            done: _water,
            onChanged: (v) => setState(() => _water = v),
          ),
          HabitTile(
            title: 'Berjalan 20 menit',
            subtitle: 'Sudah selesai pagi ini',
            icon: Icons.directions_walk,
            done: _walk,
            onChanged: (v) => setState(() => _walk = v),
          ),
          HabitTile(
            title: 'Stretching',
            icon: Icons.self_improvement,
            done: _stretch,
            onChanged: (v) => setState(() => _stretch = v),
          ),
          const HabitTile(
            title: 'Read-only (onChanged null)',
            subtitle: 'Tidak bisa diketuk',
            icon: Icons.lock_outline,
            done: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _Caption('HabitTile - uji lebar 160 px'),
          const Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 160,
              child: HabitTile(
                title: 'Tidur cukup tujuh jam setiap malam',
                subtitle: 'Sebelum pukul 23.00',
                icon: Icons.bedtime_outlined,
                done: true,
              ),
            ),
          ),
          const _Gap(),

          // ---------------- AppAvatar ----------------
          const _Caption('AppAvatar - radius & inisial berbeda'),
          const Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppAvatar(initials: 'N', radius: 16),
              AppAvatar(initials: 'NH'), // radius default 24
              AppAvatar(initials: 'AB', radius: 40),
              AppAvatar(initials: 'WXYZ', radius: 28), // inisial panjang
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _Caption('AppAvatar - imageAsset gagal dimuat -> inisial'),
          const Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              AppAvatar(
                imageAsset: 'assets/images/tidak_ada.png',
                initials: 'VT',
                radius: 32,
              ),
              AppAvatar(
                imageAsset: 'assets/images/tidak_ada.png',
                initials: 'VL',
                radius: 20,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Caption extends StatelessWidget {
  final String text;
  const _Caption(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Gap extends StatelessWidget {
  const _Gap();

  @override
  Widget build(BuildContext context) => const SizedBox(height: AppSpacing.lg);
}