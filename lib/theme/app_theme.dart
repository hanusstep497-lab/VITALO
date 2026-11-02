import 'package:flutter/material.dart';

/// STUB milik Anggota 1 (T4). Akan dilengkapi component theme, typography, dll.
class AppTheme {
  static const _seed = Color(0xFF1F9D8A);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
      );
}
