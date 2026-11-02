import 'package:flutter/material.dart';

import 'app/routes.dart';
import 'theme/app_theme.dart';

void main() => runApp(const VitaloApp());

/// Root aplikasi: Material 3, tema terang/gelap mengikuti sistem.
class VitaloApp extends StatelessWidget {
  const VitaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vitalo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light, // useMaterial3 diatur di AppTheme
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}