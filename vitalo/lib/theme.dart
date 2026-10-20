import 'package:flutter/material.dart';

/// Palet warna mengikuti desain pada proposal Vitalo.
class VColors {
  static const forest = Color(0xFF083C35);
  static const teal = Color(0xFF0FBDB7);
  static const orange = Color(0xFFF26A3D);
  static const bg = Color(0xFFF2F4ED);
  static const ink = Color(0xFF10201D);
  static const muted = Color(0xFF66746F);
  static const border = Color(0xFFCBD4CE);
  static const mint = Color(0xFFD5EFEA);
}

const TextStyle kLabelStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w700,
  letterSpacing: 1.2,
  color: VColors.muted,
);

const TextStyle kTitleStyle = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w800,
  color: VColors.ink,
);

const TextStyle kMutedStyle = TextStyle(fontSize: 14, color: VColors.muted, height: 1.4);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: VColors.forest,
    primary: VColors.forest,
    secondary: VColors.teal,
    tertiary: VColors.orange,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: VColors.bg,
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: VColors.mint,
    ),
  );
}
