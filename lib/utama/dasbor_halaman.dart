// lib/utama/dasbor_halaman.dart
import 'package:flutter/material.dart';
import 'package:tunassiakanugrah/auth/login_page.dart';
import 'package:tunassiakanugrah/pemeliharaan/qr_code.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:tunassiakanugrah/model/user.dart';
import 'package:tunassiakanugrah/pemeliharaan/modul_halaman.dart'; // Pastikan import ini ada

class DasborHalaman extends StatefulWidget {
  @override
  _DasborHalamanState createState() => _DasborHalamanState();
}

class _DasborHalamanState extends State<DasborHalaman> {
  int _indeksTerpilih = 0;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('user_data');
    if (userDataJson != null) {
      setState(() {
        _currentUser = User.fromJson(jsonDecode(userDataJson));
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) { // Tombol Scan QR di Bottom Nav
      Navigator.push(context, MaterialPageRoute(builder: (context) => QrCodeHalaman()));
    } else if (index == 3) { // Tombol Modul di Bottom Nav
      Navigator.push(context, MaterialPageRoute(builder: (context) => ModulHalaman()));
    }
    else {
      setState(() {
        _indeksTerpilih = index;
      });
    }
  }

  Widget _bangunKartuStatusBaru(String judul, String nilai, MaterialColor color, MaterialColor endColor, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.shade100, endColor.shade400],
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: Colors.white.withOpacity(0.8)),
              SizedBox(height: 8),
              Text(
                judul,
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                nilai,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bangunTombolAksiCepatBaru(IconData ikon, String label, VoidCallback onPressed, MaterialColor color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              child: Icon(ikon, size: 30, color: color.shade800),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _opsiWidget = <Widget>[
      Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang, ${_currentUser?.username ?? "Pengguna"}!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
              ),
              SizedBox(height: 10),
              Text(
                'Ringkasan Status APAR Anda:',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _bangunKartuStatusBaru('Total Alat', '100', Colors.deepPurple, Colors.purple, Icons.storage),
                  _bangunKartuStatusBaru('Kondisi Baik', '90', Colors.lightGreen, Colors.green, Icons.check_circle_outline),
                  _bangunKartuStatusBaru('Perlu Perhatian', '10', Colors.deepOrange, Colors.orange, Icons.warning_amber),
                ],
              ),
              SizedBox(height: 30),
              Text(
                'Aksi Cepat:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _bangunTombolAksiCepatBaru(Icons.report_problem_outlined, 'Rusak &\nExpired', () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Halaman Rusak & Expired belum tersedia')));
                  }, Colors.red),
                  _bangunTombolAksiCepatBaru(Icons.shopping_bag_outlined, 'Shop', () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Halaman Shop belum tersedia')));
                  }, Colors.blueGrey),
                  // Tombol "Modul" dihubungkan ke ModulHalaman
                  _bangunTombolAksiCepatBaru(Icons.menu_book, 'Modul', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ModulHalaman()));
                  }, Colors.teal),
                  _bangunTombolAksiCepatBaru(Icons.qr_code_scanner, 'Scan QR', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => QrCodeHalaman()));
                  }, Colors.indigo),
                ],
              ),
              SizedBox(height: 30),
              Text(
                'Berita & Informasi:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Penting: Pembaruan SOP Pemeliharaan APAR Terbaru!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Tim kami telah merilis pembaruan penting terkait Standar Operasional Prosedur (SOP) untuk pemeliharaan Alat Proteksi Kebakaran (APAR). Mohon periksa bagian "Modul" untuk detail selengkapnya.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 15),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'Baca Selengkapnya >>',
                        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
      Center(child: Text('Halaman Inventaris', style: TextStyle(fontSize: 24))),
      Center(child: Text('Tekan tombol Scan di tengah Bottom Nav untuk memindai QR', style: TextStyle(fontSize: 24), textAlign: TextAlign.center)),
      Center(child: Text('Halaman Modul Pemeliharaan', style: TextStyle(fontSize: 24))),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Halaman Profil Pengguna', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_data');

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                      (Route<dynamic> route) => false,
                );
              },
              icon: Icon(Icons.logout),
              label: Text('Keluar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('APK Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.blue.shade800, size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fitur Notifikasi belum diimplementasikan.')),
              );
            },
          ),
        ],
      ),
      body: _opsiWidget.elementAt(_indeksTerpilih),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'Modul',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _indeksTerpilih,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}