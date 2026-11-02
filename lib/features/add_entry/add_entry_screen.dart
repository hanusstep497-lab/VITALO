import 'package:flutter/material.dart';

/// STUB milik Anggota 3 (T5). Nama class JANGAN diubah.
class AddEntryScreen extends StatelessWidget {
  const AddEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah catatan')),
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Simpan (stub)'),
        ),
      ),
    );
  }
}
