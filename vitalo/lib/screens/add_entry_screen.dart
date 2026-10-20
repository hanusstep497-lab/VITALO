import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';

/// LAYAR 03 - Pencatatan cepat (tab Tidur, Air, Aktivitas).
class AddEntryScreen extends StatelessWidget {
  const AddEntryScreen({super.key, required this.onSaved});

  final void Function(String message) onSaved;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Tambah catatan', style: kTitleStyle),
              ),
            ),
            const TabBar(
              labelColor: VColors.forest,
              unselectedLabelColor: VColors.muted,
              indicatorColor: VColors.orange,
              tabs: [
                Tab(text: 'Tidur'),
                Tab(text: 'Air'),
                Tab(text: 'Aktivitas'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _SleepTab(onSaved: onSaved),
                  const _WaterTab(),
                  _ActivityTab(onSaved: onSaved),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text('Simpan catatan'),
    );
  }
}

// ---------------------------------------------------------------- Tidur
class _SleepTab extends StatefulWidget {
  const _SleepTab({required this.onSaved});

  final void Function(String message) onSaved;

  @override
  State<_SleepTab> createState() => _SleepTabState();
}

class _SleepTabState extends State<_SleepTab> {
  Duration _duration = const Duration(hours: 7, minutes: 20);
  int _quality = 1;

  static const _labels = ['Kurang', 'Cukup', 'Nyenyak'];

  void _change(int minutes) {
    final next = _duration + Duration(minutes: minutes);
    if (next.inMinutes < 30 || next.inMinutes > 16 * 60) return;
    setState(() => _duration = next);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ValueStepper(
          label: 'Tidur semalam',
          valueText: fmtDuration(_duration),
          onMinus: () => _change(-10),
          onPlus: () => _change(10),
        ),
        const SizedBox(height: 20),
        const Text('Bagaimana kualitas tidurmu?', style: TextStyle(fontWeight: FontWeight.w700, color: VColors.ink)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            for (var i = 0; i < _labels.length; i++)
              ChoiceChip(
                label: Text(_labels[i]),
                selected: _quality == i,
                onSelected: (_) => setState(() => _quality = i),
              ),
          ],
        ),
        const SizedBox(height: 28),
        _SaveButton(
          onPressed: () {
            AppScope.of(context).saveSleep(_duration, _quality);
            widget.onSaved('Catatan tidur tersimpan');
          },
        ),
        const SizedBox(height: 14),
        const Text(
          'Mencatat harus lebih mudah daripada menundanya.',
          textAlign: TextAlign.center,
          style: kMutedStyle,
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------- Air
class _WaterTab extends StatelessWidget {
  const _WaterTab();

  void _add(BuildContext context, int glasses) {
    AppScope.of(context).addWater(glasses);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('+$glasses gelas tercatat'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        VCard(
          child: Column(
            children: [
              ProgressRing(
                value: s.waterRatio,
                size: 150,
                stroke: 14,
                color: VColors.teal,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${s.waterGlasses}',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: VColors.ink),
                    ),
                    Text('dari ${s.waterTarget} gelas', style: kMutedStyle),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(s.waterStatus, style: kMutedStyle),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Quick-add', style: TextStyle(fontWeight: FontWeight.w700, color: VColors.ink)),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final n in [1, 2, 3]) ...[
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () => _add(context, n),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(64),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('+$n gelas'),
                ),
              ),
              if (n != 3) const SizedBox(width: 10),
            ],
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ Aktivitas
class _ActivityTab extends StatefulWidget {
  const _ActivityTab({required this.onSaved});

  final void Function(String message) onSaved;

  @override
  State<_ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<_ActivityTab> {
  static const _types = ['Jalan kaki', 'Lari', 'Bersepeda', 'Yoga'];

  String _type = _types.first;
  int _minutes = 20;
  int _steps = 1500;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Jenis aktivitas', style: TextStyle(fontWeight: FontWeight.w700, color: VColors.ink)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            for (final t in _types)
              ChoiceChip(
                label: Text(t),
                selected: _type == t,
                onSelected: (_) => setState(() => _type = t),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ValueStepper(
          label: 'Durasi (menit)',
          valueText: '$_minutes',
          onMinus: () => setState(() => _minutes = (_minutes - 5).clamp(5, 300).toInt()),
          onPlus: () => setState(() => _minutes = (_minutes + 5).clamp(5, 300).toInt()),
        ),
        const SizedBox(height: 12),
        ValueStepper(
          label: 'Jumlah langkah',
          valueText: fmtInt(_steps),
          onMinus: () => setState(() => _steps = (_steps - 500).clamp(0, 50000).toInt()),
          onPlus: () => setState(() => _steps = (_steps + 500).clamp(0, 50000).toInt()),
        ),
        const SizedBox(height: 24),
        _SaveButton(
          onPressed: () {
            AppScope.of(context).addActivity(_type, _minutes, _steps);
            widget.onSaved('Aktivitas $_type tersimpan');
          },
        ),
      ],
    );
  }
}
