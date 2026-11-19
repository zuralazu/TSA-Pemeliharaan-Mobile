import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunassiakanugrah/auth/login_page.dart';
import 'package:tunassiakanugrah/auth/register_page.dart';

const _imagePickerChannel = MethodChannel('plugins.flutter.io/image_picker');

Widget registrationTestApp({required Widget home}) {
  return MaterialApp(
    home: home,
    routes: {'/login': (_) => LoginPage(), '/register': (_) => RegisterPage()},
  );
}

void main() {
  late Directory temporaryDirectory;
  late String logoPath;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'company-registration-widget-test-',
    );
    logoPath = '${temporaryDirectory.path}${Platform.pathSeparator}logo.png';
    await File(logoPath).writeAsBytes(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+c0T8AAAAASUVORK5CYII=',
      ),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          _imagePickerChannel,
          (call) async => call.method == 'pickImage' ? logoPath : null,
        );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_imagePickerChannel, null);
    await temporaryDirectory.delete(recursive: true);
  });

  testWidgets(
    'starts with company details and keeps account fields for step 2',
    (tester) async {
      await tester.pumpWidget(registrationTestApp(home: RegisterPage()));

      expect(find.text('Langkah 1 dari 2'), findsOneWidget);
      expect(find.text('Nama Perusahaan'), findsOneWidget);
      expect(find.text('Username Supervisor'), findsNothing);
      expect(find.byKey(const Key('register-next')), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('register-next')));
      await tester.tap(find.byKey(const Key('register-next')));
      await tester.pumpAndSettle();

      expect(find.text('Bagian ini wajib diisi'), findsAtLeastNWidgets(1));
      expect(find.text('Logo perusahaan wajib dipilih'), findsOneWidget);
      expect(find.text('Langkah 1 dari 2'), findsOneWidget);
    },
  );

  testWidgets('validates company email before moving to account step', (
    tester,
  ) async {
    await tester.pumpWidget(registrationTestApp(home: RegisterPage()));

    await tester.enterText(
      find.byKey(const Key('company-name')),
      'Acme Safety',
    );
    await tester.enterText(find.byKey(const Key('company-email')), 'invalid');
    await tester.enterText(
      find.byKey(const Key('company-phone')),
      '08123456789',
    );
    await tester.enterText(
      find.byKey(const Key('company-address')),
      'Jl. Merdeka',
    );
    await tester.enterText(find.byKey(const Key('contact-name')), 'Ayu');
    await tester.ensureVisible(find.byKey(const Key('logo-picker-button')));
    await tester.tap(find.byKey(const Key('logo-picker-button')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('register-next')));
    await tester.tap(find.byKey(const Key('register-next')));
    await tester.pumpAndSettle();

    expect(find.text('Masukkan email yang valid'), findsOneWidget);
    expect(find.text('Username Supervisor'), findsNothing);
  });

  testWidgets('moves between steps and validates account passwords', (
    tester,
  ) async {
    await tester.pumpWidget(registrationTestApp(home: RegisterPage()));

    await tester.enterText(
      find.byKey(const Key('company-name')),
      'Acme Safety',
    );
    await tester.enterText(
      find.byKey(const Key('company-email')),
      'admin@acme.test',
    );
    await tester.enterText(
      find.byKey(const Key('company-phone')),
      '08123456789',
    );
    await tester.enterText(
      find.byKey(const Key('company-address')),
      'Jl. Merdeka',
    );
    await tester.enterText(find.byKey(const Key('contact-name')), 'Ayu');
    await tester.ensureVisible(find.byKey(const Key('logo-picker-button')));
    await tester.tap(find.byKey(const Key('logo-picker-button')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('register-next')));
    await tester.tap(find.byKey(const Key('register-next')));
    await tester.pumpAndSettle();

    expect(find.text('Langkah 2 dari 2'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('supervisor-username')),
      'acme_admin',
    );
    await tester.enterText(
      find.byKey(const Key('register-password')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const Key('register-password-confirmation')),
      'password456',
    );
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi password tidak cocok'), findsOneWidget);
    await tester.tap(find.byKey(const Key('register-back')));
    await tester.pumpAndSettle();
    expect(find.text('Langkah 1 dari 2'), findsOneWidget);
    expect(find.text('Acme Safety'), findsOneWidget);
  });

  testWidgets('register link on Login opens the company form', (tester) async {
    await tester.pumpWidget(registrationTestApp(home: LoginPage()));

    await tester.ensureVisible(find.byKey(const Key('login-to-register')));
    await tester.tap(find.byKey(const Key('login-to-register')));
    await tester.pumpAndSettle();

    expect(find.text('Nama Perusahaan'), findsOneWidget);
  });

  testWidgets('login link on Register opens Login', (tester) async {
    await tester.pumpWidget(registrationTestApp(home: RegisterPage()));

    await tester.ensureVisible(find.byKey(const Key('register-to-login')));
    await tester.tap(find.byKey(const Key('register-to-login')));
    await tester.pumpAndSettle();

    expect(find.text('Selamat Datang'), findsOneWidget);
  });
}
