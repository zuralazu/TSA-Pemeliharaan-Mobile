// lib/pemeliharaan/modul_detail_halaman.dart
import 'package:flutter/material.dart';

class ModulDetailHalaman extends StatelessWidget {
  final String modulType;
  final String modulTitle;

  const ModulDetailHalaman({
    Key? key,
    required this.modulType,
    required this.modulTitle,
  }) : super(key: key);

  // Fungsi untuk mendapatkan daftar TextSpan dari SOP
  List<TextSpan> _getSopTextSpans(String type) {
    List<TextSpan> spans = [];
    String rawText = '';

    switch (type) {
      case 'sop_apar':
        rawText = '''
Standar Operasional Prosedur (SOP) Pemeliharaan APAR:

1.  **Pengecekan Fisik Bulanan:**
    * Periksa kondisi tabung: tidak ada karat, penyok, atau kebocoran.
    * Periksa selang dan nozzle: tidak retak, tersumbat, atau rusak.
    * Periksa pressure gauge: jarum harus berada di area hijau.
    * Periksa safety pin dan segel: harus utuh dan tidak rusak.

2.  **Pengecekan Media Pemadam:**
    * APAR jenis Powder: Balikkan tabung beberapa kali untuk mencegah penggumpalan media.
    * APAR jenis Foam: Pastikan cairan tidak mengeras atau kadaluarsa.

3.  **Pencatatan:**
    * Catat tanggal pengecekan.
    * Catat kondisi setiap komponen.
    * Catat tindakan yang diperlukan (isi ulang, ganti part).
    * Dokumentasikan dengan foto jika ada kerusakan.

4.  **Isi Ulang (Refill) / Penggantian:**
    * Lakukan isi ulang APAR yang sudah digunakan atau yang tekanan/mediasnya kurang.
    * Ganti APAR yang sudah kadaluarsa atau rusak parah.

5.  **Lokasi Penempatan:**
    * Pastikan APAR diletakkan di lokasi yang mudah diakses, tidak terhalang, dan tanda APAR jelas terlihat.
    * Pastikan tidak terpapar sinar matahari langsung atau suhu ekstrem.

**Penting:** Laporkan setiap temuan tidak normal kepada Supervisor.
''';
        break;
      case 'sop_fire_hydrant':
        rawText = '''
Standar Operasional Prosedur (SOP) Pemeliharaan Fire Hydrant:

1.  **Pengecekan Mingguan/Bulanan:**
    * Periksa kondisi fisik hydrant: tidak ada karat, kerusakan, atau sumbatan di sekitar area.
    * Pastikan valve (katup) berfungsi dengan baik (putar sedikit untuk memastikan tidak macet).
    * Periksa kelengkapan aksesoris: selang, nozzle, kunci hydrant harus tersedia dan dalam kondisi baik.
    * Pastikan tekanan air normal (jika ada pressure gauge).

2.  **Pengecekan Tekanan Air:**
    * Lakukan uji tekanan air secara berkala untuk memastikan pasokan air dan tekanan mencukupi.

3.  **Pembersihan:**
    * Bersihkan area sekitar hydrant dari sampah atau halangan.
    * Bersihkan hydrant dari kotoran atau lumut.

4.  **Pelaporan:**
    * Catat tanggal pengecekan.
    * Catat kondisi fisik dan fungsi hydrant.
    * Laporkan setiap kerusakan atau kekurangan aksesoris.

5.  **Uji Fungsi Tahunan:**
    * Lakukan uji fungsi penuh hydrant setidaknya setahun sekali untuk memastikan siap digunakan dalam kondisi darurat.

**Penting:** Koordinasikan dengan tim teknis atau pemadam kebakaran untuk uji fungsi yang melibatkan aliran air bertekanan tinggi.
''';
        break;
      default:
        rawText = 'Modul tidak ditemukan atau tidak ada SOP untuk jenis ini.';
    }

    // Parsing teks untuk membuat bagian tebal dan bullet point
    List<String> lines = rawText.split('\n');
    for (String line in lines) {
      if (line.startsWith('**') && line.endsWith('**')) {
        // Bagian judul tebal seperti "**Pengecekan Fisik Bulanan:**"
        spans.add(TextSpan(
          text: line.replaceAll('**', '') + '\n',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
        ));
      } else if (line.startsWith('*')) {
        // Bullet points (gunakan karakter Unicode untuk bullet)
        spans.add(TextSpan(
          text: '  • ${line.substring(1).trimLeft()}\n', // Ganti '*' dengan '•'
          style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[800]),
        ));
      } else if (line.startsWith('1.') || line.startsWith('2.') || line.startsWith('3.') || line.startsWith('4.') || line.startsWith('5.')) {
        // Nomor urut tebal
        spans.add(TextSpan(
          text: line + '\n',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
        ));
      }
      else {
        // Teks biasa
        spans.add(TextSpan(
          text: line + '\n',
          style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[800]),
        ));
      }
    }
    return spans;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(modulTitle),
        backgroundColor: Colors.blue.shade700, // Warna AppBar disesuaikan
        foregroundColor: Colors.white, // Warna ikon dan teks kembali menjadi putih
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.blue.shade200], // Gradient latar belakang
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        modulTitle,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                      ),
                      SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          children: _getSopTextSpans(modulType),
                          style: DefaultTextStyle.of(context).style,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}