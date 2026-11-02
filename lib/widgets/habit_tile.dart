import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';

/// Baris kebiasaan: ikon, judul, subtitle opsional, dan penanda selesai.
///
/// Saat [done] berubah, ikon centang bertukar dengan `AnimatedSwitcher`
/// dan judul dicoret dengan `AnimatedDefaultTextStyle`. Widget ini tidak
/// menyimpan state: pemanggil yang memegang nilai [done].
class HabitTile extends StatelessWidget {
  /// Nama kebiasaan, mis. "Minum air 8 gelas". Maksimal dua baris.
  final String title;

  /// Keterangan tambahan di bawah [title]. Disembunyikan jika null.
  final String? subtitle;

  /// Ikon kebiasaan di sisi kiri.
  final IconData icon;

  /// Status selesai. `true` -> judul dicoret dan centang terisi.
  final bool done;

  /// Dipanggil saat baris diketuk, dengan nilai baru (`!done`).
  /// Jika null, baris bersifat read-only.
  final ValueChanged<bool>? onChanged;

  const HabitTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.done,
    this.onChanged,
  });

  static const double _iconCircle = 40;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final titleStyle = (text.bodyLarge ?? const TextStyle()).copyWith(
      decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
      decorationColor: scheme.onSurfaceVariant,
      color: done ? scheme.onSurfaceVariant : scheme.onSurface,
    );

    final handler = onChanged;

    return Semantics(
      checked: done,
      enabled: handler != null,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        onTap: handler == null ? null : () => handler(!done),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: AppMotion.fast,
                  curve: AppMotion.curve,
                  width: _iconCircle,
                  height: _iconCircle,
                  decoration: BoxDecoration(
                    color: done
                        ? scheme.primaryContainer
                        : scheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: done
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedDefaultTextStyle(
                        style: titleStyle,
                        duration: AppMotion.normal,
                        curve: AppMotion.curve,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        child: Text(title),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AnimatedSwitcher(
                  duration: AppMotion.fast,
                  switchInCurve: AppMotion.curve,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Icon(
                    done ? Icons.check_circle : Icons.radio_button_unchecked,
                    key: ValueKey<bool>(done),
                    color: done ? scheme.primary : scheme.outline,
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