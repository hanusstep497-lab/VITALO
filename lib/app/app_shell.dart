import 'package:flutter/material.dart';

import '../features/habits/habit_tracker_screen.dart';
import '../features/home/home_screen.dart';
import '../features/insight/insight_screen.dart';
import '../features/profile/profile_screen.dart';
import 'routes.dart';

/// STUB milik Anggota 1 (T1). Satu-satunya Scaffold untuk 4 tab.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _titles = ['Home', 'Kebiasaan', 'Insight', 'Profil'];

  Future<void> _openAddEntry() async {
    final saved = await Navigator.pushNamed(context, AppRoutes.addEntry);
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Catatan tersimpan')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          HabitTrackerScreen(),
          InsightScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.check_circle_outline), selectedIcon: Icon(Icons.check_circle), label: 'Kebiasaan'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Insight'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      floatingActionButton: _index == 3
          ? null
          : FloatingActionButton.extended(
              onPressed: _openAddEntry,
              icon: const Icon(Icons.add),
              label: const Text('Catat'),
            ),
    );
  }
}
