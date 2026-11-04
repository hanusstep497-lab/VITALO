import 'package:flutter/material.dart';

import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';

// ---------------------------------------------------------------------------
// Konstanta ukuran (di luar AppSpacing karena bukan "jarak", melainkan ukuran
// komponen). Semua target sentuh >= 48 dp.
// ---------------------------------------------------------------------------
const double _bigTap = 56; // tombol - / + stepper
const double _saveHeight = 56; // tombol "Simpan catatan"
const double _quickAddHeight = 64; // tombol "+1 gelas"
const double _radius = 24; // sudut panel & kartu pilihan
const double _contentMaxWidth = 480; // batas lebar konten di layar lebar

const double _sleepPanelHeight = 176;
const double _waterPanelHeight = 240;
const double _activityPanelHeight = 136;
const double _choiceHeight = 96;
const double _gridChoiceHeight = 88;

// Batas & langkah nilai.
const int _sleepStep = 15; // menit
const int _sleepMax = 16 * 60;
const int _activityStep = 5; // menit
const int _activityMin = 5;
const int _activityMax = 300;
const int _glassMax = 20;

class _Option {
  const _Option(this.label, this.icon);
  final String label;
  final IconData icon;
}

const _qualities = [
  _Option('Kurang', Icons.sentiment_dissatisfied_rounded),
  _Option('Cukup', Icons.sentiment_neutral_rounded),
  _Option('Nyenyak', Icons.sentiment_very_satisfied_rounded),
];

const _activities = [
  _Option('Jalan', Icons.directions_walk_rounded),
  _Option('Lari', Icons.directions_run_rounded),
  _Option('Sepeda', Icons.directions_bike_rounded),
  _Option('Lainnya', Icons.more_horiz_rounded),
];

/// Layar 03 - Tambah Catatan. Tiga tab cepat: Tidur | Air | Aktivitas.
///
/// State bersifat lokal (setState) dan sengaja berada di State layar ini
/// (bukan di tiap tab) supaya nilai tidak hilang ketika pengguna berpindah
/// tab. Data tidak disimpan ke mana pun; "Simpan catatan" hanya menutup
/// layar dengan hasil `true`.
class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  int _sleepMinutes = 7 * 60 + 20; // 7j 20m, sesuai proposal
  int _quality = 1; // indeks _qualities; "Cukup" sebagai default
  int _glasses = 0;
  int _activityType = 0; // indeks _activities
  int _activityMinutes = 30;

  static int _clampInt(int v, int lo, int hi) => v < lo ? lo : (v > hi ? hi : v);

  static String _formatSleep(int minutes) => '${minutes ~/ 60}j ${minutes % 60}m';

  void _stepSleep(int delta) => setState(
        () => _sleepMinutes = _clampInt(_sleepMinutes + delta, 0, _sleepMax),
      );

  void _stepActivity(int delta) => setState(
        () => _activityMinutes =
            _clampInt(_activityMinutes + delta, _activityMin, _activityMax),
      );

  void _stepGlasses(int delta) => setState(
        () => _glasses = _clampInt(_glasses + delta, 0, _glassMax),
      );

  void _save() => Navigator.pop(context, true);

  @override
  Widget build(BuildContext context) {
    // Jika pengguna mematikan animasi, semua transisi tampil langsung.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final anim = reduceMotion ? Duration.zero : AppMotion.fast;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Tutup',
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Tambah catatan'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tidur'),
              Tab(text: 'Air'),
              Tab(text: 'Aktivitas'),
            ],
          ),
        ),
        // Satu-satunya Column "struktural": isi tab (Expanded) di atas,
        // tombol simpan menempel di bawah.
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _sleepTab(anim),
                  _waterTab(anim),
                  _activityTab(anim),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Container(
                    constraints:
                        const BoxConstraints(maxWidth: _contentMaxWidth),
                    child: SizedBox(
                      width: double.infinity,
                      height: _saveHeight,
                      child: FilledButton(
                        onPressed: _save,
                        child: const Text('Simpan catatan'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Tab Tidur
  // -------------------------------------------------------------------------
  Widget _sleepTab(Duration anim) {
    return _TabPage(
      children: [
        _StepperPanel(
          caption: 'Tidur semalam',
          value: _formatSleep(_sleepMinutes),
          height: _sleepPanelHeight,
          large: true,
          minusTooltip: 'Kurangi $_sleepStep menit',
          plusTooltip: 'Tambah $_sleepStep menit',
          onMinus: _sleepMinutes > 0 ? () => _stepSleep(-_sleepStep) : null,
          onPlus: _sleepMinutes < _sleepMax ? () => _stepSleep(_sleepStep) : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        const _Heading('Bagaimana kualitas tidurmu?'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (var i = 0; i < _qualities.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ChoiceCard(
                  option: _qualities[i],
                  selected: _quality == i,
                  minHeight: _choiceHeight,
                  duration: anim,
                  onTap: () => setState(() => _quality = i),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab Air
  // -------------------------------------------------------------------------
  Widget _waterTab(Duration anim) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return _TabPage(
      children: [
        Container(
          height: _waterPanelHeight,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Text(
                    'Minum kali ini',
                    style: text.titleMedium
                        ?.copyWith(color: scheme.onPrimaryContainer),
                  ),
                ),
              ),
              // Angka besar tepat di tengah panel; berganti dengan
              // fade + scale setiap kali bertambah/berkurang.
              Center(
                child: AnimatedSwitcher(
                  duration: anim,
                  switchInCurve: AppMotion.curve,
                  switchOutCurve: AppMotion.curve,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: Text(
                    '$_glasses',
                    key: ValueKey<int>(_glasses),
                    style: text.displayLarge?.copyWith(
                      fontSize: 96,
                      fontWeight: FontWeight.w700,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    'gelas',
                    style: text.titleLarge
                        ?.copyWith(color: scheme.onPrimaryContainer),
                  ),
                ),
              ),
              // Koreksi cepat bila salah ketuk.
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: IconButton.filledTonal(
                    onPressed: _glasses > 0 ? () => _stepGlasses(-1) : null,
                    tooltip: 'Kurangi 1 gelas',
                    icon: const Icon(Icons.remove_rounded),
                    style: IconButton.styleFrom(
                      fixedSize: const Size.square(_bigTap),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: _quickAddHeight,
          child: FilledButton.icon(
            onPressed: _glasses < _glassMax ? () => _stepGlasses(1) : null,
            icon: const Icon(Icons.water_drop_rounded),
            label: const Text('+1 gelas'),
            style: FilledButton.styleFrom(textStyle: text.titleLarge),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Tab Aktivitas
  // -------------------------------------------------------------------------
  Widget _activityTab(Duration anim) {
    return _TabPage(
      children: [
        const _Heading('Jenis aktivitas'),
        const SizedBox(height: AppSpacing.sm),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisExtent: _gridChoiceHeight,
          ),
          children: [
            for (var i = 0; i < _activities.length; i++)
              _ChoiceCard(
                option: _activities[i],
                selected: _activityType == i,
                minHeight: _gridChoiceHeight,
                duration: anim,
                onTap: () => setState(() => _activityType = i),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _StepperPanel(
          caption: 'Durasi aktivitas',
          value: '$_activityMinutes menit',
          height: _activityPanelHeight,
          large: false,
          minusTooltip: 'Kurangi $_activityStep menit',
          plusTooltip: 'Tambah $_activityStep menit',
          onMinus: _activityMinutes > _activityMin
              ? () => _stepActivity(-_activityStep)
              : null,
          onPlus: _activityMinutes < _activityMax
              ? () => _stepActivity(_activityStep)
              : null,
        ),
      ],
    );
  }
}

// ===========================================================================
// Widget privat
// ===========================================================================

/// Kerangka satu halaman tab: scroll (jaga-jaga layar pendek), padding
/// seragam, konten dibatasi lebarnya dan ditempel di atas-tengah.
class _TabPage extends StatelessWidget {
  const _TabPage({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// Judul kecil rata kiri di dalam Column yang meregang.
class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

/// Panel berdekorasi: nilai besar di tengah, tombol - di kiri, + di kanan.
/// Disusun dengan Stack + Align/Center (bukan Row) agar nilai selalu tepat
/// di tengah berapa pun lebar tombolnya.
class _StepperPanel extends StatelessWidget {
  const _StepperPanel({
    required this.caption,
    required this.value,
    required this.height,
    required this.large,
    required this.minusTooltip,
    required this.plusTooltip,
    required this.onMinus,
    required this.onPlus,
  });

  final String caption;
  final String value;
  final double height;
  final bool large;
  final String minusTooltip;
  final String plusTooltip;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  // Ruang kiri/kanan agar teks tidak menabrak tombol.
  static const double _inset = _bigTap + AppSpacing.sm * 2;

  Widget _stepButton(IconData icon, String tooltip, VoidCallback? onPressed) {
    return IconButton.filled(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      iconSize: 28,
      style: IconButton.styleFrom(fixedSize: const Size.square(_bigTap)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final valueStyle = (large ? text.displayMedium : text.headlineLarge)
        ?.copyWith(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                caption,
                style:
                    text.titleMedium?.copyWith(color: scheme.onPrimaryContainer),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _inset),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value, style: valueStyle),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: _stepButton(Icons.remove_rounded, minusTooltip, onMinus),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _stepButton(Icons.add_rounded, plusTooltip, onPlus),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu pilihan besar. Gaya (warna, border) beranimasi lewat
/// AnimatedContainer saat [selected] berubah.
class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.option,
    required this.selected,
    required this.minHeight,
    required this.duration,
    required this.onTap,
  });

  final _Option option;
  final bool selected;
  final double minHeight;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final fg = selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: duration,
          curve: AppMotion.curve,
          constraints: BoxConstraints(minHeight: minHeight),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primaryContainer
                : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(_radius),
            // Lebar border tetap 2 dp agar ukuran kartu tidak melompat.
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(option.icon, size: 32, color: fg),
              const SizedBox(height: AppSpacing.xs),
              Text(
                option.label,
                style: text.titleMedium?.copyWith(
                  color: fg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}