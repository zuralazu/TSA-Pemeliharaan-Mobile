import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tunassiakanugrah/pemeliharaan/form_laporan.dart';
import 'package:tunassiakanugrah/pemeliharaan/tambah_barang_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

    final String? rawText = capture.barcodes.first.rawValue;
    print('[DEBUG] Hasil Scan QR: $rawText');

    if (rawText == null || rawText.trim().isEmpty) {
      await _showDialogError('QR tidak berisi Nomor Identifikasi yang valid.');
      return;
    }

    final String parsed = _parseNomorIdentifikasi(rawText);
    print('[DEBUG] Parsed nomorIdentifikasi: "$parsed"');

    setState(() => _isDetecting = true);
    await _scannerController.stop();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user_data');
    String? token = prefs.getString('access_token');

    String role = '';
    String userId = '';
    if (userDataString != null) {
      try {
        final user = jsonDecode(userDataString);
        role = (user['role'] ?? '').toString();
        userId = (user['id'] ?? '').toString();
        print('[DEBUG] User role from SharedPrefs: "$role"');
      } catch (e) {
        print('[ERROR] Error parsing user data: $e');
        role = '';
        userId = '';
      }
    }

    // Supervisor umum boleh akses halaman tambah barang jika QR kosong
    if (parsed.isEmpty) {
      if (_normalizeRole(role) == 'supervisor_umum') {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TambahBarangPage(
              nomorIdentifikasi: '',
            ),
          ),
        );
        return;
      } else {
        await _showAccessDeniedDialog(message: 'Hanya supervisor umum yang dapat menambahkan barang baru.');
        setState(() => _isDetecting = false);
        await _scannerController.start();
        return;
      }
    }

    String apiUrl;
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      http.Response response;

      if (_normalizeRole(role) == 'supervisor_umum') {
        // Endpoint khusus supervisor umum dengan POST
        apiUrl = 'http://10.0.2.2:8000/api/supervisor-umum/scan-qr';
        final body = json.encode({'nomor_identifikasi': parsed});

        print('[DEBUG] Calling supervisor umum endpoint: $apiUrl');
        print('[DEBUG] Request body: $body');

        response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
          body: body,
        );
      } else {
        // Endpoint umum GET
        apiUrl = 'http://10.0.2.2:8000/api/barang/${Uri.encodeComponent(parsed)}';
        print('[DEBUG] Calling general endpoint: $apiUrl');
        response = await http.get(Uri.parse(apiUrl), headers: headers);
      }

      print('[DEBUG] Response status: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        // Barang belum ada di DB atau id_barang masih null
        if (responseBody['status'] == 'not_found' ||
            (responseBody['data'] != null && responseBody['data']['id_barang'] == null)) {
          if (_normalizeRole(role) == 'supervisor_umum') {
            await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => TambahBarangPage(nomorIdentifikasi: parsed),
              ),
            );
            return;
          } else {
            await _showDialogError('QR ini belum memiliki data barang. Hubungi supervisor umum.');
            setState(() => _isDetecting = false);
            await _scannerController.start();
            return;
          }
        }

        // Handle response dengan data barang
        final data = responseBody['data'] ?? responseBody;

        if (data['id_barang'] != null) {
          final currentRole = role.toLowerCase().trim();
          final creatorRole = (data['created_by_role'] ?? '').toString().toLowerCase().trim();
          final creatorId = (data['created_by_id'] ?? '').toString();

          print('[DEBUG] currentRole: $currentRole, creatorRole: $creatorRole');
          print('[DEBUG] User ID: $userId, Created By ID: $creatorId');

          bool hasAccess = false;
          String accessDeniedMessage = 'Anda tidak memiliki akses ke barang ini.';

          if (currentRole == 'supervisor_umum') {
            if (creatorRole == 'supervisor_umum' && userId == creatorId) {
              hasAccess = true;
            } else {
              accessDeniedMessage = 'Supervisor hanya dapat mengakses barang yang diinput sendiri.';
            }
          } else if (currentRole == 'inspektor') {
            if (creatorRole == 'supervisor_umum') {
              hasAccess = true;
            } else {
              accessDeniedMessage = 'Inspektor hanya dapat mengakses barang yang diinput oleh supervisor umum.';
            }
          } else if (currentRole == 'staff_gudang') {
            if (creatorRole == 'staff_gudang') {
              hasAccess = true;
            } else {
              accessDeniedMessage = 'Staff gudang hanya dapat mengakses barang yang diinput oleh staff gudang.';
            }
          }

          if (hasAccess) {
            // Navigasi ke halaman yang benar
            if (currentRole == 'supervisor_umum') {
              await _showBarangDetailDialog(data);
            } else {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormulirLaporanHalaman(
                    idAlat: data['id_barang'].toString(),
                    namaAlat: data['nama_barang'] ?? 'Tidak Dikenal',
                    tipeBarang: data['tipe_barang'] ?? 'Tidak Dikenal',
                    lokasiAlat: data['lokasi_barang'] ?? 'Tidak Diketahui',
                    qrCodeData: parsed,
                  ),
                ),
              );
              if (result == 'refresh') {
                Navigator.pop(context, 'refresh');
              }
            }
          } else {
            await _showAccessDeniedDialog(message: accessDeniedMessage);
          }
        } else {
          await _showDialogError('Data barang tidak ditemukan dalam respons.');
          setState(() => _isDetecting = false);
          await _scannerController.start();
          return;
        }
      }
      else if (response.statusCode == 404) {
        await _showDialogError('QR tidak ditemukan di sistem.');
      } else if (response.statusCode == 403) {
        try {
          final errorBody = json.decode(response.body);
          final errorMessage = errorBody['message'] ?? 'Akses ditolak';
          await _showAccessDeniedDialog(message: errorMessage);
        } catch (_) {
          await _showAccessDeniedDialog();
        }
      } else {
        String bodySnippet = response.body;
        if (bodySnippet.length > 300) bodySnippet = bodySnippet.substring(0, 300) + '...';
        await _showDialogError('Terjadi kesalahan server: ${response.statusCode}\n$bodySnippet');
      }
    } catch (e) {
      print('[ERROR] Exception: $e');
      await _showDialogError('Koneksi gagal: $e');
    } finally {
      // Restart scanner hanya jika tidak ada navigasi yang terjadi
      if (mounted && Navigator.canPop(context)) {
        await _scannerController.start();
        setState(() => _isDetecting = false);
      }
    }
  }

  Future<void> _showDialogError(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Peringatan'),
          content: SingleChildScrollView(child: Text(message)),
          actions: <Widget>[
            TextButton(child: const Text('OK'), onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
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
                _buildDetailRow('Tipe Barang', data['tipe_barang']),
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