import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/section_title.dart';

/// Layar 05 - Insight Progres (T6b).
///
/// Tab screen: tanpa Scaffold (Scaffold dimiliki `AppShell`), scrollable,
/// dengan padding bawah 96 agar konten terakhir tidak tertutup FAB "Catat".
///
/// Susunan (atas ke bawah):
/// 1. Kartu hero  -> Stack + Positioned (gradient, badge, cincin progres)
/// 2. Bar chart   -> Row berisi 7 Expanded
/// 3. Pola        -> PageView (carousel) + indikator titik AnimatedContainer
/// 4. Badge       -> GridView.count 3 kolom
/// 5. Tombol "Lihat semua insight" (hanya tampilan)
///
/// Aturan animasi: semuanya satu kali saja (tidak ada yang berulang) dan
/// total animasi masuk <= 600 ms. Animasi tidak memblokir sentuhan, jadi
/// pengguna bisa langsung berinteraksi.
class InsightScreen extends StatelessWidget {
  const InsightScreen({super.key});

  static const double _bottomPadding = 96;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        _bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Kartu hero.
          const _HeroCard(),
          const SizedBox(height: AppSpacing.lg),

          // 2. Mini bar chart 7 hari.
          const SectionTitle('Skor 7 hari'),
          const SizedBox(height: AppSpacing.sm),
          const _WeeklyBarChart(),
          const SizedBox(height: AppSpacing.lg),

          // 3. Carousel pola.
          const SectionTitle('Pola yang terlihat'),
          const SizedBox(height: AppSpacing.sm),
          const _PatternCarousel(),
          const SizedBox(height: AppSpacing.lg),

          // 4. Grid badge.
          const SectionTitle('Badge'),
          const SizedBox(height: AppSpacing.sm),
          const _BadgeGrid(),
          const SizedBox(height: AppSpacing.lg),

          // 5. Tombol bawah (hanya tampilan, belum ada tujuan).
          FilledButton.tonalIcon(
            onPressed: () {},
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Lihat semua insight'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper bersama
// ---------------------------------------------------------------------------

const List<String> _daysShort = [
  'Sen',
  'Sel',
  'Rab',
  'Kam',
  'Jum',
  'Sab',
  'Min',
];

const List<String> _daysFull = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

/// Jika pengguna mematikan animasi sistem, semua animasi dilewati.
bool _reduceMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context);

/// Indeks hari dengan skor tertinggi.
int _bestDayIndex(List<double> scores) {
  var best = 0;
  for (var i = 1; i < scores.length; i++) {
    if (scores[i] > scores[best]) best = i;
  }
  return best;
}

/// Faktor skala teks (>= 1) untuk menambah tinggi area berukuran tetap
/// agar tidak overflow saat pengguna memperbesar ukuran font.
double _textScaleFactor(BuildContext context) {
  final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
  return scale < 1 ? 1 : scale;
}

// ---------------------------------------------------------------------------
// 1. Kartu hero: Stack + Positioned
// ---------------------------------------------------------------------------

/// Latar gradient dari colorScheme, teks + angka besar "+23%", badge kecil
/// di pojok kanan atas (Positioned), dan cincin progres di kanan bawah
/// (Positioned) yang terisi satu kali dengan animasi.
class _HeroCard extends StatelessWidget {
  const _HeroCard();

  static const String _growth = '+23%';
  static const double _ringSize = 84;
  static const Duration _entrance = Duration(milliseconds: 600);

  /// Rata-rata skor 7 hari, dipakai sebagai isi cincin.
  static double get _average {
    final scores = DummyData.weeklyScore;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final onHero = scheme.onPrimary;
    final average = _average;
    final reduce = _reduceMotion(context);

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: 'Kebiasaan lebih konsisten, naik 23 persen dalam 7 hari '
          'terakhir. Rata-rata skor ${(average * 100).round()} persen.',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        child: Stack(
          children: [
            // Lapisan 1: latar gradient memenuhi kartu.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [scheme.primary, scheme.tertiary],
                  ),
                ),
              ),
            ),

            // Lapisan 2: teks. Padding kanan menyisakan ruang untuk cincin,
            // padding atas menyisakan ruang untuk badge.
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 176),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  52,
                  _ringSize + AppSpacing.md * 2,
                  AppSpacing.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kebiasaan lebih konsisten',
                      style: text.titleMedium?.copyWith(
                        color: onHero,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _growth,
                        maxLines: 1,
                        style: text.displaySmall?.copyWith(
                          color: onHero,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lapisan 3: badge kecil di pojok kanan atas.
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: onHero.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 14, color: onHero),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '7 hari terakhir',
                      style: text.labelSmall?.copyWith(
                        color: onHero,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lapisan 4: cincin progres di kanan bawah.
            Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              width: _ringSize,
              height: _ringSize,
              child: TweenAnimationBuilder<double>(
                // Dipanggil sekali saat pertama tampil; `end` tidak berubah
                // sehingga tidak berulang.
                tween: Tween<double>(begin: reduce ? average : 0, end: average),
                duration: reduce ? Duration.zero : _entrance,
                curve: AppMotion.curve,
                builder: (context, value, _) => Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        color: onHero,
                        backgroundColor: onHero.withValues(alpha: 0.25),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: FittedBox(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(value * 100).round()}%',
                              style: text.titleLarge?.copyWith(
                                color: onHero,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'skor',
                              style: text.labelSmall?.copyWith(color: onHero),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Mini bar chart 7 hari: Row berisi 7 Expanded
// ---------------------------------------------------------------------------

/// Satu TweenAnimationBuilder (0 -> 1, 600 ms) menggerakkan semua batang;
/// tiap batang memakai [Interval] sendiri sehingga tumbuh berurutan:
/// jeda antar batang 50 ms, durasi tumbuh 300 ms, jadi batang terakhir
/// selesai tepat di (7 - 1) * 50 + 300 = 600 ms.
class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart();

  static const double _trackHeight = 120;
  static const double _barWidth = 24;
  static const int _staggerMs = 50;
  static const int _growMs = 300;

  @override
  Widget build(BuildContext context) {
    final scores = DummyData.weeklyScore;
    final count = scores.length;
    final totalMs = (count - 1) * _staggerMs + _growMs;
    final best = _bestDayIndex(scores);
    final reduce = _reduceMotion(context);

    final summary = StringBuffer('Skor kebiasaan 7 hari terakhir. ');
    for (var i = 0; i < count; i++) {
      final day = i < _daysFull.length ? _daysFull[i] : 'Hari ${i + 1}';
      summary.write('$day ${(scores[i] * 100).round()} persen. ');
    }

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: summary.toString(),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: reduce ? 1 : 0, end: 1),
            duration: reduce ? Duration.zero : Duration(milliseconds: totalMs),
            builder: (context, t, _) => Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < count; i++)
                  Expanded(
                    child: _Bar(
                      score: scores[i],
                      progress: Interval(
                        i * _staggerMs / totalMs,
                        (i * _staggerMs + _growMs) / totalMs,
                        curve: AppMotion.curve,
                      ).transform(t),
                      label: i < _daysShort.length ? _daysShort[i] : '',
                      highlight: i == best,
                      trackHeight: _trackHeight,
                      barWidth: _barWidth,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.score,
    required this.progress,
    required this.label,
    required this.highlight,
    required this.trackHeight,
    required this.barWidth,
  });

  final double score;
  final double progress; // 0..1, sudah termasuk stagger dan curve
  final String label;
  final bool highlight;
  final double trackHeight;
  final double barWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(8);
    final barHeight =
        (trackHeight * score.clamp(0.0, 1.0).toDouble() * progress).toDouble();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: trackHeight,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Jalur (track) abu tipis di belakang batang.
              Container(
                width: barWidth,
                height: trackHeight,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: radius,
                ),
              ),
              // Batang yang tumbuh dari bawah.
              Container(
                width: barWidth,
                height: barHeight,
                decoration: BoxDecoration(
                  color: highlight
                      ? scheme.primary
                      : scheme.primary.withValues(alpha: 0.45),
                  borderRadius: radius,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: text.labelMedium?.copyWith(
            color: highlight ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Carousel "Pola yang terlihat": PageView + indikator titik
// ---------------------------------------------------------------------------

class _PatternData {
  const _PatternData({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _PatternCarousel extends StatefulWidget {
  const _PatternCarousel();

  @override
  State<_PatternCarousel> createState() => _PatternCarouselState();
}

class _PatternCarouselState extends State<_PatternCarousel> {
  static const double _baseHeight = 132;
  static const double _cardGap = 12;

  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    // Kartu berikutnya mengintip di sisi kanan sebagai petunjuk geser.
    _controller = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_PatternData> _buildItems() {
    final scores = DummyData.weeklyScore;
    final best = _bestDayIndex(scores);
    final bestPercent = (scores[best] * 100).round();
    final remaining = DummyData.waterTarget - DummyData.waterGlasses;

    return [
      const _PatternData(
        icon: Icons.wb_sunny_rounded,
        title: 'Kamu paling konsisten di pagi hari',
        body: 'Kebiasaan yang dimulai sebelum siang paling sering selesai.',
      ),
      _PatternData(
        icon: Icons.trending_up_rounded,
        title: 'Coba pertahankan momentum ini',
        body: 'Skor tertinggi pekan ini $bestPercent% pada hari '
            '${_daysFull[best]}. Jaga ritmenya.',
      ),
      _PatternData(
        icon: Icons.water_drop_rounded,
        title: 'Air minum masih bisa naik',
        body: remaining > 0
            ? 'Tinggal $remaining gelas lagi untuk mencapai target hari ini.'
            : 'Target air minum hari ini sudah tercapai.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();
    final scheme = Theme.of(context).colorScheme;
    final reduce = _reduceMotion(context);
    final height = _baseHeight * _textScaleFactor(context);

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _controller,
            padEnds: false, // kartu pertama rata kiri dengan konten lain
            itemCount: items.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: _cardGap),
              child: _PatternCard(data: items[i]),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 4),
        Semantics(
          excludeSemantics: true,
          label: 'Halaman ${_page + 1} dari ${items.length}',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < items.length; i++)
                AnimatedContainer(
                  duration: reduce ? Duration.zero : AppMotion.fast,
                  curve: AppMotion.curve,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? scheme.primary
                        : scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PatternCard extends StatelessWidget {
  const _PatternCard({required this.data});

  final _PatternData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                data.icon,
                size: 20,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    data.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
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

// ---------------------------------------------------------------------------
// 4. Badge: GridView.count 3 kolom
// ---------------------------------------------------------------------------

class _BadgeData {
  const _BadgeData({
    required this.label,
    required this.icon,
    required this.unlocked,
  });

  final String label;
  final IconData icon;
  final bool unlocked;
}

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid();

  static const int _columns = 3;
  static const double _gap = 12;

  List<_BadgeData> _buildBadges() {
    return [
      _BadgeData(
        label: 'Streak 3 Hari',
        icon: Icons.local_fire_department_rounded,
        unlocked: DummyData.streakDays >= 3,
      ),
      const _BadgeData(
        label: 'Hidrasi',
        icon: Icons.water_drop_rounded,
        unlocked: true,
      ),
      const _BadgeData(
        label: 'Tidur Nyenyak',
        icon: Icons.bedtime_rounded,
        unlocked: true,
      ),
      const _BadgeData(
        label: 'Pejalan Rajin',
        icon: Icons.directions_walk_rounded,
        unlocked: false,
      ),
      _BadgeData(
        label: 'Streak 7 Hari',
        icon: Icons.whatshot_rounded,
        unlocked: DummyData.streakDays >= 7,
      ),
      const _BadgeData(
        label: 'Konsisten',
        icon: Icons.workspace_premium_rounded,
        unlocked: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final badges = _buildBadges();
    final scale = _textScaleFactor(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Rasio sel dihitung dari lebar sebenarnya + skala teks, sehingga
        // sel tidak overflow di 360 px maupun saat font diperbesar.
        final cellWidth =
            (constraints.maxWidth - _gap * (_columns - 1)) / _columns;
        final cellHeight = 76 + 32 * scale;

        return GridView.count(
          crossAxisCount: _columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: _gap,
          crossAxisSpacing: _gap,
          childAspectRatio: cellWidth / cellHeight,
          children: [
            for (final badge in badges) _BadgeCell(data: badge),
          ],
        );
      },
    );
  }
}

class _BadgeCell extends StatelessWidget {
  const _BadgeCell({required this.data});

  final _BadgeData data;

  static const double _circle = 52;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final unlocked = data.unlocked;

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '${data.label}, ${unlocked ? 'terbuka' : 'terkunci'}',
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: _circle,
                height: _circle,
                child: Stack(
                  children: [
                    // Lingkaran ikon: berwarna bila terbuka, pudar bila terkunci.
                    Opacity(
                      opacity: unlocked ? 1 : 0.4,
                      child: Container(
                        width: _circle,
                        height: _circle,
                        decoration: BoxDecoration(
                          color: unlocked
                              ? scheme.primaryContainer
                              : scheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          data.icon,
                          size: 26,
                          color: unlocked
                              ? scheme.onPrimaryContainer
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    // Ikon gembok di pojok kanan bawah, hanya saat terkunci.
                    if (!unlocked)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                          child: Icon(
                            Icons.lock_rounded,
                            size: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                data.label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: text.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: unlocked
                      ? scheme.onSurface
                      : scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}