// lib/pemeliharaan/form_laporan.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunassiakanugrah/auth/login_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  final List<String> _daftarLokasi = ['LANTAI-1', 'LANTAI-2', 'LANTAI-3', 'LANTAI-4'];

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

  @override
  void initState() {
    super.initState();
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

    final uri = Uri.parse('http://10.0.2.2:8000/api/laporan-apk');
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
        Navigator.pop(context, 'refresh');
      } else {
        final data = json.decode(respStr);
        _showSnackBar(data['message'] ?? 'Gagal mengirim laporan.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e', Colors.red);
    }

    setState(() => _isLoading = false);
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

  Widget _buildModernChoiceChip(String label, bool isSelected, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(
            colors: [Colors.blue[400]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.blue[200]!.withOpacity(0.5),
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionGroup(String title, List<String> options, String? selectedValue, Function(String) onChanged, {Color? accentColor}) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: accentColor ?? Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: options.map((option) {
              return _buildModernChoiceChip(
                option,
                selectedValue == option,
                    () {
                  setState(() {
                    onChanged(option);
                  });
                },
              );
            }).toList(),
          ),
          if (title == 'Tindakan yang Diperlukan' &&
              ((isAPAR && _tindakanTerpilih == 'Ganti') ||
                  (isHYDRANT && _tindakanTerpilih == 'Repair')))
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: TextField(
                controller: _catatanTindakanController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Catatan tindakan...',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
            ),

        ],
      ),
    );
  }

  Widget _buildCompactOptionGroup(String title, List<String> options, String? selectedValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            return _buildModernChoiceChip(
              option,
              selectedValue == option,
                  () => onChanged(option),
            );
          }).toList(),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String title, IconData icon, Widget child) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[700]),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String detectedType = _detectTipeBarang();
    // final bool isAPAR = detectedType == 'APAR';
    // final bool isHYDRANT = detectedType == 'HYDRANT';

    if (detectedType == 'UNKNOWN') {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Form Pelaporan $detectedType',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: isAPAR ? Colors.red[600] : Colors.blue[600],
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Info
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isAPAR
                        ? [Colors.red[50]!, Colors.red[100]!]
                        : [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isAPAR ? Colors.red[200]! : Colors.blue[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Nama', widget.namaAlat),
                    _buildInfoRow('Tipe', detectedType),
                    _buildInfoRow('Lokasi', widget.lokasiAlat),
                    _buildInfoRow('QR Code', widget.qrCodeData),
                    _buildInfoRow('ID', widget.idAlat),
                  ],
                ),
              ),
              SizedBox(height: 24),

              _buildInputField(
                'Tanggal Inspeksi',
                Icons.calendar_today,
                TextField(
                  controller: _tanggalController,
                  readOnly: true,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),

              _buildInputField(
                'Lokasi Perangkat',
                Icons.location_on,
                DropdownButtonFormField<String>(
                  value: _lokasiDropdownValue,
                  decoration: InputDecoration(border: InputBorder.none),
                  items: _daftarLokasi.map((lok) {
                    return DropdownMenuItem(
                      value: lok,
                      child: Text(lok),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _lokasiDropdownValue = val!),
                ),
              ),

              _buildInputField(
                'Foto Bukti',
                Icons.camera_alt,
                Column(
                  children: [
                    if (_imageFile != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!,
                            height: 200, width: double.infinity, fit: BoxFit.cover),
                      ),
                    SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0), // biar nggak mepet
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.camera_alt),
                        label: Text('Ambil Foto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAPAR ? Colors.red[600] : Colors.blue[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          minimumSize: Size(double.infinity, 50), // full lebar tapi ada jarak dari padding
                        ),
                      ),
                    )
                  ],
                ),
              ),

              _buildOptionGroup(
                'Kondisi Fisik',
                ['Good', 'Korosif', 'Bad'],
                _kondisiFisikTerpilih,
                    (val) => setState(() => _kondisiFisikTerpilih = val),
                accentColor: Colors.orange,
              ),

              if (isAPAR)
                Container(
                  padding: EdgeInsets.all(15),
                  margin: EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red[50]!, Colors.red[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
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
                    (val) => setState(() => _tindakanTerpilih = val),
              ),

              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _kirimLaporan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAPAR ? Colors.red[600] : Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Kirim Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
