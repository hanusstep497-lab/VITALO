import 'package:flutter/material.dart';

import '../../app/routes.dart';

/// STUB milik Anggota 2 (T2). Nama class JANGAN diubah.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.shell),
          child: const Text('Masuk (stub)'),
        ),
      ),
    );
  }
}
