import 'package:flutter/material.dart';

class HabitItem {
  HabitItem(this.title, this.icon, {this.done = false});
  final String title;
  final IconData icon;
  bool done;
}

class ReminderItem {
  ReminderItem(this.label, this.icon, this.time, {this.enabled = true});
  final String label;
  final IconData icon;
  TimeOfDay time;
  bool enabled;
}

/// State aplikasi (data DUMMY, belum terhubung ke backend/database).
class AppState extends ChangeNotifier {
  // --- Air minum ---
  int waterGlasses = 5;
  final int waterTarget = 8;

  // --- Tidur ---
  Duration sleep = const Duration(hours: 7, minutes: 20);
  final Duration sleepTarget = const Duration(hours: 8);
  int sleepQuality = 1; // 0 = kurang, 1 = cukup, 2 = nyenyak

  // --- Aktivitas ---
  int steps = 4280;
  final int stepsTarget = 8000;
  int activityMinutes = 35;
  String activityType = 'Jalan kaki';

  // --- Konsistensi & streak ---
  final List<bool> weekDone = [true, true, false, true, true, false, true];
  int streak = 4;
  final int improvement = 23;
  final List<double> weeklyScore = [0.55, 0.62, 0.48, 0.70, 0.66, 0.78, 0.85];

  final List<HabitItem> habits = [
    HabitItem('Minum air 8 gelas', Icons.water_drop_rounded),
    HabitItem('Berjalan 20 menit', Icons.directions_walk_rounded, done: true),
    HabitItem('Tidur sebelum 22:00', Icons.bedtime_rounded),
    HabitItem('Peregangan 5 menit', Icons.self_improvement_rounded),
  ];

  final List<ReminderItem> reminders = [
    ReminderItem('Minum air', Icons.water_drop_rounded, const TimeOfDay(hour: 10, minute: 0)),
    ReminderItem('Tidur', Icons.bedtime_rounded, const TimeOfDay(hour: 21, minute: 30)),
    ReminderItem('Gerak', Icons.directions_run_rounded, const TimeOfDay(hour: 16, minute: 0), enabled: false),
  ];

  final List<String> insights = const [
    'Kamu paling konsisten di pagi hari. Coba pertahankan momentum ini.',
    'Minum air meningkat 2 gelas dibanding minggu lalu.',
    'Tidur lebih dari 7 jam terjadi 5 dari 7 malam terakhir.',
    'Langkah harianmu naik pada hari kerja, turun saat akhir pekan.',
  ];

  // --- Getter turunan ---
  double get waterRatio => (waterGlasses / waterTarget).clamp(0.0, 1.0).toDouble();
  double get sleepRatio => (sleep.inMinutes / sleepTarget.inMinutes).clamp(0.0, 1.0).toDouble();
  double get stepsRatio => (steps / stepsTarget).clamp(0.0, 1.0).toDouble();
  double get overallProgress => (waterRatio + sleepRatio + stepsRatio) / 3;
  int get doneDays => weekDone.where((d) => d).length;

  String get waterStatus {
    if (waterGlasses >= waterTarget) return 'Target harian tercapai!';
    if (waterRatio >= 0.6) return 'Target harian hampir tercapai';
    return 'Ayo minum lagi, masih jauh dari target';
  }

  // --- Aksi ---
  void addWater(int glasses) {
    waterGlasses += glasses;
    notifyListeners();
  }

  void saveSleep(Duration duration, int quality) {
    sleep = duration;
    sleepQuality = quality;
    notifyListeners();
  }

  void addActivity(String type, int minutes, int addedSteps) {
    activityType = type;
    activityMinutes += minutes;
    steps += addedSteps;
    notifyListeners();
  }

  void toggleHabit(HabitItem item, bool value) {
    item.done = value;
    notifyListeners();
  }

  void setReminderEnabled(ReminderItem item, bool value) {
    item.enabled = value;
    notifyListeners();
  }

  void setReminderTime(ReminderItem item, TimeOfDay time) {
    item.time = time;
    notifyListeners();
  }
}

/// Menyediakan AppState ke seluruh widget tree (tanpa package eksternal).
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope tidak ditemukan di widget tree');
    return scope!.notifier!;
  }
}
