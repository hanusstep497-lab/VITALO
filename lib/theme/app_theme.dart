import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// Warna semantik kebiasaan Vitalo (air, tidur, aktivitas).
///
/// Pemakaian:
/// - `water` / `sleep` / `activity` : ikon, progress, angka aksen di atas
///   surface atau kartu (kontras >= 4.5:1).
/// - `xxxContainer` + `onXxxContainer` : latar tint + teks/ikon di atasnya.
@immutable
class HabitColors extends ThemeExtension<HabitColors> {
  const HabitColors({
    required this.water,
    required this.waterContainer,
    required this.onWaterContainer,
    required this.sleep,
    required this.sleepContainer,
    required this.onSleepContainer,
    required this.activity,
    required this.activityContainer,
    required this.onActivityContainer,
  });

  final Color water;
  final Color waterContainer;
  final Color onWaterContainer;
  final Color sleep;
  final Color sleepContainer;
  final Color onSleepContainer;
  final Color activity;
  final Color activityContainer;
  final Color onActivityContainer;

  /// Varian terang: aksen gelap-sedang di atas latar terang.
  static const HabitColors light = HabitColors(
    water: Color(0xFF0B6BA8),
    waterContainer: Color(0xFFD5E9F8),
    onWaterContainer: Color(0xFF00324F),
    sleep: Color(0xFF524FB8),
    sleepContainer: Color(0xFFE4E2FF),
    onSleepContainer: Color(0xFF1B1A68),
    activity: Color(0xFF9A4B00),
    activityContainer: Color(0xFFFFDFC4),
    onActivityContainer: Color(0xFF3C1A00),
  );

  /// Varian gelap: aksen terang di atas latar gelap.
  static const HabitColors dark = HabitColors(
    water: Color(0xFF8FCDFF),
    waterContainer: Color(0xFF00476C),
    onWaterContainer: Color(0xFFCDE6FF),
    sleep: Color(0xFFC3C1FF),
    sleepContainer: Color(0xFF3A3A9E),
    onSleepContainer: Color(0xFFE4E2FF),
    activity: Color(0xFFFFB77A),
    activityContainer: Color(0xFF6B3500),
    onActivityContainer: Color(0xFFFFDFC4),
  );

  /// Ambil dari tema aktif: `HabitColors.of(context).water`.
  static HabitColors of(BuildContext context) =>
      Theme.of(context).extension<HabitColors>() ?? light;

  @override
  HabitColors copyWith({
    Color? water,
    Color? waterContainer,
    Color? onWaterContainer,
    Color? sleep,
    Color? sleepContainer,
    Color? onSleepContainer,
    Color? activity,
    Color? activityContainer,
    Color? onActivityContainer,
  }) {
    return HabitColors(
      water: water ?? this.water,
      waterContainer: waterContainer ?? this.waterContainer,
      onWaterContainer: onWaterContainer ?? this.onWaterContainer,
      sleep: sleep ?? this.sleep,
      sleepContainer: sleepContainer ?? this.sleepContainer,
      onSleepContainer: onSleepContainer ?? this.onSleepContainer,
      activity: activity ?? this.activity,
      activityContainer: activityContainer ?? this.activityContainer,
      onActivityContainer: onActivityContainer ?? this.onActivityContainer,
    );
  }

  @override
  HabitColors lerp(ThemeExtension<HabitColors>? other, double t) {
    if (other is! HabitColors) return this;
    return HabitColors(
      water: Color.lerp(water, other.water, t)!,
      waterContainer: Color.lerp(waterContainer, other.waterContainer, t)!,
      onWaterContainer: Color.lerp(onWaterContainer, other.onWaterContainer, t)!,
      sleep: Color.lerp(sleep, other.sleep, t)!,
      sleepContainer: Color.lerp(sleepContainer, other.sleepContainer, t)!,
      onSleepContainer: Color.lerp(onSleepContainer, other.onSleepContainer, t)!,
      activity: Color.lerp(activity, other.activity, t)!,
      activityContainer: Color.lerp(activityContainer, other.activityContainer, t)!,
      onActivityContainer:
          Color.lerp(onActivityContainer, other.onActivityContainer, t)!,
    );
  }
}

/// Tema Material 3 Vitalo.
///
/// Peran warna (seed hijau-teal 0xFF1F9D8A):
/// - primary   : identitas & aksi utama (tombol Filled, tab aktif, progress utama).
/// - secondary : pendukung yang tenang (indikator NavigationBar, chip terpilih).
/// - tertiary  : aksen pelengkap (streak, sorotan Insight) - dipakai hemat.
/// - surface   : latar layar; kartu memakai surfaceContainerLow.
/// - error     : hanya kesalahan input/aksi destruktif, bukan "target belum tercapai".
class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFF1F9D8A);

  /// Tinggi minimum target sentuh (48 dp).
  static const double _minTouch = 48;

  static final ThemeData light = _build(Brightness.light, HabitColors.light);
  static final ThemeData dark = _build(Brightness.dark, HabitColors.dark);

  static ThemeData _build(Brightness brightness, HabitColors habit) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    final text = _textTheme(scheme);
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      side: BorderSide(color: scheme.outlineVariant),
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );
    const buttonPadding = EdgeInsets.symmetric(horizontal: AppSpacing.lg);

    OutlineInputBorder inputBorder(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      extensions: <ThemeExtension<dynamic>>[habit],
      // Transisi halaman sama di semua platform (zoom + fade).
      pageTransitionsTheme: PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          for (final platform in TargetPlatform.values)
            platform: const ZoomPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: text.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: cardShape,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, _minTouch),
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, _minTouch),
          padding: buttonPadding,
          shape: buttonShape,
          side: BorderSide(color: scheme.outline),
          textStyle: text.labelLarge,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return text.labelMedium?.copyWith(
            color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        border: inputBorder(scheme.outline),
        enabledBorder: inputBorder(scheme.outline),
        focusedBorder: inputBorder(scheme.primary, 2),
        errorBorder: inputBorder(scheme.error),
        focusedErrorBorder: inputBorder(scheme.error, 2),
        disabledBorder: inputBorder(scheme.outlineVariant),
        helperStyle: text.labelMedium,
        errorStyle: text.labelMedium?.copyWith(color: scheme.error),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        side: BorderSide(color: scheme.outline),
        selectedColor: scheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle:
            text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        actionTextColor: scheme.inversePrimary,
        insetPadding: const EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  /// Hierarchy tipografi. Font bawaan sistem (tanpa package).
  /// - displaySmall  : angka besar dashboard
  /// - headlineSmall : judul layar
  /// - titleMedium   : judul kartu
  /// - bodyMedium    : isi
  /// - labelMedium   : keterangan / label
  static TextTheme _textTheme(ColorScheme scheme) {
    final base = ThemeData(useMaterial3: true, colorScheme: scheme).textTheme;
    final label = base.labelMedium?.copyWith(
      fontSize: 12,
      height: 1.35,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.4,
    );
    return base
        .copyWith(
          displaySmall: base.displaySmall?.copyWith(
            fontSize: 36,
            height: 1.2,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontSize: 24,
            height: 1.3,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontSize: 16,
            height: 1.4,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
          ),
          labelMedium: label,
        )
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface)
        .copyWith(
          // Label = keterangan sekunder, sedikit lebih redup (tetap >= 4.5:1).
          labelMedium: label?.copyWith(color: scheme.onSurfaceVariant),
        );
  }
}