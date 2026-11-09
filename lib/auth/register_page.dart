import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tunassiakanugrah/auth/register_request.dart';
import 'package:tunassiakanugrah/config/env.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const _blue = Color(0xFF1976D2);
  static const _pageColor = Color(0xFFF3F7FC);

  final _formKey = GlobalKey<FormState>();
  final _companyName = TextEditingController();
  final _companyEmail = TextEditingController();
  final _companyPhone = TextEditingController();
  final _companyAddress = TextEditingController();
  final _contactName = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirmation = TextEditingController();

  XFile? _logo;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  String? _logoError;

  @override
  void dispose() {
    _companyName.dispose();
    _companyEmail.dispose();
    _companyPhone.dispose();
    _companyAddress.dispose();
    _contactName.dispose();
    _username.dispose();
    _password.dispose();
    _passwordConfirmation.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Bagian ini wajib diisi' : null;

  String? _validEmail(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())) {
      return 'Masukkan email yang valid';
    }
    return null;
  }

  String? _validPassword(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;
    if (value!.length < 8) return 'Password minimal 8 karakter';
    return null;
  }

  String? _matchingPassword(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;
    if (value != _password.text) return 'Konfirmasi password tidak cocok';
    return null;
  }

  Future<void> _pickLogo() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (!mounted || image == null) return;

    setState(() {
      _logo = image;
      _logoError = null;
    });
  }

  Future<void> _register() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _logoError = _logo == null ? 'Logo perusahaan wajib dipilih' : null;
    });
    if (!isFormValid || _logo == null) return;

    setState(() => _isLoading = true);

    try {
      final request = await buildCompanyRegistrationRequest(
        uri: Uri.parse('${Env.baseUrl}/api/register'),
        username: _username.text.trim(),
        email: _companyEmail.text.trim(),
        password: _password.text,
        passwordConfirmation: _passwordConfirmation.text,
        companyName: _companyName.text.trim(),
        companyPhone: _companyPhone.text.trim(),
        companyAddress: _companyAddress.text.trim(),
        contactName: _contactName.text.trim(),
        logoPath: _logo!.path,
      );
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Registrasi berhasil'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        final message = _validationMessage(errorData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      } else if (response.statusCode == 302) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error 302: Periksa routing atau konfigurasi endpoint server.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registrasi gagal (${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat terhubung ke server. Coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _validationMessage(dynamic errorData) {
    if (errorData is Map<String, dynamic>) {
      final errors = errorData['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) return value.first.toString();
          if (value is String) return value;
        }
      }
      if (errorData['message'] is String) return errorData['message'];
    }
    return 'Data pendaftaran belum valid. Periksa kembali isian Anda.';
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: _blue),
    filled: true,
    fillColor: const Color(0xFFF9FBFE),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFDCE6F1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFDCE6F1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _blue, width: 1.5),
    ),
  );

  Widget _field({
    required Key key,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      decoration: _decoration(label, icon).copyWith(suffixIcon: suffixIcon),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 14, top: 8),
    child: Text(
      title,
      style: const TextStyle(
        color: Color(0xFF18324F),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageColor,
      appBar: AppBar(
        backgroundColor: _pageColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF18324F)),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D5EAA), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          color: Color(0xFFC62828),
                          size: 34,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daftarkan Perusahaan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Buat akun supervisor untuk mulai mengelola pemeliharaan.',
                              style: TextStyle(
                                color: Colors.white,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x100D3B66),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sectionTitle('Identitas Perusahaan'),
                      Center(
                        child: Column(
                          children: [
                            InkWell(
                              key: const Key('logo-picker-button'),
                              onTap: _pickLogo,
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                width: 116,
                                height: 116,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF3FC),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFC9DDF2),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: _logo == null
                                    ? const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate_outlined,
                                            color: _blue,
                                            size: 34,
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'Tambah logo',
                                            style: TextStyle(
                                              color: _blue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Image.file(
                                        File(_logo!.path),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              _logo == null
                                  ? 'Logo perusahaan *'
                                  : 'Ketuk untuk mengganti logo',
                              style: TextStyle(
                                color: _logoError == null
                                    ? const Color(0xFF66788A)
                                    : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                            if (_logoError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _logoError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _field(
                        key: const Key('company-name'),
                        controller: _companyName,
                        label: 'Nama Perusahaan',
                        icon: Icons.business_outlined,
                        validator: _required,
                      ),
                      const SizedBox(height: 14),
                      _field(
                        key: const Key('company-email'),
                        controller: _companyEmail,
                        label: 'Email Perusahaan',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validEmail,
                      ),
                      const SizedBox(height: 14),
                      _field(
                        key: const Key('company-phone'),
                        controller: _companyPhone,
                        label: 'Nomor Telepon',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: _required,
                      ),
                      const SizedBox(height: 14),
                      _field(
                        key: const Key('company-address'),
                        controller: _companyAddress,
                        label: 'Alamat Perusahaan',
                        icon: Icons.location_on_outlined,
                        validator: _required,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      _field(
                        key: const Key('contact-name'),
                        controller: _contactName,
                        label: 'Nama Penanggung Jawab',
                        icon: Icons.person_outline,
                        validator: _required,
                      ),
                      _sectionTitle('Akun Supervisor Umum'),
                      _field(
                        key: const Key('supervisor-username'),
                        controller: _username,
                        label: 'Username Supervisor',
                        icon: Icons.account_circle_outlined,
                        validator: _required,
                      ),
                      const SizedBox(height: 14),
                      _field(
                        key: const Key('register-password'),
                        controller: _password,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        validator: _validPassword,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _field(
                        key: const Key('register-password-confirmation'),
                        controller: _passwordConfirmation,
                        label: 'Konfirmasi Password',
                        icon: Icons.lock_reset_outlined,
                        validator: _matchingPassword,
                        obscureText: _obscureConfirmation,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscureConfirmation = !_obscureConfirmation,
                          ),
                          icon: Icon(
                            _obscureConfirmation
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          key: const Key('register-submit'),
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Daftar Perusahaan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: TextButton(
                    key: const Key('register-to-login'),
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Sudah punya akun? ',
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
