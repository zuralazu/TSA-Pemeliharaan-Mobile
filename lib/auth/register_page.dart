import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tunassiakanugrah/auth/register_request.dart';
import 'package:tunassiakanugrah/config/env.dart';
import 'package:tunassiakanugrah/core/constants/app_colors.dart';
import 'package:tunassiakanugrah/widgets/common/gradient_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const _blue = AppColors.authBlue;
  static const _gradient = [AppColors.authBlue, AppColors.authBlueLight];

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
  int _step = 0;
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

  void _nextStep() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _logoError = _logo == null ? 'Logo perusahaan wajib dipilih' : null;
    });
    if (!isFormValid || _logo == null) return;
    setState(() => _step = 1);
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

  // ── Form fields ───────────────────────────────────────────────────────────

  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
    floatingLabelStyle: const TextStyle(
      color: _blue,
      fontWeight: FontWeight.w600,
    ),
    errorStyle: const TextStyle(color: AppColors.bad, fontSize: 12),
    prefixIcon: Icon(icon, color: _blue, size: 22),
    filled: true,
    fillColor: AppColors.bgInput,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    border: _border(AppColors.borderInput),
    enabledBorder: _border(AppColors.borderInput),
    focusedBorder: _border(_blue, 2),
    errorBorder: _border(AppColors.bad),
    focusedErrorBorder: _border(AppColors.bad, 2),
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
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: _decoration(label, icon).copyWith(suffixIcon: suffixIcon),
    );
  }

  Widget _visibilityToggle(bool obscured, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.textSecondary,
      ),
    );
  }

  // ── Header on the gradient ────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 48,
          child: Navigator.canPop(context)
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                    ),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.aparAccent,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daftarkan Perusahaan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Buat akun supervisor untuk mulai mengelola pemeliharaan.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildStepper(),
      ],
    );
  }

  Widget _buildStepper() {
    Widget step(int index, String label) {
      final reached = _step >= index;
      final done = _step > index;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: reached
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: reached ? 1 : 0.5),
                width: 1.5,
              ),
            ),
            child: done
                ? const Icon(Icons.check_rounded, size: 16, color: _blue)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: reached ? _blue : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: reached ? 1 : 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        step(0, 'Perusahaan'),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: _step >= 1 ? 1 : 0.35),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        step(1, 'Supervisor'),
      ],
    );
  }

  // ── Card content ──────────────────────────────────────────────────────────

  Widget _buildStepTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _step == 0 ? 'Identitas Perusahaan' : 'Akun Supervisor Umum',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _step == 0 ? 'Langkah 1 dari 2' : 'Langkah 2 dari 2',
                style: const TextStyle(
                  color: _blue,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _step == 0
              ? 'Lengkapi profil perusahaan dan unggah logonya.'
              : 'Buat kredensial untuk supervisor perusahaan.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoPicker() {
    final hasError = _logoError != null;
    final tint = hasError ? AppColors.bad : _blue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('logo-picker-button'),
            onTap: _pickLogo,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: tint.withValues(alpha: hasError ? 0.6 : 0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderInput),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _logo == null
                          ? Icon(
                              Icons.add_photo_alternate_outlined,
                              key: const ValueKey('empty-logo'),
                              color: tint,
                              size: 28,
                            )
                          : Image.file(
                              File(_logo!.path),
                              key: ValueKey(_logo!.path),
                              fit: BoxFit.cover,
                              width: 64,
                              height: 64,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Logo Perusahaan',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _logo == null
                              ? 'Logo perusahaan wajib diunggah'
                              : 'Ketuk logo untuk menggantinya',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: tint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _logo == null ? 'Pilih logo' : 'Ganti',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              _logoError!,
              style: const TextStyle(color: AppColors.bad, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildCompanyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLogoPicker(),
        const SizedBox(height: 16),
        _field(
          key: const Key('company-name'),
          controller: _companyName,
          label: 'Nama Perusahaan',
          icon: Icons.business_outlined,
          validator: _required,
        ),
        const SizedBox(height: 12),
        _field(
          key: const Key('company-email'),
          controller: _companyEmail,
          label: 'Email Perusahaan',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: _validEmail,
        ),
        const SizedBox(height: 12),
        _field(
          key: const Key('company-phone'),
          controller: _companyPhone,
          label: 'Nomor Telepon',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: _required,
        ),
        const SizedBox(height: 12),
        _field(
          key: const Key('company-address'),
          controller: _companyAddress,
          label: 'Alamat Perusahaan',
          icon: Icons.location_on_outlined,
          validator: _required,
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        _field(
          key: const Key('contact-name'),
          controller: _contactName,
          label: 'Nama Penanggung Jawab',
          icon: Icons.person_outline,
          validator: _required,
        ),
      ],
    );
  }

  Widget _buildSupervisorStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _blue.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: _blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Akun ini akan mendapat akses Supervisor Umum.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _field(
          key: const Key('supervisor-username'),
          controller: _username,
          label: 'Username Supervisor',
          icon: Icons.account_circle_outlined,
          validator: _required,
        ),
        const SizedBox(height: 12),
        _field(
          key: const Key('register-password'),
          controller: _password,
          label: 'Password',
          icon: Icons.lock_outline,
          validator: _validPassword,
          obscureText: _obscurePassword,
          suffixIcon: _visibilityToggle(
            _obscurePassword,
            () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 12),
        _field(
          key: const Key('register-password-confirmation'),
          controller: _passwordConfirmation,
          label: 'Konfirmasi Password',
          icon: Icons.lock_reset_outlined,
          validator: _matchingPassword,
          obscureText: _obscureConfirmation,
          suffixIcon: _visibilityToggle(
            _obscureConfirmation,
            () => setState(() => _obscureConfirmation = !_obscureConfirmation),
          ),
        ),
      ],
    );
  }

  Widget _buildStepActions() {
    if (_step == 0) {
      return GradientButton(
        key: const Key('register-next'),
        label: 'Lanjutkan',
        icon: Icons.arrow_forward_rounded,
        colors: _gradient,
        onPressed: _nextStep,
        height: 52,
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: OutlinedButton(
            key: const Key('register-back'),
            onPressed: () => setState(() => _step = 0),
            style: OutlinedButton.styleFrom(
              foregroundColor: _blue,
              padding: EdgeInsets.zero,
              side: BorderSide(color: _blue.withValues(alpha: 0.4), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GradientButton(
            key: const Key('register-submit'),
            label: 'Buat Akun',
            icon: Icons.check_circle_rounded,
            colors: _gradient,
            onPressed: _register,
            isLoading: _isLoading,
            height: 52,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _blue,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _gradient,
            ),
          ),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStepTitle(),
                          const SizedBox(height: 20),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 240),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.04, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey(_step),
                                child: _step == 0
                                    ? _buildCompanyStep()
                                    : _buildSupervisorStep(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildStepActions(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        key: const Key('register-to-login'),
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: 'Sudah punya akun? ',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            children: const [
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
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
        ),
      ),
    );
  }
}
