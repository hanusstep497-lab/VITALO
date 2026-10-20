import 'package:flutter/material.dart';

import 'screens/splash_login_screen.dart';
import 'state/app_state.dart';
import 'theme.dart';

void main() => runApp(const VitaloApp());

class VitaloApp extends StatefulWidget {
  const VitaloApp({super.key});

  @override
  State<VitaloApp> createState() => _VitaloAppState();
}

class _VitaloAppState extends State<VitaloApp> {
  final AppState _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AppScope berada di atas MaterialApp supaya semua halaman
    // (termasuk yang dibuka lewat Navigator) bisa membaca AppState.
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'Vitalo',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const SplashLoginScreen(),
      ),
    );
  }
}
