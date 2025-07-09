import 'package:flutter/material.dart';

class ModulDetailHalaman extends StatelessWidget {
  final String modulType;
  final String modulTitle;

  const ModulDetailHalaman({
    Key? key,
    required this.modulType,
    required this.modulTitle,
  }) : super(key: key);

  final Map<String, List<String>> sopData = const {
    'sop_apar': [
      'Periksa kondisi tabung: tidak ada karat, penyok, atau kebocoran.',
      'Periksa selang dan nozzle: tidak retak, tersumbat, atau rusak.',
      'Periksa pressure gauge: jarum harus berada di area hijau.',
      'Periksa safety pin dan segel: harus utuh dan tidak rusak.',
      'APAR jenis Powder: Balikkan tabung untuk mencegah penggumpalan.',
      'APAR jenis Foam: Pastikan cairan tidak mengeras atau kadaluarsa.',
      'Catat tanggal pengecekan dan kondisi komponen.',
      'Lakukan isi ulang jika tekanan/media kurang.',
      'Ganti APAR yang kadaluarsa atau rusak.',
      'Pastikan APAR di tempat yang mudah diakses dan terlihat jelas.',
    ],
    'sop_fire_hydrant': [
      'Periksa kondisi fisik hydrant dan area sekitar.',
      'Putar valve sedikit untuk memastikan tidak macet.',
      'Pastikan selang, nozzle, dan kunci tersedia dan baik.',
      'Periksa tekanan air dan lakukan uji tekanan berkala.',
      'Bersihkan hydrant dan area sekitarnya.',
      'Catat tanggal dan kondisi hydrant.',
      'Lakukan uji fungsi penuh setahun sekali.',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final List<String> sopList = sopData[modulType] ?? ['Modul tidak ditemukan.'];

    return Scaffold(
      appBar: AppBar(
        title: Text(modulTitle),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.blue.shade200],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book_rounded, color: Colors.blue.shade800),
                        SizedBox(width: 10),
                        Text(
                          modulTitle,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    for (int i = 0; i < sopList.length; i++)
                      ListTile(
                        leading: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                          ),
                        ),
                        title: Text(
                          sopList[i],
                          style: const TextStyle(fontSize: 16, height: 1.4),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}