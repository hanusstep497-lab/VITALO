import 'package:flutter/material.dart';

/// Batas lebar (logical pixel) untuk kelas ukuran layar (nilai kontrak).
///
/// compact < 600, medium 600-840 (inklusif), expanded > 840.
class Breakpoints {
  static const double compact = 600;
  static const double medium = 840;
}

/// Kelas ukuran layar berdasarkan lebar yang tersedia.
enum ScreenSize {
  compact,
  medium,
  expanded;

  /// Tentukan kelas ukuran dari [width].
  static ScreenSize fromWidth(double width) {
    if (width < Breakpoints.compact) return ScreenSize.compact;
    if (width <= Breakpoints.medium) return ScreenSize.medium;
    return ScreenSize.expanded;
  }
}

/// Akses cepat info ukuran layar dari [BuildContext].
extension ResponsiveContext on BuildContext {
  /// Kelas ukuran berdasarkan lebar jendela (MediaQuery).
  ScreenSize get screenSize =>
      ScreenSize.fromWidth(MediaQuery.sizeOf(this).width);

  /// True jika orientasi layar landscape.
  bool get isLandscape => MediaQuery.orientationOf(this) == Orientation.landscape;
}

/// Builder yang menerima context dan constraint area yang tersedia.
typedef ResponsiveWidgetBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
);

/// Memilih layout berdasarkan constraint induk (bukan lebar layar penuh),
/// sehingga tetap benar saat widget ditempatkan di panel yang lebih sempit.
///
/// [medium] dan [expanded] opsional: bila null memakai builder terdekat
/// di bawahnya (expanded -> medium -> compact).
class ResponsiveBuilder extends StatelessWidget {
  final ResponsiveWidgetBuilder compact;
  final ResponsiveWidgetBuilder? medium;
  final ResponsiveWidgetBuilder? expanded;

  const ResponsiveBuilder({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Lebar tak terbatas (jarang terjadi) diperlakukan sebagai compact.
        final size = constraints.maxWidth.isFinite
            ? ScreenSize.fromWidth(constraints.maxWidth)
            : ScreenSize.compact;

        final builder = switch (size) {
          ScreenSize.compact => compact,
          ScreenSize.medium => medium ?? compact,
          ScreenSize.expanded => expanded ?? medium ?? compact,
        };
        return builder(context, constraints);
      },
    );
  }
}

/// Membatasi lebar maksimum [child] dan menempatkannya di tengah,
/// agar form/daftar tidak melebar di layar besar.
class MaxWidthBox extends StatelessWidget {
  final double maxWidth;
  final AlignmentGeometry alignment;
  final Widget child;

  const MaxWidthBox({
    super.key,
    this.maxWidth = 600,
    this.alignment = Alignment.topCenter,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}