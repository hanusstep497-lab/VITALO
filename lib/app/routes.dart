import 'package:flutter/material.dart';

import '../features/add_entry/add_entry_screen.dart';
import '../features/login/login_screen.dart';
import 'app_shell.dart';

/// Nama route + peta route (sesuai kontrak, jangan diubah).
class AppRoutes {
  static const login = '/login';
  static const shell = '/app';
  static const addEntry = '/add';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        shell: (_) => const AppShell(),
        addEntry: (_) => const AddEntryScreen(),
      };
}