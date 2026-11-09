import 'package:flutter/material.dart' show PageView, Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tunassiakanugrah/auth/login_page.dart';
import 'package:tunassiakanugrah/auth/register_page.dart';
import 'package:tunassiakanugrah/main.dart';

void setViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('shows the introduction on first launch', (tester) async {
    setViewport(tester);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AplikasiSaya());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Selamat datang di APK Tracker'), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('shows Register and Login on later launches', (tester) async {
    setViewport(tester);
    SharedPreferences.setMockInitialValues({'intro_seen': true});

    await tester.pumpWidget(const AplikasiSaya());
    await tester.pumpAndSettle();

    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  for (final action in ['Register', 'Login']) {
    testWidgets('saves intro completion before opening $action', (tester) async {
      setViewport(tester);
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const AplikasiSaya());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.drag(find.byType(PageView), const Offset(-1200, 0));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('intro_seen'), isTrue);
      expect(
        find.byType(action == 'Register' ? RegisterPage : LoginPage),
        findsOneWidget,
      );
    });
  }
}
