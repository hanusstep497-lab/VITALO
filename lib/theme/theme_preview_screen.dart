import 'package:flutter/material.dart';

import 'app_motion.dart';
import 'app_spacing.dart';
import 'app_theme.dart';

/// Jalankan halaman ini sendiri (tidak ada di routes):
/// flutter run -t lib/theme/theme_preview_screen.dart
void main() => runApp(const _PreviewApp());

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vitalo - Pratinjau Tema',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const ThemePreviewScreen(),
    );
  }
}

/// Pratinjau tema: swatch warna, skala tipografi, komponen, dan switch terang/gelap.
class ThemePreviewScreen extends StatefulWidget {
  const ThemePreviewScreen({super.key});

  @override
  State<ThemePreviewScreen> createState() => _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends State<ThemePreviewScreen> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    // Jika animasi dimatikan sistem, ganti tema langsung.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedTheme(
      data: _dark ? AppTheme.dark : AppTheme.light,
      duration: reduceMotion ? Duration.zero : AppMotion.normal,
      curve: AppMotion.curve,
      child: _PreviewBody(
        dark: _dark,
        onDarkChanged: (value) => setState(() => _dark = value),
      ),
    );
  }
}

class _PreviewBody extends StatefulWidget {
  const _PreviewBody({required this.dark, required this.onDarkChanged});

  final bool dark;
  final ValueChanged<bool> onDarkChanged;

  @override
  State<_PreviewBody> createState() => _PreviewBodyState();
}

class _PreviewBodyState extends State<_PreviewBody> {
  static const _chipNames = ['Air', 'Tidur', 'Gerak'];

  final Set<String> _selectedChips = {'Air'};
  int _navIndex = 0;

  void _showSnackBar() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Catatan tersimpan'),
          action: SnackBarAction(label: 'Urungkan', onPressed: () {}),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pratinjau Tema')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          Card(
            child: SwitchListTile(
              secondary: Icon(widget.dark ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Mode gelap'),
              subtitle: const Text('Ganti tema terang / gelap'),
              value: widget.dark,
              onChanged: widget.onDarkChanged,
            ),
          ),
          const _Section(title: 'Warna', child: _PaletteGrid()),
          const _Section(title: 'Tipografi', child: _TypeScale()),
          _Section(title: 'Kartu & progress', child: _cardDemo()),
          _Section(title: 'Warna kebiasaan', child: _habitDemo()),
          _Section(title: 'Tombol', child: _buttonsDemo()),
          _Section(title: 'Input', child: _inputsDemo()),
          _Section(title: 'Chip', child: _chipsDemo()),
          _Section(
            title: 'SnackBar',
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonal(
                onPressed: _showSnackBar,
                child: const Text('Tampilkan SnackBar'),
              ),
            ),
          ),
          _Section(title: 'NavigationBar', child: _navDemo()),
        ],
      ),
    );
  }

  // Kartu statistik: angka besar + progress memakai warna semantik air.
  Widget _cardDemo() {
    final theme = Theme.of(context);
    final habit = HabitColors.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Minum air', style: theme.textTheme.titleMedium),
            Text('Target 8 gelas', style: theme.textTheme.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '5',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: habit.water,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text('gelas', style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: 5 / 8,
              minHeight: AppSpacing.sm,
              color: habit.water,
              backgroundColor: habit.waterContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ],
        ),
      ),
    );
  }

  // Tiga warna semantik: air, tidur, aktivitas.
  Widget _habitDemo() {
    final habit = HabitColors.of(context);
    Widget tile(String label, IconData icon, Color accent, Color bg, Color fg) {
      return Expanded(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Icon(icon, color: accent),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: fg),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tile('Air', Icons.water_drop_outlined, habit.water,
            habit.waterContainer, habit.onWaterContainer),
        const SizedBox(width: AppSpacing.sm),
        tile('Tidur', Icons.bedtime_outlined, habit.sleep,
            habit.sleepContainer, habit.onSleepContainer),
        const SizedBox(width: AppSpacing.sm),
        tile('Gerak', Icons.directions_walk, habit.activity,
            habit.activityContainer, habit.onActivityContainer),
      ],
    );
  }

  Widget _buttonsDemo() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        FilledButton(onPressed: () {}, child: const Text('Catat')),
        FilledButton.tonal(onPressed: () {}, child: const Text('Tonal')),
        OutlinedButton(onPressed: () {}, child: const Text('Batal')),
        TextButton(onPressed: () {}, child: const Text('Lewati')),
        const FilledButton(onPressed: null, child: Text('Nonaktif')),
      ],
    );
  }

  Widget _inputsDemo() {
    return const Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Gelas air',
            helperText: 'Contoh: 2',
          ),
        ),
        SizedBox(height: AppSpacing.md),
        TextField(
          decoration: InputDecoration(
            labelText: 'Jam tidur',
            errorText: 'Isi antara 0 dan 24 jam',
          ),
        ),
      ],
    );
  }

  Widget _chipsDemo() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final name in _chipNames)
          FilterChip(
            label: Text(name),
            selected: _selectedChips.contains(name),
            onSelected: (value) => setState(() {
              if (value) {
                _selectedChips.add(name);
              } else {
                _selectedChips.remove(name);
              }
            }),
          ),
        ActionChip(
          avatar: const Icon(Icons.add),
          label: const Text('Tambah'),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _navDemo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Kebiasaan',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insight',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Judul seksi + isi, dengan jarak konsisten.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

/// Rasio kontras WCAG antara dua warna.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

class _SwatchData {
  const _SwatchData(this.name, this.bg, this.fg);

  final String name;
  final Color bg;
  final Color fg;
}

/// Swatch peran warna + rasio kontras teks di atasnya (target AA >= 4.5:1).
class _PaletteGrid extends StatelessWidget {
  const _PaletteGrid();

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final h = HabitColors.of(context);
    // Untuk warna aksen kebiasaan, teks di atasnya = warna surface.
    final items = <_SwatchData>[
      _SwatchData('primary', s.primary, s.onPrimary),
      _SwatchData('primaryContainer', s.primaryContainer, s.onPrimaryContainer),
      _SwatchData('secondary', s.secondary, s.onSecondary),
      _SwatchData(
          'secondaryContainer', s.secondaryContainer, s.onSecondaryContainer),
      _SwatchData('tertiary', s.tertiary, s.onTertiary),
      _SwatchData(
          'tertiaryContainer', s.tertiaryContainer, s.onTertiaryContainer),
      _SwatchData('error', s.error, s.onError),
      _SwatchData('errorContainer', s.errorContainer, s.onErrorContainer),
      _SwatchData('surface', s.surface, s.onSurface),
      _SwatchData('surfaceContainerLow', s.surfaceContainerLow, s.onSurface),
      _SwatchData('onSurfaceVariant', s.surface, s.onSurfaceVariant),
      _SwatchData('water', h.water, s.surface),
      _SwatchData('waterContainer', h.waterContainer, h.onWaterContainer),
      _SwatchData('sleep', h.sleep, s.surface),
      _SwatchData('sleepContainer', h.sleepContainer, h.onSleepContainer),
      _SwatchData('activity', h.activity, s.surface),
      _SwatchData(
          'activityContainer', h.activityContainer, h.onActivityContainer),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - AppSpacing.sm) / 2;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final item in items)
              SizedBox(width: width, child: _Swatch(item)),
          ],
        );
      },
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.data);

  final _SwatchData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = _contrast(data.bg, data.fg);
    // Garis tepi hanya untuk swatch yang menyatu dengan latar halaman.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: data.bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(color: data.fg),
            ),
            Text(
              '${ratio.toStringAsFixed(1)}:1'
              '${ratio >= 4.5 ? ' lulus AA' : ' di bawah AA'}',
              style: theme.textTheme.labelMedium?.copyWith(color: data.fg),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeSpec {
  const _TypeSpec(this.name, this.style, this.sample, [this.role]);

  final String name;
  final TextStyle? style;
  final String sample;
  final String? role;
}

/// Seluruh skala tipografi M3; lima gaya utama Vitalo diberi keterangan peran.
class _TypeScale extends StatelessWidget {
  const _TypeScale();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    const number = '4.280';
    const heading = 'Ringkasan hari ini';
    const body = 'Kamu sudah minum 5 dari 8 gelas hari ini.';
    final specs = <_TypeSpec>[
      _TypeSpec('displayLarge', t.displayLarge, number),
      _TypeSpec('displayMedium', t.displayMedium, number),
      _TypeSpec('displaySmall', t.displaySmall, number, 'angka besar dashboard'),
      _TypeSpec('headlineLarge', t.headlineLarge, heading),
      _TypeSpec('headlineMedium', t.headlineMedium, heading),
      _TypeSpec('headlineSmall', t.headlineSmall, heading, 'judul layar'),
      _TypeSpec('titleLarge', t.titleLarge, 'Insight mingguan'),
      _TypeSpec('titleMedium', t.titleMedium, 'Minum air', 'judul kartu'),
      _TypeSpec('titleSmall', t.titleSmall, 'Minum air'),
      _TypeSpec('bodyLarge', t.bodyLarge, body),
      _TypeSpec('bodyMedium', t.bodyMedium, body, 'isi'),
      _TypeSpec('bodySmall', t.bodySmall, body),
      _TypeSpec('labelLarge', t.labelLarge, 'Catat'),
      _TypeSpec('labelMedium', t.labelMedium, 'Target 8 gelas',
          'keterangan / label'),
      _TypeSpec('labelSmall', t.labelSmall, 'Target 8 gelas'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final spec in specs) ...[
              Text(
                '${spec.name} - ${spec.style?.fontSize?.toStringAsFixed(0)} sp'
                ' - w${spec.style?.fontWeight?.value}'
                '${spec.role == null ? '' : ' - ${spec.role}'}',
                style: t.labelMedium,
              ),
              Text(
                spec.sample,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: spec.style,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}