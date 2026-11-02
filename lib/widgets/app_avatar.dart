import 'package:flutter/material.dart';

/// STUB milik Anggota 3 (T3b). Signature JANGAN diubah.
class AppAvatar extends StatelessWidget {
  final String? imageAsset;
  final String initials;
  final double radius;

  const AppAvatar({
    super.key,
    this.imageAsset,
    required this.initials,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: radius, child: Text(initials));
  }
}
