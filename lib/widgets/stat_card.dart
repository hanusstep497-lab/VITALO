import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';

/// Kartu ringkas berisi ikon dalam lingkaran tonal, judul, nilai besar
/// dengan unit kecil, dan progress bar opsional.
///
/// Widget ini murni presentasional: semua data diterima lewat parameter
/// (tidak membaca `DummyData`). Jika [onTap] diberikan, kartu memberi
/// feedback tekan berupa scale 0.98.
class StatCard extends StatefulWidget {
  /// Judul kartu, mis. "Air minum". Satu baris, dipotong `...` bila panjang.
  final String title;

  /// Nilai utama yang ditampilkan besar, mis. "5" atau "4.280".
  final String value;

  /// Unit kecil di samping [value], mis. "gelas". Disembunyikan jika null.
  final String? unit;

  /// Ikon di dalam lingkaran berwarna tonal.
  final IconData icon;

  /// Progres 0.0-1.0 (nilai di luar rentang di-clamp). Jika null, progress
  /// bar tidak ditampilkan. Pengisiannya dianimasikan.
  final double? progress;

  /// Dipanggil saat kartu diketuk. Jika null, kartu tidak interaktif dan
  /// tidak ada feedback tekan.
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    required this.icon,
    this.progress,
    this.onTap,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  static const double _pressedScale = 0.98;
  static const double _iconCircle = 36;

  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final interactive = widget.onTap != null;
    final progress = widget.progress?.clamp(0.0, 1.0).toDouble();

    final valueStyle = text.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: scheme.onSurface,
    );
    final unitStyle = text.labelMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: _iconCircle,
                height: _iconCircle,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text.rich(
            TextSpan(
              text: widget.value,
              style: valueStyle,
              children: [
                if (widget.unit != null)
                  TextSpan(text: ' ${widget.unit}', style: unitStyle),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (progress != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TweenAnimationBuilder<double>(
              // begin 0 -> animasi mengisi saat pertama tampil; saat `end`
              // berubah, animasi berlanjut dari nilai terakhir.
              tween: Tween<double>(begin: 0, end: progress),
              duration: AppMotion.slow,
              curve: AppMotion.curve,
              builder: (context, animated, _) => ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.xs),
                child: LinearProgressIndicator(
                  value: animated,
                  minHeight: AppSpacing.sm - 2,
                  color: scheme.primary,
                  backgroundColor: scheme.surfaceContainerHighest,
                  semanticsLabel: widget.title,
                  semanticsValue: '${(progress * 100).round()}%',
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return AnimatedScale(
      scale: interactive && _pressed ? _pressedScale : 1.0,
      duration: AppMotion.fast,
      curve: AppMotion.curve,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: interactive
            ? InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => _setPressed(true),
                onTapUp: (_) => _setPressed(false),
                onTapCancel: () => _setPressed(false),
                child: content,
              )
            : content,
      ),
    );
  }
}