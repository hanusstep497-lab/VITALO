import 'package:flutter/material.dart';

/// STUB milik Anggota 3 (T3b). Signature JANGAN diubah.
class HabitTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool done;
  final ValueChanged<bool>? onChanged;

  const HabitTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.done,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked),
      onTap: onChanged == null ? null : () => onChanged!(!done),
    );
  }
}
