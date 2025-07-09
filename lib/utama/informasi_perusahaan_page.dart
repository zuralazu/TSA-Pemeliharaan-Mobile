import 'package:flutter/material.dart';

class InformasiPerusahaanPage extends StatelessWidget {
  const InformasiPerusahaanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Tentang Perusahaan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.business, size: 60, color: Colors.blue),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'PT Tunas Siak Anugrah',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildCard(
              title: 'Profil perusahaan',
              content:
              'PT Tunas Siak Anugrah (TSA) berdiri di Pekanbaru pada tanggal 21 September 2020, sebelumnya berbentuk CV dan kini telah menjadi PT. TSA bergerak di bidang pengadaan barang dan jasa, dengan dedikasi terhadap kualitas layanan dan keselamatan.',
            ),
            const SizedBox(height: 20),
            _buildCard(
              title: 'Visi',
              content:
              'Menjadi jasa dan pelayanan dengan standar nasional dan internasional.',
              additionalContentTitle: 'Misi',
              additionalContent:
              '1. Melayani dan menanggapi setiap pelanggan dengan kompetensi tinggi.\n'
                  '2. Memberikan solusi sesuai kebutuhan dengan loyalitas luar biasa.\n'
                  '3. Inovatif dalam setiap aspek layanan.',
            ),
            const SizedBox(height: 20),
            _buildCard(
              title: 'Bidang usaha',
              content:
              'PT Tunas Siak Anugrah bergerak di bidang pengadaan barang dan jasa, meliputi:\n\n'
                  '• Pengadaan barang:\n'
                  '  - Barang besar dan kecil\n'
                  '  - Racking warehouse, gudang, supermarket & minimarket\n'
                  '  - Alat proteksi kebakaran & peralatan keselamatan kerja\n\n'
                  '• Jasa:\n'
                  '  - Layanan pendukung keselamatan kerja dan inspeksi',
            ),
            const SizedBox(height: 20),
            _buildCard(
              title: 'Kontak',
              content:
              '📍 Jl. Tengku Maharatu I Blok D No.05, Kel. Maharani, Kec. Rumbai Barat, Pekanbaru - Riau 28264\n\n'
                  '📞 0811 760 4545 / 0811 576 976\n'
                  '📧 tunassiakanugrah@gmail.com\n'
                  '🌐 tunassiakanugrah.web.indotraning.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String content,
    String? additionalContentTitle,
    String? additionalContent,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title[0].toUpperCase() + title.substring(1),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 16, height: 1.6),
              textAlign: TextAlign.justify,
            ),
            if (additionalContentTitle != null) ...[
              const SizedBox(height: 16),
              Text(
                additionalContentTitle[0].toUpperCase() + additionalContentTitle.substring(1),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                additionalContent ?? '',
                style: const TextStyle(fontSize: 16, height: 1.6),
                textAlign: TextAlign.justify,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
