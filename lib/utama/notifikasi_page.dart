import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  List<Map<String, dynamic>> notifikasiList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifikasi();
  }

  Future<void> fetchNotifikasi() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/notifikasi'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = json.decode(response.body);
      final List<dynamic> data = responseJson['data'];

      final List<Map<String, dynamic>> hasil = data.map<Map<String, dynamic>>((item) {
        final barang = item['barang'] ?? {};
        return {
          'judul': item['judul'] ?? 'Notifikasi',
          'deskripsi': item['deskripsi'] ?? 'Tidak ada deskripsi.',
          'tipe': item['tipe'] ?? 'info',
          'tanggal': item['tanggal'] ?? 'Tidak diketahui',
          'baru': item['baru'] ?? false,
          'nama_barang': barang['nama_barang'] ?? 'Tidak diketahui',
          'lokasi': barang['lokasi'] ?? 'Tidak diketahui',
        };
      }).toList();


      setState(() {
        notifikasiList = hasil;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('[ERROR] Gagal memuat notifikasi (${response.statusCode})');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notifikasiList.isEmpty
          ? Center(
        child: Text(
          'Tidak ada notifikasi barang yang belum dicek.',
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.builder(
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
                  Expanded(
                    child: Text(
                      item['judul'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
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
