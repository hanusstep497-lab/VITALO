import 'package:flutter/material.dart';

/// 4280 -> "4.280"
String fmtInt(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

/// Duration(7j 20m) -> "7j 20m"
String fmtDuration(Duration d) => '${d.inHours}j ${d.inMinutes.remainder(60)}m';

/// TimeOfDay -> "09:05"
String fmtTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
