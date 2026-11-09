// lib/pemeliharaan/form_laporan.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunassiakanugrah/auth/login_page.dart';
import 'package:tunassiakanugrah/config/env.dart';
import 'package:tunassiakanugrah/core/utils/date_formatter.dart';
import 'package:tunassiakanugrah/core/utils/report_photo_url.dart';
import 'package:tunassiakanugrah/pemeliharaan/widgets/form_fields/apar_fields.dart';
import 'package:tunassiakanugrah/pemeliharaan/widgets/form_fields/hydrant_fields.dart';

class FormulirLaporanHalaman extends StatefulWidget {
  final String idAlat;
  final String tipeBarang;
  final String lokasiAlat;
  final String qrCodeData;
  final String namaAlat;

  FormulirLaporanHalaman({
    Key? key,
    required this.idAlat,
    required this.tipeBarang,
    required this.lokasiAlat,
    required this.qrCodeData,
    required this.namaAlat,
  }) : super(key: key);

  @override
  _FormulirLaporanHalamanState createState() => _FormulirLaporanHalamanState();
}

class _FormulirLaporanHalamanState extends State<FormulirLaporanHalaman>
    with TickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────────────────────────────
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _catatanTindakanController =
      TextEditingController();

  // ── State ─────────────────────────────────────────────────────────────────
  String? _lokasiDropdownValue;
  File? _imageFile;
  String? _kondisiFisikTerpilih;
  String? _tindakanTerpilih;

  // Field khusus APAR
  String? _selangTerpilih;
  String? _pressureGaugeTerpilih;
  String? _safetyPinTerpilih;

  // Field khusus HYDRANT
  String? _tekananAirTerpilih;
  String? _katupTerpilih;
  String? _selangHydrantTerpilih;

  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _lokasiAwalAlat;

  Map<String, dynamic>? _lastInspection;
  bool _isLoadingInspection = true;

  // ── Getters ───────────────────────────────────────────────────────────────
  final List<String> _daftarLokasi = [
    'LANTAI-1',
    'LANTAI-2',
    'LANTAI-3',
    'LANTAI-4',
  ];

  bool get isAPAR => _detectTipeBarang() == 'APAR';
  bool get isHYDRANT => _detectTipeBarang() == 'HYDRANT';

  Color get _accent =>
      isAPAR ? const Color(0xFFE04B3E) : const Color(0xFF1E6FBF);
  Color get _accentSoft =>
      isAPAR ? const Color(0xFFFDEDEB) : const Color(0xFFE9F1FA);

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _lokasiAwalAlat = widget.lokasiAlat;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _tanggalController.text = DateFormatter.formatYMD(DateTime.now());
    _lokasiDropdownValue = _daftarLokasi.contains(widget.lokasiAlat)
        ? widget.lokasiAlat
        : _daftarLokasi.first;

    final type = _detectTipeBarang();
    if (type == 'UNKNOWN') {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showErrorDialog());
    } else {
      _animationController.forward();
    }

    _fetchLastInspection();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tanggalController.dispose();
    _catatanTindakanController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _detectTipeBarang() {
    final upperId = widget.idAlat.toUpperCase();
    final upperTipe = widget.tipeBarang.toUpperCase();
    if (upperId.contains('APACO') ||
        upperId.contains('APAR') ||
        upperTipe.contains('APAR'))
      return 'APAR';
    if (upperId.contains('HYD') ||
        upperId.contains('HYDRANT') ||
        upperTipe.contains('HYDRANT'))
      return 'HYDRANT';
    return 'UNKNOWN';
  }

  // ── API calls ─────────────────────────────────────────────────────────────

  Future<void> _fetchLastInspection() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      setState(() => _isLoadingInspection = false);
      return;
    }

    final response = await http.get(
      Uri.parse('${Env.baseUrl}/api/laporan-apk/terakhir/${widget.qrCodeData}'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      if (data != null) {
        setState(() {
          _lastInspection = data;
          _kondisiFisikTerpilih = data['kondisi_fisik'];
          _tindakanTerpilih = data['tindakan'];
          _catatanTindakanController.text = data['catatan_tindakan'] ?? '';
          _selangTerpilih = data['selang'];
          _pressureGaugeTerpilih = data['pressure_gauge'];
          _safetyPinTerpilih = data['safety_pin'];
          _tekananAirTerpilih = data['tekanan_air'];
          _katupTerpilih = data['katup'];
          _selangHydrantTerpilih = data['selang_hydrant'];
          if (data['lokasi_alat'] != null) {
            _lokasiAwalAlat = data['lokasi_alat'];
          }
        });
      }
    }

    setState(() => _isLoadingInspection = false);
  }

  Future<void> _kirimLaporan() async {
    setState(() => _isLoading = true);

    final tanggal = _tanggalController.text;
    final lokasi = _lokasiDropdownValue ?? '';
    final kondisiFisik = _kondisiFisikTerpilih ?? '';
    final tindakan = _tindakanTerpilih ?? '';
    final catatanTindakan = _catatanTindakanController.text.trim();

    if (tanggal.isEmpty ||
        lokasi.isEmpty ||
        kondisiFisik.isEmpty ||
        tindakan.isEmpty) {
      _showSnackBar('Semua field wajib diisi!', Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    if (isAPAR && _tindakanTerpilih == 'Ganti' && catatanTindakan.isEmpty) {
      _showSnackBar(
        'Catatan tindakan wajib diisi untuk APAR jika memilih Ganti!',
        Colors.red,
      );
      setState(() => _isLoading = false);
      return;
    }

    if (isHYDRANT && _tindakanTerpilih == 'Repair' && catatanTindakan.isEmpty) {
      _showSnackBar(
        'Catatan tindakan wajib diisi untuk HYDRANT jika memilih Repair!',
        Colors.red,
      );
      setState(() => _isLoading = false);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      _showSnackBar('Sesi login habis. Silakan login ulang.', Colors.red);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${Env.baseUrl}/api/laporan-apk'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll({
      'qr_code_data': widget.qrCodeData.trim(),
      'tanggal_inspeksi': tanggal,
      'lokasi_alat': lokasi,
      'kondisi_fisik': kondisiFisik,
      'tindakan': tindakan,
      'catatan_tindakan': catatanTindakan,
      'selang': isAPAR ? (_selangTerpilih ?? '') : '',
      'pressure_gauge': isAPAR ? (_pressureGaugeTerpilih ?? '') : '',
      'safety_pin': isAPAR ? (_safetyPinTerpilih ?? '') : '',
      'tekanan_air': isHYDRANT ? (_tekananAirTerpilih ?? '') : '',
      'katup': isHYDRANT ? (_katupTerpilih ?? '') : '',
      'selang_hydrant': isHYDRANT ? (_selangHydrantTerpilih ?? '') : '',
    });

    if (_imageFile != null) {
      final fileName = _imageFile!.path.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          _imageFile!.path,
          filename: fileName,
        ),
      );
    }

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = json.decode(respStr);
        _showSnackBar(
          data['message'] ?? 'Laporan berhasil dikirim.',
          Colors.green,
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (route) => false,
        );
      } else {
        final data = json.decode(respStr);
        _showSnackBar(data['message'] ?? 'Gagal mengirim laporan.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e', Colors.red);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  // ── Dialogs & Snackbar ────────────────────────────────────────────────────

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        elevation: 10,
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text(
              'Jenis Tidak Didukung',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Barang ini tidak sesuai dengan jenis APAR dan HYDRANT yang didukung sistem.',
          style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red[700],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Kembali',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String pesan, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              warna == Colors.green ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(pesan, style: const TextStyle(fontSize: 16))),
          ],
        ),
        backgroundColor: warna,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Widget builders ───────────────────────────────────────────────────────

  Widget _sectionCard({required Widget child, EdgeInsets? margin}) => Container(
    margin: margin ?? const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFEDF0F5)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );

  Widget _buildModernChoiceChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _accent : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? _accent : const Color(0xFFE2E8F0),
            width: 1.4,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionGroup(
    String title,
    List<String> options,
    String? selectedValue,
    Function(String) onChanged, {
    Color? accentColor,
  }) {
    final color = accentColor ?? _accent;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options
                .map(
                  (option) => _buildModernChoiceChip(
                    option,
                    selectedValue == option,
                    () => setState(() => onChanged(option)),
                  ),
                )
                .toList(),
          ),
          // Catatan tindakan muncul jika pilih Ganti / Repair
          if (title == 'Tindakan yang Diperlukan' &&
              ((isAPAR && _tindakanTerpilih == 'Ganti') ||
                  (isHYDRANT && _tindakanTerpilih == 'Repair')))
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: TextField(
                controller: _catatanTindakanController,
                maxLines: 3,
                style: const TextStyle(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Catatan tindakan...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13.5,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _accent, width: 1.4),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String title, IconData icon, Widget child) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _accentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _accent, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildFotoSection() {
    Widget content;

    if (_imageFile != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          _imageFile!,
          height: 190,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (_lastInspection != null &&
        _lastInspection!['foto'] != null &&
        _lastInspection!['foto'].toString().isNotEmpty) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          reportPhotoUrl(_lastInspection!['foto'], Env.baseUrl),
          height: 190,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 190,
              color: const Color(0xFFF8FAFC),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: _accent,
                  ),
                ),
              ),
            );
          },
          errorBuilder: (ctx, error, stackTrace) => Container(
            height: 190,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Text(
                'Foto tidak dapat ditampilkan',
                style: TextStyle(color: Colors.grey[500], fontSize: 12.5),
              ),
            ),
          ),
        ),
      );
    } else {
      content = Container(
        height: 190,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 32),
            const SizedBox(height: 8),
            Text(
              'Belum ada foto',
              style: TextStyle(color: Colors.grey[500], fontSize: 12.5),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        content,
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickImage,
            icon: Icon(Icons.camera_alt_rounded, size: 18, color: _accent),
            label: Text(
              'Ambil Foto',
              style: TextStyle(fontWeight: FontWeight.w700, color: _accent),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              side: BorderSide(color: _accent, width: 1.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoAlat(String detectedType) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isAPAR
                      ? Icons.local_fire_department_rounded
                      : Icons.water_drop_rounded,
                  color: _accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.namaAlat,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              if (_lastInspection != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    DateFormatter.inspectionAge(
                      _lastInspection!['tanggal_inspeksi'],
                    ),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB7791F),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0xFFEDF0F5)),
          const SizedBox(height: 14),
          _buildInfoRow('Tipe', detectedType),
          _buildInfoRow('Lokasi', _lokasiAwalAlat ?? '-'),
          _buildInfoRow('QR Code', widget.qrCodeData),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final detectedType = _detectTipeBarang();

    if (detectedType == 'UNKNOWN') {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: Center(child: CircularProgressIndicator(color: _accent)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Form Pelaporan $detectedType',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: Colors.white,
          ),
        ),
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Info alat ───────────────────────────────────────────────
              _buildInfoAlat(detectedType),

              // ── Tanggal inspeksi ─────────────────────────────────────────
              _buildInputField(
                'Tanggal Inspeksi',
                Icons.calendar_today_rounded,
                TextField(
                  controller: _tanggalController,
                  readOnly: true,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),

              // ── Lokasi perangkat ─────────────────────────────────────────
              _buildInputField(
                'Lokasi Perangkat',
                Icons.location_on_rounded,
                DropdownButtonFormField<String>(
                  value: _lokasiDropdownValue,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  items: _daftarLokasi
                      .map(
                        (lok) => DropdownMenuItem(value: lok, child: Text(lok)),
                      )
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _lokasiDropdownValue = val!),
                ),
              ),

              // ── Foto bukti ───────────────────────────────────────────────
              _buildInputField(
                'Foto Bukti',
                Icons.camera_alt_rounded,
                _buildFotoSection(),
              ),

              // ── Kondisi fisik ────────────────────────────────────────────
              _buildOptionGroup(
                'Kondisi Fisik',
                const ['Good', 'Korosif', 'Bad'],
                _kondisiFisikTerpilih,
                (val) => _kondisiFisikTerpilih = val,
                accentColor: const Color(0xFFF59E0B),
              ),

              // ── Field khusus APAR ────────────────────────────────────────
              if (isAPAR)
                AparFields(
                  selangTerpilih: _selangTerpilih,
                  pressureGaugeTerpilih: _pressureGaugeTerpilih,
                  safetyPinTerpilih: _safetyPinTerpilih,
                  accentColor: _accent,
                  accentSoft: _accentSoft,
                  onSelangChanged: (val) =>
                      setState(() => _selangTerpilih = val),
                  onPressureGaugeChanged: (val) =>
                      setState(() => _pressureGaugeTerpilih = val),
                  onSafetyPinChanged: (val) =>
                      setState(() => _safetyPinTerpilih = val),
                ),

              // ── Field khusus HYDRANT ─────────────────────────────────────
              if (isHYDRANT)
                HydrantFields(
                  tekananAirTerpilih: _tekananAirTerpilih,
                  katupTerpilih: _katupTerpilih,
                  selangHydrantTerpilih: _selangHydrantTerpilih,
                  accentColor: _accent,
                  accentSoft: _accentSoft,
                  onTekananAirChanged: (val) =>
                      setState(() => _tekananAirTerpilih = val),
                  onKatupChanged: (val) => setState(() => _katupTerpilih = val),
                  onSelangHydrantChanged: (val) =>
                      setState(() => _selangHydrantTerpilih = val),
                ),

              // ── Tindakan ─────────────────────────────────────────────────
              _buildOptionGroup(
                'Tindakan yang Diperlukan',
                isAPAR
                    ? const ['Isi Ulang', 'Good', 'Ganti']
                    : const ['Good', 'Broken', 'Repair'],
                _tindakanTerpilih,
                (val) => _tindakanTerpilih = val,
              ),

              // ── Tombol kirim ─────────────────────────────────────────────
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _kirimLaporan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.4,
                          ),
                        )
                      : const Text(
                          'Kirim Laporan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
