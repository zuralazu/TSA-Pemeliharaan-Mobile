import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunassiakanugrah/auth/login_page.dart';
import 'package:tunassiakanugrah/auth/register_page.dart';

Widget registrationTestApp({required Widget home}) {
  return MaterialApp(
    home: home,
    routes: {'/login': (_) => LoginPage(), '/register': (_) => RegisterPage()},
  );
}

void main() {
  testWidgets('shows company identity fields and requires a logo', (
    tester,
  ) async {
    await tester.pumpWidget(registrationTestApp(home: RegisterPage()));

    for (final label in [
      'Nama Perusahaan',
      'Email Perusahaan',
      'Nomor Telepon',
      'Alamat Perusahaan',
      'Nama Penanggung Jawab',
      'Username Supervisor',
      'Password',
      'Konfirmasi Password',
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.ensureVisible(find.byKey(const Key('register-submit')));
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Logo perusahaan wajib dipilih'), findsOneWidget);
  });

  testWidgets('rejects invalid company email and mismatched passwords', (
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
    await tester.ensureVisible(find.byKey(const Key('register-submit')));
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Masukkan email yang valid'), findsOneWidget);
    expect(find.text('Konfirmasi password tidak cocok'), findsOneWidget);
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
