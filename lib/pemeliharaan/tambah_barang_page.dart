import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TambahBarangPage extends StatefulWidget {
  final String? nomorIdentifikasi; // dari hasil scan QR (bisa null/empty)

  const TambahBarangPage({Key? key, this.nomorIdentifikasi}) : super(key: key);

  @override
  State<TambahBarangPage> createState() => _TambahBarangPageState();
}

class _TambahBarangPageState extends State<TambahBarangPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomorIdentifikasiController = TextEditingController();
  final TextEditingController _namaBarangController = TextEditingController();
  final TextEditingController _tipeController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController(text: '1');
  final TextEditingController _satuanController = TextEditingController(text: 'pcs');
  final TextEditingController _kondisiController = TextEditingController(text: 'Baik');
  final TextEditingController _beratController = TextEditingController();
  final TextEditingController _merekController = TextEditingController();
  final TextEditingController _ukuranController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _hargaBeliController = TextEditingController();
  final TextEditingController _hargaJualController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.nomorIdentifikasi != null && widget.nomorIdentifikasi!.isNotEmpty) {
      _nomorIdentifikasiController.text = widget.nomorIdentifikasi!;
    } else {
      // Generate nomor identifikasi otomatis jika kosong
      _generateNomorIdentifikasi();
    }
  }

  void _generateNomorIdentifikasi() {
    // Generate nomor identifikasi dengan format timestamp
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString();
    _nomorIdentifikasiController.text = 'SUP-$timestamp';
  }

  Future<void> _simpanBarang() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userDataString = prefs.getString('user_data');

      if (token == null || token.isEmpty) {
        _showError('Token tidak ditemukan. Silakan login ulang.');
        return;
      }

      if (userDataString == null) {
        _showError('Data user tidak ditemukan. Silakan login ulang.');
        return;
      }

      // Parse user data untuk validasi
      Map<String, dynamic> userData;
      try {
        userData = json.decode(userDataString);
      } catch (e) {
        _showError('Data user tidak valid. Silakan login ulang.');
        return;
      }

      // Validasi user data
      final userRole = userData['role']?.toString();
      final userId = userData['id']?.toString();

      if (userRole == null || userRole.isEmpty) {
        _showError('Role user tidak ditemukan. Silakan login ulang.');
        return;
      }

      if (userId == null || userId.isEmpty) {
        _showError('ID user tidak ditemukan. Silakan login ulang.');
        return;
      }

      print('[DEBUG] User data parsed - Role: $userRole, ID: $userId');

      final apiUrl = Uri.parse('http://10.0.2.2:8000/api/supervisor-umum/barang');

      final body = {
        'nomor_identifikasi': _nomorIdentifikasiController.text.trim(),
        'nama_barang': _namaBarangController.text.trim(),
        'jumlah_barang': int.tryParse(_jumlahController.text.trim()) ?? 1,
        'tipe_barang': _tipeController.text.trim(),
        'satuan': _satuanController.text.trim(),
        'kondisi': _kondisiController.text.trim(),
        'lokasi_barang': _lokasiController.text.trim().isEmpty ? null : _lokasiController.text.trim(),
        'berat_barang': _beratController.text.trim().isEmpty ? null : double.tryParse(_beratController.text.trim()),
        'merek_barang': _merekController.text.trim().isEmpty ? null : _merekController.text.trim(),
        'ukuran_barang': _ukuranController.text.trim().isEmpty ? null : _ukuranController.text.trim(),
        'harga_beli': _hargaBeliController.text.trim().isEmpty ? null : double.tryParse(_hargaBeliController.text.trim()),
        'harga_jual': _hargaJualController.text.trim().isEmpty ? null : double.tryParse(_hargaJualController.text.trim()),
        // PERBAIKAN: Tambahkan created_by_role dan created_by_id
        'created_by_role': userRole,
        'created_by_id': int.tryParse(userId) ?? userId, // Handle both string and int
      };

      // Remove null values
      body.removeWhere((key, value) => value == null);

      print('[DEBUG] Sending data to server: ${json.encode(body)}');
      print('[DEBUG] User data: $userData');
      print('[DEBUG] Token: ${token.substring(0, 20)}...'); // Log partial token for security

      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      print('[DEBUG] Response status: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        dynamic respJson;
        try {
          respJson = json.decode(response.body);
        } catch (_) {
          respJson = {'message': 'Barang berhasil ditambahkan (response tidak JSON).'};
        }

        final message = respJson['message'] ?? 'Barang berhasil ditambahkan';

        await _showSuccessDialog(message, respJson['data']);

      } else if (response.statusCode == 422) {
        // Validation error
        try {
          final errJson = json.decode(response.body);
          String errMsg = errJson['message'] ?? 'Data tidak valid';
          if (errJson['errors'] != null) {
            final errors = errJson['errors'] as Map<String, dynamic>;
            final errorList = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorList.addAll(value.cast<String>());
              } else {
                errorList.add(value.toString());
              }
            });
            errMsg += '\n\n' + errorList.join('\n');
          }
          _showError(errMsg);
        } catch (_) {
          _showError('Data tidak valid. Periksa kembali input Anda.');
        }
      } else if (response.statusCode == 401) {
        _showError('Sesi login telah berakhir. Silakan login ulang.');
      } else if (response.statusCode == 403) {
        _showError('Anda tidak memiliki hak akses untuk menambahkan barang.');
      } else {
        // Other errors
        String errMsg = 'Gagal menambahkan barang. Status: ${response.statusCode}';
        try {
          final errJson = json.decode(response.body);
          if (errJson is Map && errJson['message'] != null) {
            errMsg = errJson['message'];
          }
        } catch (_) {
          String bodySnippet = response.body;
          if (bodySnippet.length > 400) bodySnippet = bodySnippet.substring(0, 400) + '...';
          errMsg = 'Gagal menambahkan barang. Server response:\n$bodySnippet';
        }
        _showError(errMsg);
      }
    } catch (e) {
      print('[ERROR] Exception in _simpanBarang: $e');
      _showError('Terjadi kesalahan koneksi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Tutup',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _showSuccessDialog(String message, dynamic data) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Sukses'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (data != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Detail Barang:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    if (data['nama_barang'] != null)
                      Text('Nama: ${data['nama_barang']}'),
                    if (data['nomor_identifikasi'] != null)
                      Text('ID: ${data['nomor_identifikasi']}'),
                    if (data['id_barang'] != null)
                      Text('ID Barang: ${data['id_barang']}'),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(true); // Kembali ke scanner dengan result
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      {
        TextInputType keyboard = TextInputType.text,
        bool required = true,
        String? hint
      }
      ) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return "$label tidak boleh kosong";
        }

        // Validasi khusus untuk nomor identifikasi
        if (label.contains('Nomor Identifikasi') && value != null && value.trim().isNotEmpty) {
          if (value.trim().length < 3) {
            return "Nomor identifikasi minimal 3 karakter";
          }
          // Cek apakah mengandung karakter yang tidak diizinkan
          if (!RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(value.trim())) {
            return "Nomor identifikasi hanya boleh berisi huruf, angka, tanda hubung (-) dan underscore (_)";
          }
        }

        // Validasi untuk angka
        if (keyboard == TextInputType.number && value != null && value.trim().isNotEmpty) {
          if (label.contains('Jumlah')) {
            final number = int.tryParse(value.trim());
            if (number == null || number <= 0) {
              return "Jumlah harus berupa angka positif";
            }
          } else {
            final number = double.tryParse(value.trim());
            if (number == null || number < 0) {
              return "Nilai harus berupa angka yang valid";
            }
          }
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Barang'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Tombol refresh nomor identifikasi
          IconButton(
            onPressed: () {
              _generateNomorIdentifikasi();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Nomor identifikasi baru telah dibuat'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(Icons.refresh),
            tooltip: 'Generate Nomor ID Baru',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Header info
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Isi form di bawah untuk menambahkan barang baru ke sistem. Barang yang ditambahkan hanya bisa diakses oleh Anda.',
                        style: TextStyle(color: Colors.blue[800]),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Form fields
              _buildTextField(
                  'Nomor Identifikasi',
                  _nomorIdentifikasiController,
                  hint: 'Contoh: APAR'
              ),
              SizedBox(height: 12),

              _buildTextField('Nama Barang', _namaBarangController, hint: 'Contoh: Laptop Dell'),
              SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                        'Jumlah',
                        _jumlahController,
                        keyboard: TextInputType.number,
                        hint: '1'
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: _buildTextField('Satuan', _satuanController, hint: 'pcs, kg, liter'),
                  ),
                ],
              ),
              SizedBox(height: 12),

              _buildTextField('Tipe Barang', _tipeController, hint: 'Contoh: Elektronik'),
              SizedBox(height: 12),

              _buildTextField('Kondisi', _kondisiController, hint: 'Baik, Rusak, Perlu Perbaikan'),
              SizedBox(height: 12),

              _buildTextField('Lokasi Barang', _lokasiController, required: false, hint: 'Contoh: Gudang A'),
              SizedBox(height: 12),

              // Optional fields section
              ExpansionTile(
                title: Text('Informasi Tambahan (Opsional)'),
                initiallyExpanded: false,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildTextField(
                            'Berat (kg)',
                            _beratController,
                            keyboard: TextInputType.numberWithOptions(decimal: true),
                            required: false,
                            hint: '0.5'
                        ),
                        SizedBox(height: 12),

                        _buildTextField('Merek', _merekController, required: false, hint: 'Contoh: Dell, HP'),
                        SizedBox(height: 12),

                        _buildTextField('Ukuran', _ukuranController, required: false, hint: 'Contoh: 14 inch'),
                        SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                  'Harga Beli',
                                  _hargaBeliController,
                                  keyboard: TextInputType.numberWithOptions(decimal: true),
                                  required: false,
                                  hint: '1000000'
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                  'Harga Jual',
                                  _hargaJualController,
                                  keyboard: TextInputType.numberWithOptions(decimal: true),
                                  required: false,
                                  hint: '1200000'
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Submit button
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _simpanBarang,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Menyimpan...'),
                    ],
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save),
                      SizedBox(width: 8),
                      Text('Simpan Barang'),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Info tambahan
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          'Catatan Keamanan:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Barang yang Anda tambahkan hanya bisa diakses dan diedit oleh Anda sendiri\n• Pastikan nomor identifikasi unik dan mudah diingat\n• Data yang sudah disimpan tidak bisa dihapus melalui aplikasi ini',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomorIdentifikasiController.dispose();
    _namaBarangController.dispose();
    _tipeController.dispose();
    _jumlahController.dispose();
    _satuanController.dispose();
    _kondisiController.dispose();
    _beratController.dispose();
    _merekController.dispose();
    _ukuranController.dispose();
    _lokasiController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    super.dispose();
  }
}