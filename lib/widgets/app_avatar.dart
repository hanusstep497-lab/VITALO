import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Avatar bulat berbasis `CircleAvatar`.
///
/// Jika [imageAsset] diberikan, gambar ditampilkan; bila gagal dimuat
/// (`errorBuilder`) otomatis kembali ke [initials]. Tanpa [imageAsset],
/// langsung menampilkan [initials].
class AppAvatar extends StatelessWidget {
  /// Path asset gambar, mis. `assets/images/me.png`. Null -> pakai inisial.
  final String? imageAsset;

  /// Inisial yang ditampilkan sebagai fallback, mis. "NH". Disarankan 1-2
  /// huruf; teks otomatis mengecil agar tetap muat di dalam lingkaran.
  final String initials;

  /// Jari-jari avatar dalam logical pixel. Default 24.
  final double radius;

  const AppAvatar({
    super.key,
    this.imageAsset,
    required this.initials,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final initialsView = Padding(
      padding: EdgeInsets.all(radius * 0.2),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          initials,
          maxLines: 1,
          style: text.titleMedium?.copyWith(
            fontSize: radius * 0.8,
            fontWeight: FontWeight.w600,
            color: scheme.onPrimaryContainer,
          ),
        ),
      ),
    );

    final asset = imageAsset;
    final size = radius * 2;

    return Semantics(
      label: initials,
      image: true,
      excludeSemantics: true,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: scheme.primaryContainer,
        child: asset == null
            ? initialsView
            : ClipOval(
                child: Image.asset(
                  asset,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => SizedBox(
                    width: size - AppSpacing.xs,
                    height: size - AppSpacing.xs,
                    child: Center(child: initialsView),
                  ),
                ),
              ),
      ),
    );
  }
}