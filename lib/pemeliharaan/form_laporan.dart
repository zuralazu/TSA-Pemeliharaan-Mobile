// lib/pemeliharaan/form_laporan.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunassiakanugrah/auth/login_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tunassiakanugrah/config/env.dart';

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
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _catatanTindakanController = TextEditingController();

  String? _lokasiDropdownValue;
  File? _imageFile;

  String? _kondisiFisikTerpilih;
  String? _tindakanTerpilih;

  // Field khusus APAR
  String? _selangTerpilih;
  String? _pressureGaugeTerpilih;
  String? _safetyPinTerpilih;

  bool _isLoading = false;

  bool get isAPAR => _detectTipeBarang() == 'APAR';
  bool get isHYDRANT => _detectTipeBarang() == 'HYDRANT';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _lokasiAwalAlat;

  final List<String> _daftarLokasi = ['LANTAI-1', 'LANTAI-2', 'LANTAI-3', 'LANTAI-4'];

  Map<String, dynamic>? _lastInspection;
  bool _isLoadingInspection = true;

  // ─── WARNA AKSEN SESUAI TIPE ────────────────────────────────────────────
  Color get _accent => isAPAR ? const Color(0xFFE04B3E) : const Color(0xFF1E6FBF);
  Color get _accentSoft => isAPAR ? const Color(0xFFFDEDEB) : const Color(0xFFE9F1FA);

  String _detectTipeBarang() {
    final upperId = widget.idAlat.toUpperCase();
    final upperTipe = widget.tipeBarang.toUpperCase();

    if (upperId.contains('APACO') || upperId.contains('APAR') || upperTipe.contains('APAR')) {
      return 'APAR';
    }

    if (upperId.contains('HYD') || upperId.contains('HYDRANT') || upperTipe.contains('HYDRANT')) {
      return 'HYDRANT';
    }

    return 'UNKNOWN';
  }

  String _inspectionAge(String tanggal) {
    final last = DateTime.parse(tanggal);
    final diff = DateTime.now().difference(last).inDays;
    return '$diff hari lalu';
  }

  String _buildFotoUrl(String foto) {
    if (foto.isEmpty) return '';

    // kalau backend sudah kirim full URL
    if (foto.startsWith('http')) {
      return foto;
    }

    // ambil nama file-nya aja, route /foto-laporan/{filename}
    // otomatis nambahin folder foto_laporan/ di belakang layar
    final filename = foto.split('/').last;
    return '${Env.baseUrl}/foto-laporan/$filename';
  }

  @override
  void initState() {
    super.initState();
    _lokasiAwalAlat = widget.lokasiAlat;

    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );

    _tanggalController.text = _formatDate(DateTime.now());
    _lokasiDropdownValue = _daftarLokasi.contains(widget.lokasiAlat)
        ? widget.lokasiAlat
        : _daftarLokasi.first;

    String type = _detectTipeBarang();
    if (type == 'UNKNOWN') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog();
      });
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

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          elevation: 10,
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Jenis Tidak Didukung',
                style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                ),
              ),
            ],
          ),
          content: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Barang ini tidak sesuai dengan jenis APAR dan HYDRANT yang didukung sistem.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
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
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Kembali', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _kirimLaporan() async {
    setState(() => _isLoading = true);

    final String tanggal = _tanggalController.text;
    final String lokasi = _lokasiDropdownValue ?? '';
    final String kondisiFisik = _kondisiFisikTerpilih ?? '';
    final String tindakan = _tindakanTerpilih ?? '';
    final String catatanTindakan = _catatanTindakanController.text.trim();
    final bool isAPAR = _detectTipeBarang() == 'APAR';

    if (tanggal.isEmpty || lokasi.isEmpty || kondisiFisik.isEmpty || tindakan.isEmpty) {
      _showSnackBar('Semua field wajib diisi!', Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    if (isAPAR && _tindakanTerpilih == 'Ganti' && catatanTindakan.isEmpty) {
      _showSnackBar('Catatan tindakan wajib diisi untuk APAR jika memilih Ganti!', Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    if (isHYDRANT && _tindakanTerpilih == 'Repair' && catatanTindakan.isEmpty) {
      _showSnackBar('Catatan tindakan wajib diisi untuk HYDRANT jika memilih Repair!', Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null) {
      _showSnackBar('Sesi login habis. Silakan login ulang.', Colors.red);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
      return;
    }

    final uri = Uri.parse('${Env.baseUrl}/api/laporan-apk');
    final request = http.MultipartRequest('POST', uri);
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
    });

    if (_imageFile != null) {
      final fileName = _imageFile!.path.split('/').last;
      request.files.add(await http.MultipartFile.fromPath('foto', _imageFile!.path, filename: fileName));
    }

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = json.decode(respStr);
        _showSnackBar(data['message'] ?? 'Laporan berhasil dikirim.', Colors.green);
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

  Future<void> _fetchLastInspection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null) {
      return;
    }

    final response = await http.get(
      Uri.parse(
        '${Env.baseUrl}/api/laporan-apk/terakhir/${widget.qrCodeData}',
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final data = jsonData['data'];

      if (data != null) {
        setState(() {
          _lastInspection = data;

          _kondisiFisikTerpilih = data['kondisi_fisik'];
          _tindakanTerpilih = data['tindakan'];
          _catatanTindakanController.text = data['catatan_tindakan'] ?? '';

          _selangTerpilih = data['selang'];
          _pressureGaugeTerpilih = data['pressure_gauge'];
          _safetyPinTerpilih = data['safety_pin'];

          if (data['lokasi_alat'] != null) {
            _lokasiAwalAlat = data['lokasi_alat'];
          }
        });
      }
    }

    setState(() => _isLoadingInspection = false);
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
            SizedBox(width: 12),
            Expanded(child: Text(pesan, style: TextStyle(fontSize: 16))),
          ],
        ),
        backgroundColor: warna,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  // ─── CHIP PILIHAN (redesign) ────────────────────────────────────────────
  Widget _buildModernChoiceChip(String label, bool isSelected, VoidCallback onTap) {
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

  // ─── CARD WRAPPER (redesign, flat) ──────────────────────────────────────
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

  Widget _buildOptionGroup(String title, List<String> options, String? selectedValue, Function(String) onChanged, {Color? accentColor}) {
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
            children: options.map((option) {
              return _buildModernChoiceChip(
                option,
                selectedValue == option,
                    () => setState(() => onChanged(option)),
              );
            }).toList(),
          ),
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
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
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

  Widget _buildCompactOptionGroup(String title, List<String> options, String? selectedValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              return _buildModernChoiceChip(
                option,
                selectedValue == option,
                    () => setState(() => onChanged(option)),
              );
            }).toList(),
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

    // 1️⃣ FOTO BARU (PRIORITAS)
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
    }
    // 2️⃣ FOTO DARI INSPEKSI TERAKHIR
    else if (_lastInspection != null &&
        _lastInspection!['foto'] != null &&
        _lastInspection!['foto'].toString().isNotEmpty) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          _buildFotoUrl(_lastInspection!['foto']),
          height: 190,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 190,
              color: const Color(0xFFF8FAFC),
              child: Center(
                child: SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: _accent),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
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
            );
          },
        ),
      );
    }
    // 3️⃣ BELUM ADA FOTO SAMA SEKALI
    else {
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
            Text('Belum ada foto',
                style: TextStyle(color: Colors.grey[500], fontSize: 12.5)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String detectedType = _detectTipeBarang();

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
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: Colors.white),
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
              // ── Info Alat + badge inspeksi terakhir ──────────────────────
              _sectionCard(
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
                            isAPAR ? Icons.local_fire_department_rounded : Icons.water_drop_rounded,
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7E6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _inspectionAge(_lastInspection!['tanggal_inspeksi']),
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
              ),

              _buildInputField(
                'Tanggal Inspeksi',
                Icons.calendar_today_rounded,
                TextField(
                  controller: _tanggalController,
                  readOnly: true,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                ),
              ),

              _buildInputField(
                'Lokasi Perangkat',
                Icons.location_on_rounded,
                DropdownButtonFormField<String>(
                  value: _lokasiDropdownValue,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                  items: _daftarLokasi.map((lok) {
                    return DropdownMenuItem(value: lok, child: Text(lok));
                  }).toList(),
                  onChanged: (val) => setState(() => _lokasiDropdownValue = val!),
                ),
              ),

              _buildInputField(
                'Foto Bukti',
                Icons.camera_alt_rounded,
                _buildFotoSection(),
              ),

              _buildOptionGroup(
                'Kondisi Fisik',
                ['Good', 'Korosif', 'Bad'],
                _kondisiFisikTerpilih,
                    (val) => _kondisiFisikTerpilih = val,
                accentColor: const Color(0xFFF59E0B),
              ),

              if (isAPAR)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _accentSoft,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _accent.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCompactOptionGroup('Selang', ['Good', 'Bad', 'Crack'], _selangTerpilih,
                              (val) => setState(() => _selangTerpilih = val)),
                      _buildCompactOptionGroup('Pressure Gauge', ['Good', 'Bad'], _pressureGaugeTerpilih,
                              (val) => setState(() => _pressureGaugeTerpilih = val)),
                      _buildCompactOptionGroup('Safety Pin', ['Good', 'Crack'], _safetyPinTerpilih,
                              (val) => setState(() => _safetyPinTerpilih = val)),
                    ],
                  ),
                ),

              _buildOptionGroup(
                'Tindakan yang Diperlukan',
                isAPAR
                    ? ['Isi Ulang', 'Good', 'Ganti']
                    : ['Good', 'Broken', 'Repair'],
                _tindakanTerpilih,
                    (val) => _tindakanTerpilih = val,
              ),

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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                  )
                      : const Text('Kirim Laporan',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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