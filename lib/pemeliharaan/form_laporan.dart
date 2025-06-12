// lib/pemeliharaan/form_laporan.dart
import 'package:flutter/material.dart';

class FormulirLaporanHalaman extends StatefulWidget {
  final String idAlat; // Parameter: id_barang dari ERD
  final String tipeAlat; // Parameter: jenis_barang dari API (dari tabel barang)
  final String lokasiAlat; // Parameter: lokasi_barang dari API (dari tabel barang)
  final String qrCodeData; // Parameter: nomor_identifikasi dari ERD (tabel qr_code)
  final String namaAlat; // Parameter: nama_barang dari ERD

  FormulirLaporanHalaman({
    Key? key,
    required this.idAlat,
    required this.tipeAlat,
    required this.lokasiAlat,
    required this.qrCodeData,
    required this.namaAlat,
  }) : super(key: key);

  @override
  _FormulirLaporanHalamanState createState() => _FormulirLaporanHalamanState();
}

class _FormulirLaporanHalamanState extends State<FormulirLaporanHalaman> {
  String? _kondisiFisikTerpilih;
  String? _selangTerpilih;
  String? _pressureGaugeTerpilih;
  String? _safetySealTerpilih;
  String? _tindakanTerpilih;

  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Isi otomatis field dengan data dari QR Code/API
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
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
                  _buildInfoRow('Nama Alat', widget.namaAlat), // Menampilkan Nama Alat
                  _buildInfoRow('Tipe Alat', widget.tipeAlat),
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
              _safetySealTerpilih,
                  (String? value) {
                setState(() {
                  _safetySealTerpilih = value;
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Laporan dikirim (UI Demo)!')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Text(
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
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Simulasi unggah foto')));
            },
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
                  Text('Pilih Gambar', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                  Icon(Icons.camera_alt, color: Colors.blueAccent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk grup pilihan (ChoiceChip) yang bisa memilih (PERBAIKAN FINAL onSelected)
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