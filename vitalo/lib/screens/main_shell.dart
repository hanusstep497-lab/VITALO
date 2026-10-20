import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'add_entry_screen.dart';
import 'habit_tracker_screen.dart';
import 'home_screen.dart';
import 'insight_screen.dart';
import 'settings_screen.dart';

/// Kerangka utama dengan navigasi bawah untuk layar 02 - 06.
/// Perpindahan tab memakai AnimatedSwitcher (fade + geser tipis), dan
/// animasi masuk setiap layar diputar ulang saat tab dibuka.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _go(int i) {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
  }

  void _saved(String message) {
    setState(() => _index = 0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _page(int i) {
    switch (i) {
      case 0:
        return HomeScreen(onAdd: () => _go(1));
      case 1:
        return AddEntryScreen(onSaved: _saved);
      case 2:
        return const HabitTrackerScreen();
      case 3:
        return const InsightScreen();
      default:
        return const SettingsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_index),
          child: _page(_index),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline_rounded), selectedIcon: Icon(Icons.add_circle_rounded), label: 'Catat'),
          NavigationDestination(icon: Icon(Icons.checklist_rounded), selectedIcon: Icon(Icons.checklist_rounded), label: 'Kebiasaan'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights_rounded), label: 'Insight'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Pengaturan'),
        ],
      ),
    );
  }
}
