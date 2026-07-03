import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tunassiakanugrah/pemeliharaan/form_laporan.dart';
import 'package:tunassiakanugrah/pemeliharaan/tambah_barang_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunassiakanugrah/config/env.dart';

class QrCodeHalaman extends StatefulWidget {
  @override
  _QrCodeHalamanState createState() => _QrCodeHalamanState();
}

class _QrCodeHalamanState extends State<QrCodeHalaman> with SingleTickerProviderStateMixin {
  late MobileScannerController _scannerController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _isFlashOn = false;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: _isFlashOn,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showPreviewBarangDialog(
      Map<String, dynamic> data,
      String qrCode,
      Map<String, dynamic> inspectionStatus,
      ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header dengan Gradient
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade600, Colors.blue.shade800],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.inventory_2_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preview Alat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Verifikasi data alat',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEnhancedDetailRow(
                            'Nama Alat',
                            data['nama_barang']?.toString() ?? '-',
                            Icons.label_rounded,
                            Colors.blue,
                          ),
                          SizedBox(height: 12),
                          _buildEnhancedDetailRow(
                            'Tipe',
                            data['tipe_barang_kategori']?.toString() ?? '-',
                            Icons.category_rounded,
                            Colors.purple,
                          ),
                          SizedBox(height: 12),
                          _buildEnhancedDetailRow(
                            'Kode QR',
                            qrCode ?? '-',
                            Icons.qr_code_rounded,
                            Colors.teal,
                          ),
                          SizedBox(height: 20),

                          Container(
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: inspectionStatus['is_due'] == true
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: inspectionStatus['is_due'] == true
                                    ? Colors.green.shade300
                                    : Colors.orange.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      inspectionStatus['is_due'] == true
                                          ? Icons.check_circle_rounded
                                          : Icons.lock_clock_rounded,
                                      color: inspectionStatus['is_due'] == true
                                          ? Colors.green
                                          : Colors.orange,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        inspectionStatus['status_text'] ?? '-',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: inspectionStatus['is_due'] == true
                                              ? Colors.green.shade800
                                              : Colors.orange.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                if (inspectionStatus['last_inspection'] != null)
                                  Text(
                                    'Terakhir inspeksi: ${inspectionStatus['last_inspection']}',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey.shade700),
                                  ),
                                if (inspectionStatus['next_inspection'] != null)
                                  Text(
                                    'Jadwal berikutnya: ${inspectionStatus['next_inspection']}',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey.shade700),
                                  ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
                // Actions
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _scannerController.start();
                              _isDetecting = false;
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red.shade300, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.close_rounded, color: Colors.red, size: 15),
                                SizedBox(width: 6),
                                Text(
                                  'Batal',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: inspectionStatus['is_due'] == true
                                ? LinearGradient(
                              colors: [Colors.blue.shade600, Colors.blue.shade800],
                            )
                                : LinearGradient(
                              colors: [Colors.grey.shade400, Colors.grey.shade500],
                            ),

                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: inspectionStatus['is_due'] == true
                                ? () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FormulirLaporanHalaman(
                                    idAlat: data['id_barang'].toString(),
                                    namaAlat: data['nama_barang'] ?? '-',
                                    tipeBarang: data['tipe_barang_kategori'],
                                    lokasiAlat: data['lokasi_barang'] ?? '-',
                                    qrCodeData: qrCode,
                                  ),
                                ),
                              );
                            } : null,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.fact_check_rounded, color: Colors.white,size: 17),
                                SizedBox(width: 8),
                                Text(
                                  'Lanjut Inspeksi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
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
              ],
            ),
          ),
        );
      },
    );
  }

// Widget helper untuk detail row
  Widget _buildEnhancedDetailRow(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[900],
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDialogError(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header dengan Gradient Merah
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.red.shade500, Colors.red.shade700],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.warning_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Peringatan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Terjadi kesalahan',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.red.shade200,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.red.shade700,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    message,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.red.shade900,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Action Button
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade500, Colors.red.shade700],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Mengerti',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
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
        );
      },
    );
  }

  String _parseNomorIdentifikasi(String raw) {
    final lines = raw.split('\n');
    for (var line in lines) {
      final lower = line.toLowerCase();
      if (lower.contains('nomor identifikasi')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          return parts.sublist(1).join(':').trim();
        }
        // kalau cuma "Nomor Identifikasi:" tanpa isi
        return '';
      }
    }
    return raw.trim();
  }


  // Helper method untuk normalisasi role
  String _normalizeRole(String role) {
    return role.toLowerCase().trim().replaceAll(' ', '_');
  }

  // Helper method untuk pengecekan akses

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isDetecting) return;

    final rawText = capture.barcodes.first.rawValue;
    if (rawText == null || rawText.trim().isEmpty) {
      await _showDialogError('QR tidak valid.');
      return;
    }

    final parsed = _parseNomorIdentifikasi(rawText);
    if (parsed.isEmpty) {
      await _showDialogError('QR tidak dikenali.');
      return;
    }

    setState(() => _isDetecting = true);
    await _scannerController.stop();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userData = jsonDecode(prefs.getString('user_data') ?? '{}');

      final role = (userData['role'] ?? '').toString().toLowerCase();

      // 🔒 VALIDASI ROLE
      if (role != 'inspektor') {
        await _showAccessDeniedDialog(
            message: 'Hanya INSPEKTOR yang dapat melakukan inspeksi.'
        );
        return;
      }

      final response = await http.get(
        Uri.parse('${Env.baseUrl}/api/barang/${Uri.encodeComponent(parsed)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        await _showDialogError('Barang atau QR tidak dikenali.');
        return;
      }

      final body = jsonDecode(response.body);
      final data = body['data'];
      final inspectionStatus = data['inspection_status'];


      if (data == null) {
        await _showDialogError('Barang tidak ditemukan.');
        return;
      }

      final tipe = (data['tipe_barang_kategori'] ?? '').toString().toUpperCase();

      if (tipe != 'APAR' && tipe != 'HYDRANT') {
        await _showDialogError('Barang bukan APAR atau HYDRANT.');
        return;
      }

      await _showPreviewBarangDialog(data, parsed, inspectionStatus);



    } catch (e) {
      await _showDialogError('Terjadi kesalahan: $e');
    } finally {
      _isDetecting = false;
      await _scannerController.start();
    }
  }


  Future<void> _showAccessDeniedDialog({String? message}) async {
    final defaultMessage =
        'Anda tidak memiliki hak akses untuk barang ini.\n\nAnda hanya dapat mengakses barang yang telah diinputkan sendiri.';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.block, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text('Akses Ditolak'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message ?? defaultMessage,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Mengerti', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showBarangDetailDialog(Map<String, dynamic> data) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text('Detail Barang'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Nama Barang', data['nama_barang']),
                _buildDetailRow('Tipe Barang', data['tipe_barang_kategori']),
                _buildDetailRow('Lokasi', data['lokasi_barang']),
                _buildDetailRow('Nomor Identifikasi', data['nomor_identifikasi']),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Barang dapat diakses',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value?.toString() ?? '-'),
          ),
        ],
      ),
    );
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
      _scannerController.toggleTorch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: Text('QR CODE'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _scannerController, onDetect: _onDetect),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Posisikan kode QR pada kotak yang disediakan',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent, width: 3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 250 * (_animation.value - 0.5)),
                            child: Container(width: 240, height: 3, color: Colors.redAccent),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                ElevatedButton.icon(
                  onPressed: _toggleFlash,
                  icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white),
                  label: Text(_isFlashOn ? 'Flash On' : 'Flash Off', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _scannerController.switchCamera(),
                  icon: Icon(Icons.cameraswitch, color: Colors.white),
                  label: Text('Ganti Kamera', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}