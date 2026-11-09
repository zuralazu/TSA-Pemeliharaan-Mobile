import 'package:http/http.dart' as http;

Future<http.MultipartRequest> buildCompanyRegistrationRequest({
  required Uri uri,
  required String username,
  required String email,
  required String password,
  required String passwordConfirmation,
  required String companyName,
  required String companyPhone,
  required String companyAddress,
  required String contactName,
  required String logoPath,
}) async {
  final request = http.MultipartRequest('POST', uri)
    ..headers['Accept'] = 'application/json'
    ..fields.addAll({
      'username': username,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'role': 'supervisor_umum',
      'company_name': companyName,
      'company_phone': companyPhone,
      'company_address': companyAddress,
      'contact_name': contactName,
    })
    ..files.add(await http.MultipartFile.fromPath('logo', logoPath));

  return request;
}
