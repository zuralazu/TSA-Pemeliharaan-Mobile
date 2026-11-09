// lib/pemeliharaan/qr_code.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunassiakanugrah/config/env.dart';
import 'package:tunassiakanugrah/pemeliharaan/widgets/preview_barang_dialog.dart';
import 'package:tunassiakanugrah/pemeliharaan/widgets/qr_scanner_overlay.dart';
import 'package:tunassiakanugrah/widgets/common/info_dialog.dart';

class QrCodeHalaman extends StatefulWidget {
  @override
  _QrCodeHalamanState createState() => _QrCodeHalamanState();
}

class _QrCodeHalamanState extends State<QrCodeHalaman>
    with SingleTickerProviderStateMixin {
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
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
      _scannerController.toggleTorch();
    });
  }

  /// Mengurai teks QR dan mengambil "Nomor Identifikasi".
  String _parseNomorIdentifikasi(String raw) {
    for (var line in raw.split('\n')) {
      if (line.toLowerCase().contains('nomor identifikasi')) {
        final parts = line.split(':');
        return parts.length >= 2 ? parts.sublist(1).join(':').trim() : '';
      }
    }
    return raw.trim();
  }

  // ── Scan handler ──────────────────────────────────────────────────────────

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isDetecting) return;

    final rawText = capture.barcodes.first.rawValue;
    if (rawText == null || rawText.trim().isEmpty) {
      await InfoDialog.showError(context, 'QR tidak valid.');
      return;
    }

    final parsed = _parseNomorIdentifikasi(rawText);
    if (parsed.isEmpty) {
      await InfoDialog.showError(context, 'QR tidak dikenali.');
      return;
    }

    setState(() => _isDetecting = true);
    await _scannerController.stop();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userData = jsonDecode(prefs.getString('user_data') ?? '{}');
      final role = (userData['role'] ?? '').toString().toLowerCase();

      // 🔒 Validasi role
      if (role != 'inspektor') {
        await InfoDialog.showAccessDenied(
          context,
          'Hanya INSPEKTOR yang dapat melakukan inspeksi.',
        );
        return;
      }

      final response = await http.get(
        Uri.parse(
            '${Env.baseUrl}/api/barang/${Uri.encodeComponent(parsed)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        await InfoDialog.showError(
            context, 'Barang atau QR tidak dikenali.');
        return;
      }

      final body = jsonDecode(response.body);
      final data = body['data'];
      final inspectionStatus = data['inspection_status'];

      if (data == null) {
        await InfoDialog.showError(context, 'Barang tidak ditemukan.');
        return;
      }

      final tipe = (data['tipe_barang_kategori'] ?? '').toString().toUpperCase();
      if (tipe != 'APAR' && tipe != 'HYDRANT') {
        await InfoDialog.showError(
            context, 'Barang bukan APAR atau HYDRANT.');
        return;
      }

      await _showPreviewBarangDialog(data, parsed, inspectionStatus);
    } catch (e) {
      await InfoDialog.showError(context, 'Terjadi kesalahan: $e');
    } finally {
      _isDetecting = false;
      await _scannerController.start();
    }
  }

  Future<void> _showPreviewBarangDialog(
    Map<String, dynamic> data,
    String qrCode,
    Map<String, dynamic> inspectionStatus,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PreviewBarangDialog(
        data: data,
        qrCode: qrCode,
        inspectionStatus: inspectionStatus,
        onBatal: () {
          Navigator.of(context).pop();
          _scannerController.start();
          _isDetecting = false;
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('QR CODE'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          QrScannerOverlay(
            animation: _animation,
            isFlashOn: _isFlashOn,
            onToggleFlash: _toggleFlash,
            onSwitchCamera: () => _scannerController.switchCamera(),
          ),
        ],
      ),
    );
  }
}