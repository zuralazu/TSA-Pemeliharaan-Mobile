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

class _FormulirLaporanHalamanState extends State<FormulirLaporanHalaman> {
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();


  String? _kondisiFisikTerpilih;
  String? _selangTerpilih;
  String? _pressureGaugeTerpilih;
  String? _safetyPinTerpilih;
  String? _tindakanTerpilih;
  File? _imageFile;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _lokasiController.text = widget.lokasiAlat;
    _tanggalController.text = _formatDate(DateTime.now());
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text = _formatDate(picked);
      });
    }
  }

  // Fungsi untuk mengirim laporan ke API (ini sudah benar)
  Future<void> _kirimLaporan() async {
    setState(() {
      _isLoading = true;
    });


    final String tanggalInspeksi = _tanggalController.text;
    final String lokasiAlat = _lokasiController.text;
    final String fotoPath = _imageFile?.path ?? '';
    final String kondisiFisik = _kondisiFisikTerpilih ?? '';
    final String selang = _selangTerpilih ?? '';
    final String pressureGauge = _pressureGaugeTerpilih ?? '';
    final String safetyPin = _safetyPinTerpilih ?? '';
    final String tindakan = _tindakanTerpilih ?? '';

    if (tanggalInspeksi.isEmpty || lokasiAlat.isEmpty ||
        kondisiFisik.isEmpty || selang.isEmpty ||
        pressureGauge.isEmpty || safetyPin.isEmpty || tindakan.isEmpty) {
      _showSnackBar('Semua field laporan wajib diisi!', Colors.red);
      setState(() { _isLoading = false; });
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      _showSnackBar('Anda belum login. Silakan login kembali.', Colors.red);
      setState(() { _isLoading = false; });
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
      return;
    }

    final Map<String, dynamic> requestBody = {
      'qr_code_data': widget.qrCodeData,
      'tanggal_inspeksi': tanggalInspeksi,
      'lokasi_alat': lokasiAlat,
      'foto': fotoPath,
      'kondisi_fisik': kondisiFisik,
      'selang': selang,
      'pressure_gauge': pressureGauge,
      'safety_pin': safetyPin,
      'tindakan': tindakan,
    };

    final String apiUrl = 'http://10.0.2.2:8000/api/laporan-apk';
    print('[DEBUG] Mengirim laporan ke: $apiUrl');
    print('[DEBUG] Body laporan: ${jsonEncode(requestBody)}');
    print('[DEBUG] Token: $accessToken');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      print('[DEBUG] Respons laporan status: ${response.statusCode}');
      print('[DEBUG] Respons laporan body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        _showSnackBar(responseData['message'] ?? 'Laporan berhasil disimpan!', Colors.green);
        Navigator.pop(context);
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage = "Validasi gagal: ";
        if (errorData.containsKey('errors')) {
          errorData['errors'].forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessage += "${value[0]} ";
            }
          });
        } else if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        }
        _showSnackBar(errorMessage, Colors.red);
      } else if (response.statusCode == 401) {
        _showSnackBar('Sesi habis. Silakan login kembali.', Colors.red);
        await prefs.remove('user_data');
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
      } else {
        _showSnackBar('Terjadi kesalahan server: ${response.statusCode}', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Terjadi error koneksi: $e', Colors.red);
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }


  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Pelaporan APAR'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.5),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi APAR Setelah Scan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                  ),
                  SizedBox(height: 10),
                  _buildInfoRow('ID Alat', widget.idAlat),
                  _buildInfoRow('Nama Alat', widget.namaAlat),
                  _buildInfoRow('Tipe Alat', widget.tipeBarang),
                  _buildInfoRow('Lokasi', widget.lokasiAlat),
                  _buildInfoRow('Data QR', widget.qrCodeData),
                ],
              ),
            ),
            SizedBox(height: 25),

            _bangunBidangInput(
              label: 'Tanggal',
              hint: 'Pilih Tanggal',
              controller: _tanggalController,
              icon: Icons.calendar_today,
              onTap: () => _selectDate(context),
              readOnly: true,
            ),
            _bangunBidangInput(label: 'Lokasi', hint: 'Input Lokasi Sekarang', controller: _lokasiController),
            _bangunBidangUnggahFoto(context),
            SizedBox(height: 25),

            Text('Kondisi Fisik :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            SizedBox(height: 10),
            _bangunGrupPilihan(
              ['Good', 'Korosif', 'Bad'],
              _kondisiFisikTerpilih,
                  (String? value) {
                setState(() {
                  _kondisiFisikTerpilih = value;
                });
              },
            ),
            SizedBox(height: 20),

            Text('Selang :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            SizedBox(height: 10),
            _bangunGrupPilihan(
              ['Good', 'Bad', 'Crack'],
              _selangTerpilih,
                  (String? value) {
                setState(() {
                  _selangTerpilih = value;
                });
              },
            ),
            SizedBox(height: 20),

            Text('Pressure Gauge :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            SizedBox(height: 10),
            _bangunGrupPilihan(
              ['Good', 'Bad'],
              _pressureGaugeTerpilih,
                  (String? value) {
                setState(() {
                  _pressureGaugeTerpilih = value;
                });
              },
            ),
            SizedBox(height: 20),

            Text('Safety Seal :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            SizedBox(height: 10),
            _bangunGrupPilihan(
              ['Good', 'Crack'],
              _safetyPinTerpilih, // UBAH INI: ERD Anda pakai safety_pin, pastikan disamakan
                  (String? value) {
                setState(() {
                  _safetyPinTerpilih = value;
                });
              },
            ),
            SizedBox(height: 20),

            Text('Tindakan :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            SizedBox(height: 10),
            _bangunGrupPilihan(
              ['Isi Ulang', 'Ganti'],
              _tindakanTerpilih,
                  (String? value) {
                setState(() {
                  _tindakanTerpilih = value;
                });
              },
            ),
            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // PERBAIKAN: Hubungkan onPressed ke fungsi _kirimLaporan
                onPressed: _isLoading ? null : _kirimLaporan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                // Tampilkan CircularProgressIndicator jika sedang loading
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Kirim Laporan',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          Expanded(child: Text(value, style: TextStyle(fontSize: 15, color: Colors.grey[800]))),
        ],
      ),
    );
  }

  Widget _bangunBidangInput({required String label, required String hint, TextEditingController? controller, IconData? icon, bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          SizedBox(height: 10),
          TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: icon != null ? Icon(icon, color: Colors.blueAccent) : null,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bangunBidangUnggahFoto(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Unggah Foto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          SizedBox(height: 10),
          InkWell(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _imageFile != null ? 'Gambar Dipilih: ${_imageFile!.path.split('/').last}' : 'Pilih Gambar',
                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  ),
                  Icon(Icons.camera_alt, color: Colors.blueAccent),
                ],
              ),
            ),
          ),
          if (_imageFile != null) ...[
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(_imageFile!, height: 150),
            )
          ]
        ],
      ),
    );
  }


  Widget _bangunGrupPilihan(List<String> opsi, String? selectedValue, Function(String?) callback) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 10.0,
      children: opsi.map((opsiTeks) {
        final bool isSelected = selectedValue == opsiTeks;
        return ChoiceChip(
          label: Text(opsiTeks, style: TextStyle(fontWeight: FontWeight.w500)),
          selected: isSelected,
          onSelected: (bool selected) {
            if (selected) {
              callback(opsiTeks);
            } else {
              callback(null);
            }
          },
          selectedColor: Colors.blueAccent.shade100,
          backgroundColor: Colors.grey[100],
          labelStyle: TextStyle(
            color: isSelected ? Colors.blue.shade900 : Colors.black87,
          ),
          side: BorderSide(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          elevation: isSelected ? 3 : 1,
        );
      }).toList(),
    );
  }
}