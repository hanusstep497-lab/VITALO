import 'package:flutter/material.dart';

import '../features/habits/habit_tracker_screen.dart';
import '../features/home/home_screen.dart';
import '../features/insight/insight_screen.dart';
import '../features/profile/profile_screen.dart';
import '../theme/app_motion.dart';
import 'routes.dart';

/// Satu-satunya Scaffold untuk 4 tab utama.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _titles = ['Home', 'Kebiasaan', 'Insight', 'Profil'];
  static const _profileIndex = 3;

  // Isi tab dibuat sekali; state (termasuk posisi scroll) tetap hidup.
  static const List<Widget> _tabs = [
    HomeScreen(),
    HabitTrackerScreen(),
    InsightScreen(),
    ProfileScreen(),
  ];

  int _index = 0;

  void _onSelectTab(int i) {
    if (i == _index) return;
    setState(() => _index = i);
  }

  // Buka layar tambah catatan; tampilkan SnackBar jika hasilnya true.
  Future<void> _openAddEntry() async {
    final saved = await Navigator.pushNamed<bool>(context, AppRoutes.addEntry);
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Catatan tersimpan')));
  }

  @override
  Widget build(BuildContext context) {
    // Jika pengguna mematikan animasi, semua transisi tampil langsung.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    Duration dur(Duration d) => reduceMotion ? Duration.zero : d;
    final showFab = _index != _profileIndex;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        // Judul berganti dengan fade; tetap rata kiri saat transisi.
        title: AnimatedSwitcher(
          duration: dur(AppMotion.normal),
          switchInCurve: AppMotion.curve,
          switchOutCurve: AppMotion.curve,
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.centerLeft,
            children: [...previous, if (current != null) current],
          ),
          child: Text(_titles[_index], key: ValueKey<int>(_index)),
        ),
      ),
      // Semua tab ditumpuk; hanya tab aktif yang terlihat (cross-fade).
      body: Stack(
        fit: StackFit.expand,
        children: [
          for (var i = 0; i < _tabs.length; i++)
            _TabFade(
              active: i == _index,
              duration: dur(AppMotion.normal),
              child: _tabs[i],
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onSelectTab,
        animationDuration: dur(AppMotion.fast),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Kebiasaan',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insight',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // FAB selalu ada di tree agar bisa dianimasikan; disembunyikan di tab Profil.
      floatingActionButton: IgnorePointer(
        ignoring: !showFab,
        child: ExcludeSemantics(
          excluding: !showFab,
          child: ExcludeFocus(
            excluding: !showFab,
            child: AnimatedScale(
              scale: showFab ? 1 : 0,
              duration: dur(AppMotion.fast),
              curve: AppMotion.curve,
              child: FloatingActionButton.extended(
                heroTag: null, // hindari animasi Hero saat membuka layar catat
                onPressed: _openAddEntry,
                icon: const Icon(Icons.add),
                label: const Text('Catat'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Membungkus satu tab: fade in/out, tab tak aktif tidak menerima sentuhan,
/// fokus, atau semantics, tetapi state-nya tetap terjaga.
class _TabFade extends StatelessWidget {
  const _TabFade({
    required this.active,
    required this.duration,
    required this.child,
  });

  final bool active;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: active ? 1 : 0,
      duration: duration,
      curve: AppMotion.curve,
      child: IgnorePointer(
        ignoring: !active,
        child: ExcludeSemantics(
          excluding: !active,
          child: ExcludeFocus(
            excluding: !active,
            child: TickerMode(
              enabled: active,
              // Tiap tab memakai ScrollController sendiri (bukan yang primer).
              child: PrimaryScrollController.none(child: child),
            ),
          ),
        ),
      ),
    );
  }
}