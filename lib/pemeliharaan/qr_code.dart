// lib/pemeliharaan/qr_code.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tunassiakanugrah/pemeliharaan/form_laporan.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  void _onDetect(BarcodeCapture capture) async {
    if (_isDetecting) return;

    final String? qrCodeData = capture.barcodes.first.rawValue;

    if (qrCodeData == null || qrCodeData.isEmpty) {
      _showSnackBar('QR tidak valid atau kosong', Colors.orange);
      await _scannerController.start();
      setState(() => _isDetecting = false);
      return;
    }

    setState(() => _isDetecting = true);
    await _scannerController.stop();

    // STEP 1: Tampilkan QR yang dibaca
    _showSnackBar('QR Terbaca: $qrCodeData', Colors.blue);
    await Future.delayed(Duration(seconds: 2));

    final String apiUrl = 'http://10.0.2.2:8000/api/barang/$qrCodeData';

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {'Accept': 'application/json'});

      // STEP 2: Tampilkan status code
      _showSnackBar('Status Code: ${response.statusCode}', Colors.green);
      await Future.delayed(Duration(seconds: 2));

      if (response.statusCode == 200) {
        // STEP 3: Tampilkan sebagian response body
        String shortResponse = response.body.length > 100 ?
        response.body.substring(0, 100) + '...' :
        response.body;
        _showSnackBar('Response: $shortResponse', Colors.purple);
        await Future.delayed(Duration(seconds: 3));

        final Map<String, dynamic> responseBody = json.decode(response.body);

        // STEP 4: Debug struktur data
        if (responseBody.containsKey('data')) {
          _showSnackBar('Found "data" key in response', Colors.cyan);
          await Future.delayed(Duration(seconds: 1));

          final data = responseBody['data'];
          if (data != null && data['id_barang'] != null) {
            _showSnackBar('ID Barang found: ${data['id_barang']}', Colors.lime);
            await Future.delayed(Duration(seconds: 1));

            // NAVIGASI KE FORM
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FormulirLaporanHalaman(
                  idAlat: data['id_barang']?.toString() ?? 'N/A',
                  namaAlat: data['nama_barang'] ?? 'Tidak Dikenal',
                  tipeBarang: data['tipe_barang'] ?? 'Tidak Dikenal',
                  lokasiAlat: data['lokasi_barang'] ?? 'Tidak Diketahui',
                  qrCodeData: qrCodeData,
                ),
              ),
            );
            return;
          } else {
            _showSnackBar('Data atau id_barang is null', Colors.red);
          }
        } else if (responseBody.containsKey('id_barang')) {
          _showSnackBar('Direct format detected', Colors.cyan);
          await Future.delayed(Duration(seconds: 1));

          // NAVIGASI KE FORM (format direct)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FormulirLaporanHalaman(
                idAlat: responseBody['id_barang']?.toString() ?? 'N/A',
                namaAlat: responseBody['nama_barang'] ?? 'Tidak Dikenal',
                tipeBarang: responseBody['tipe_barang'] ?? 'Tidak Dikenal',
                lokasiAlat: responseBody['lokasi_barang'] ?? 'Tidak Diketahui',
                qrCodeData: qrCodeData,
              ),
            ),
          );
          return;
        } else {
          _showSnackBar('No expected keys found in response', Colors.red);
        }
      } else if (response.statusCode == 404) {
        _showSnackBar('QR tidak ditemukan (404)', Colors.orange);
      } else {
        _showSnackBar('Server error: ${response.statusCode}', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Exception: $e', Colors.red);
    }

    await _scannerController.start();
    setState(() => _isDetecting = false);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide previous snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
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
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('QR CODE'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
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
                            child: Container(
                              width: 240,
                              height: 3,
                              color: Colors.redAccent,
                            ),
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
                  onPressed: () {
                    _scannerController.switchCamera();
                  },
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