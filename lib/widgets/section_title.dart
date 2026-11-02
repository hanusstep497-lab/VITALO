import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Judul bagian dengan tombol teks aksi opsional di sisi kanan,
/// mis. "Kebiasaan hari ini" + "Lihat semua".
class SectionTitle extends StatelessWidget {
  /// Teks judul bagian. Satu baris, dipotong `...` bila terlalu panjang.
  final String title;

  /// Label tombol aksi di kanan. Jika null, tombol tidak ditampilkan.
  final String? actionLabel;

  /// Dipanggil saat tombol aksi ditekan. Hanya relevan jika [actionLabel]
  /// tidak null; bila null tombol tampil nonaktif.
  final VoidCallback? onAction;

  const SectionTitle(this.title, {super.key, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final label = actionLabel;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Tombol dibatasi maksimal 55% lebar agar judul tetap terbaca
        // dan Row tidak overflow pada lebar sempit (mis. 160 px).
        final maxAction = constraints.maxWidth.isFinite
            ? constraints.maxWidth * 0.55
            : double.infinity;

        return Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (label != null)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxAction),
                child: TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}