import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/common.dart';
import '../widgets/feedback.dart';

/// LAYAR 03 - Pencatatan cepat (tab Tidur, Air, Aktivitas).
/// Animasi: tombol quick-add memantul saat ditekan, angka air berganti
/// dengan efek pop, centang animasi saat simpan, confetti saat target air
/// tercapai.
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
            const Staggered(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Tambah catatan', style: kTitleStyle),
                ),
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
    HapticFeedback.selectionClick();
    setState(() => _duration = next);
  }

  Future<void> _save() async {
    const message = 'Catatan tidur tersimpan';
    AppScope.of(context).saveSleep(_duration, _quality);
    await showSuccessCheck(context, message);
    if (!mounted) return;
    widget.onSaved(message);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Staggered(
          child: ValueStepper(
            label: 'Tidur semalam',
            valueText: fmtDuration(_duration),
            onMinus: () => _change(-10),
            onPlus: () => _change(10),
          ),
        ),
        const SizedBox(height: 20),
        Staggered(
          delay: const Duration(milliseconds: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bagaimana kualitas tidurmu?', style: TextStyle(fontWeight: FontWeight.w700, color: VColors.ink)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  for (var i = 0; i < _labels.length; i++)
                    ChoiceChip(
                      label: Text(_labels[i]),
                      selected: _quality == i,
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        setState(() => _quality = i);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Staggered(
          delay: const Duration(milliseconds: 200),
          child: Column(
            children: [
              _SaveButton(onPressed: _save),
              const SizedBox(height: 14),
              const Text(
                'Mencatat harus lebih mudah daripada menundanya.',
                textAlign: TextAlign.center,
                style: kMutedStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------- Air
class _WaterTab extends StatelessWidget {
  const _WaterTab();

  void _add(BuildContext context, int glasses) {
    final reached = AppScope.of(context).addWater(glasses);
    if (reached) {
      showCelebration(
        context,
        title: 'Target air tercapai!',
        subtitle: 'Badge "Hidrasi Harian" kamu dapatkan.',
      );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('+$glasses gelas tercatat'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Staggered(
          child: VCard(
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
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: anim,
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                        child: Text(
                          '${s.waterGlasses}',
                          key: ValueKey<int>(s.waterGlasses),
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: VColors.ink),
                        ),
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
        ),
        const SizedBox(height: 20),
        Staggered(
          delay: const Duration(milliseconds: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quick-add', style: TextStyle(fontWeight: FontWeight.w700, color: VColors.ink)),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final n in [1, 2, 3]) ...[
                    Expanded(
                      child: _QuickAddButton(
                        label: '+$n gelas',
                        onTap: () => _add(context, n),
                      ),
                    ),
                    if (n != 3) const SizedBox(width: 10),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tombol yang mengecil sesaat saat ditekan (efek memantul) + getaran ringan.
class _QuickAddButton extends StatefulWidget {
  const _QuickAddButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends State<_QuickAddButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: VColors.mint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(fontWeight: FontWeight.w800, color: VColors.forest),
          ),
        ),
      ),
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

  Future<void> _save() async {
    final message = 'Aktivitas $_type tersimpan';
    AppScope.of(context).addActivity(_type, _minutes, _steps);
    await showSuccessCheck(context, message);
    if (!mounted) return;
    widget.onSaved(message);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Staggered(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        setState(() => _type = t);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Staggered(
          delay: const Duration(milliseconds: 100),
          child: ValueStepper(
            label: 'Durasi (menit)',
            valueText: '$_minutes',
            onMinus: () => setState(() => _minutes = (_minutes - 5).clamp(5, 300).toInt()),
            onPlus: () => setState(() => _minutes = (_minutes + 5).clamp(5, 300).toInt()),
          ),
        ),
        const SizedBox(height: 12),
        Staggered(
          delay: const Duration(milliseconds: 200),
          child: ValueStepper(
            label: 'Jumlah langkah',
            valueText: fmtInt(_steps),
            onMinus: () => setState(() => _steps = (_steps - 500).clamp(0, 50000).toInt()),
            onPlus: () => setState(() => _steps = (_steps + 500).clamp(0, 50000).toInt()),
          ),
        ),
        const SizedBox(height: 24),
        Staggered(
          delay: const Duration(milliseconds: 300),
          child: _SaveButton(onPressed: _save),
        ),
      ],
    );
  }
}
