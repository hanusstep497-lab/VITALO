import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/section_title.dart';
import '../../widgets/stat_card.dart';

/// Tab Profil: avatar + nama pengguna dan ringkasan singkat.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Ambil maksimal 2 huruf awal dari nama, mis. "Budi Santoso" -> "BS".
  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const SizedBox(height: AppSpacing.md),
        Center(
          child: AppAvatar(
            initials: _initials(DummyData.userName),
            radius: 44,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          DummyData.userName,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Streak ${DummyData.streakDays} hari',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionTitle('Ringkasan hari ini'),
        const SizedBox(height: AppSpacing.sm),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StatCard(
                title: 'Air minum',
                value: '${DummyData.waterGlasses}',
                unit: '/ ${DummyData.waterTarget}',
                icon: Icons.water_drop_rounded,
                progress: DummyData.waterGlasses / DummyData.waterTarget,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                title: 'Langkah',
                value: '${DummyData.steps}',
                icon: Icons.directions_walk_rounded,
                progress: DummyData.steps / DummyData.stepTarget,
              ),
            ),
          ],
        ),
      ],
    );
  }
}