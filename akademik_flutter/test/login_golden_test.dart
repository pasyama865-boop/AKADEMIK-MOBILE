import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:akademik_flutter/screens/login.dart';

void main() {
  testWidgets(
    'Golden Test: Tampilan halaman LoginScreen sesuai standar (UI Regresi)',
    (WidgetTester tester) async {
      // Setel ukuran viewport simulasi layaknya perangkat seluler Portrait
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3.0;

      // Build widget LoginScreen terbungkus MaterialApp
      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: LoginScreen(),
        ),
      );

      // Tunggu animasi / asset memuat seutuhnya
      await tester.pumpAndSettle();

      // Pastikan tidak ada perubahan layout (Visual Regression)
      await expectLater(
        find.byType(LoginScreen),
        matchesGoldenFile('goldens/login_screen.png'),
      );

      // Kembalikan ukuran layar simulasi ke default
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );
}
