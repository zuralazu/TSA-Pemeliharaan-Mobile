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

    final String? rawText = capture.barcodes.first.rawValue;
    print('[DEBUG] Hasil Scan QR: $rawText');

    String? nomorIdentifikasi;

    if (rawText != null) {
      final lines = rawText.split('\n');
      for (var line in lines) {
        if (line.toLowerCase().contains('nomor identifikasi')) {
          final parts = line.split(':');
          if (parts.length == 2) {
            nomorIdentifikasi = parts[1].trim();
            break;
          }
        }
      }
    }

    if (nomorIdentifikasi == null || nomorIdentifikasi.isEmpty) {
      await _showDialogError('QR tidak berisi Nomor Identifikasi yang valid.');
      return;
    }

    setState(() => _isDetecting = true);
    await _scannerController.stop();

    final String apiUrl = 'http://10.0.2.2:8000/api/barang/$nomorIdentifikasi';

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final data = responseBody['data'] ?? responseBody;

        if (data['id_barang'] != null) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormulirLaporanHalaman(
                idAlat: data['id_barang'].toString(),
                namaAlat: data['nama_barang'] ?? 'Tidak Dikenal',
                tipeBarang: data['tipe_barang'] ?? 'Tidak Dikenal',
                lokasiAlat: data['lokasi_barang'] ?? 'Tidak Diketahui',
                qrCodeData: nomorIdentifikasi!,
              ),
            ),
          );

          // Jika setelah laporan kembali dengan result = 'refresh', kirim sinyal ke dashboard
          if (result == 'refresh') {
            Navigator.pop(context, 'refresh');
          }

          return;
        } else {
          await _showDialogError('Data barang tidak ditemukan dalam respons.');
        }
      } else if (response.statusCode == 404) {
        await _showDialogError('QR tidak ditemukan di sistem.');
      } else {
        await _showDialogError('Terjadi kesalahan server: ${response.statusCode}');
      }
    } catch (e) {
      await _showDialogError('Koneksi gagal: $e');
    }

    await _scannerController.start();
    setState(() => _isDetecting = false);
  }

  Future<void> _showDialogError(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Peringatan'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
