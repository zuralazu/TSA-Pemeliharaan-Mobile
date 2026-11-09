import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tunassiakanugrah/auth/register_request.dart';

void main() {
  late Directory temporaryDirectory;
  late String logoPath;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'company-registration-test-',
    );
    logoPath = '${temporaryDirectory.path}${Platform.pathSeparator}logo.png';
    await File(logoPath).writeAsBytes([137, 80, 78, 71]);
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  test('builds the company registration multipart contract', () async {
    final request = await buildCompanyRegistrationRequest(
      uri: Uri.parse('https://api.example.test/api/register'),
      username: 'acme_admin',
      email: 'admin@acme.test',
      password: 'secure-pass-123',
      passwordConfirmation: 'secure-pass-123',
      companyName: 'Acme Fire Safety',
      companyPhone: '+6281234567890',
      companyAddress: 'Jl. Merdeka 10',
      contactName: 'Ayu',
      logoPath: logoPath,
    );

    expect(request.method, 'POST');
    expect(request.url, Uri.parse('https://api.example.test/api/register'));
    expect(request.headers['Accept'], 'application/json');
    expect(request.fields, {
      'username': 'acme_admin',
      'email': 'admin@acme.test',
      'password': 'secure-pass-123',
      'password_confirmation': 'secure-pass-123',
      'role': 'supervisor_umum',
      'company_name': 'Acme Fire Safety',
      'company_phone': '+6281234567890',
      'company_address': 'Jl. Merdeka 10',
      'contact_name': 'Ayu',
    });
    expect(request.files, hasLength(1));
    expect(request.files.single.field, 'logo');
    expect(request.files.single.filename, 'logo.png');
  });
}
