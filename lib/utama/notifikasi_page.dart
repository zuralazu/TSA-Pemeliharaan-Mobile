import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifikasiList = [
      {
        'judul': 'Laporan Disetujui ✅',
        'deskripsi': 'Laporan pemeliharaan APAR #001 telah disetujui.',
        'tipe': 'success',
        'tanggal': '7 Juli 2025',
        'baru': true,
      },
      {
        'judul': 'Inspeksi Dijadwalkan 📅',
        'deskripsi': 'Inspeksi APAR Gudang B dijadwalkan 10 Juli.',
        'tipe': 'info',
        'tanggal': '6 Juli 2025',
        'baru': false,
      },
      {
        'judul': 'Laporan Ditolak ⚠️',
        'deskripsi': 'Laporan APAR #002 ditolak karena foto tidak jelas.',
        'tipe': 'warning',
        'tanggal': '5 Juli 2025',
        'baru': true,
      },
    ];

    IconData getIcon(String type) {
      switch (type) {
        case 'success':
          return Icons.check_circle_outline;
        case 'info':
          return Icons.info_outline;
        case 'warning':
          return Icons.warning_amber_outlined;
        default:
          return Icons.notifications_none;
      }
    }

    Color getColor(String type) {
      switch (type) {
        case 'success':
          return Colors.greenAccent.shade100;
        case 'info':
          return Colors.lightBlueAccent.shade100;
        case 'warning':
          return Colors.orangeAccent.shade100;
        default:
          return Colors.grey.shade300;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifikasiList.length,
        itemBuilder: (context, index) {
          final item = notifikasiList[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [getColor(item['tipe'])!, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(getIcon(item['tipe']), color: Colors.black87),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['judul'], style: TextStyle(fontWeight: FontWeight.bold)),
                  if (item['baru'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Baru',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['deskripsi'], style: TextStyle(height: 1.3)),
                  const SizedBox(height: 4),
                  Text(item['tanggal'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              isThreeLine: true,
              contentPadding: const EdgeInsets.all(16),
            ),
          );
        },
      ),
    );
  }
}
