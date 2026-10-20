import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// LAYAR 05 - Insight Progres (grafik mingguan + pola).
/// Animasi: batang grafik tumbuh dari bawah berurutan, angka +% count-up.
class InsightScreen extends StatelessWidget {
  const InsightScreen({super.key});

  static const _dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  void _showAll(BuildContext context, AppState s) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Semua insight', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: VColors.ink)),
            const SizedBox(height: 12),
            for (var i = 0; i < s.insights.length; i++)
              Staggered(
                delay: Duration(milliseconds: i * 90),
                slide: const Offset(0.06, 0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded, color: VColors.orange, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(s.insights[i], style: kMutedStyle)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Staggered(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('INSIGHT PROGRES', style: kLabelStyle),
                SizedBox(height: 4),
                Text('Insight mingguan', style: kTitleStyle),
                SizedBox(height: 8),
                Text(
                  'Ubah catatan menjadi pemahaman: lihat pola, rayakan konsistensi, dan temukan langkah sederhana berikutnya.',
                  style: kMutedStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Staggered(
            delay: const Duration(milliseconds: 100),
            child: VCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('7 hari terakhir', style: kLabelStyle),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 160,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < 7; i++)
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: s.weeklyScore[i]),
                                  // Batang belakang tumbuh sedikit lebih lambat -> efek berurutan.
                                  duration: Duration(milliseconds: 500 + i * 110),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, v, _) => Container(
                                    height: 120 * v,
                                    margin: const EdgeInsets.symmetric(horizontal: 6),
                                    decoration: BoxDecoration(
                                      color: i == 6 ? VColors.orange : VColors.teal,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(_dayLabels[i], style: const TextStyle(fontSize: 12, color: VColors.muted)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Staggered(
            delay: const Duration(milliseconds: 250),
            child: VCard(
              color: VColors.forest,
              child: Row(
                children: [
                  CountUpText(
                    value: s.improvement,
                    prefix: '+',
                    suffix: '%',
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: VColors.teal),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Kebiasaan lebih konsisten',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Staggered(
            delay: const Duration(milliseconds: 350),
            child: VCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pola yang terlihat', style: kLabelStyle),
                  const SizedBox(height: 8),
                  Text(s.insights.first, style: const TextStyle(fontSize: 16, color: VColors.ink, height: 1.4)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Staggered(
            delay: const Duration(milliseconds: 450),
            child: Column(
              children: [
                OutlinedButton(
                  onPressed: () => _showAll(context, s),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Lihat semua insight'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bukan sekadar angka. Ada cerita di baliknya.',
                  textAlign: TextAlign.center,
                  style: kMutedStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
