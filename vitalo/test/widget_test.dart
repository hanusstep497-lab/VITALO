import 'package:flutter_test/flutter_test.dart';

import 'package:vitalo/main.dart';

void main() {
  testWidgets('Login membuka Home Dashboard', (tester) async {
    await tester.pumpWidget(const VitaloApp());
    await tester.pumpAndSettle();

    expect(find.text('Vitalo'), findsOneWidget);

    await tester.tap(find.text('Masuk dengan Google'));
    await tester.pumpAndSettle();

    expect(find.text('Halo, kamu siap?'), findsOneWidget);
  });

  testWidgets('Pindah tab ke Pengaturan menampilkan pengingat', (tester) async {
    await tester.pumpWidget(const VitaloApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Masuk dengan Google'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pengaturan'));
    await tester.pumpAndSettle();

    expect(find.text('Pengingat aktif'), findsOneWidget);
  });
}
