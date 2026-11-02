import 'package:flutter/material.dart';

class Habit {
  final String title;
  final IconData icon;
  final bool done;
  const Habit({required this.title, required this.icon, required this.done});
}

class DummyData {
  static const String userName = 'Kamu';
  static const int waterGlasses = 5;
  static const int waterTarget = 8;
  static const int sleepMinutes = 440; // 7j 20m
  static const int steps = 4280;
  static const int stepTarget = 8000;
  static const int streakDays = 4;
  static const List<double> weeklyScore = [0.4, 0.6, 0.5, 0.8, 0.7, 0.9, 0.75];
  static const List<Habit> habits = [
    Habit(title: 'Minum air 8 gelas', icon: Icons.water_drop_outlined, done: false),
    Habit(title: 'Berjalan 20 menit', icon: Icons.directions_walk, done: true),
    Habit(title: 'Tidur 7 jam', icon: Icons.bedtime_outlined, done: true),
    Habit(title: 'Stretching', icon: Icons.self_improvement, done: false),
  ];
}
