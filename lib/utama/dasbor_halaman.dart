// lib/utama/dasbor_halaman.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunassiakanugrah/auth/login_page.dart';
import 'package:tunassiakanugrah/model/user.dart';
import 'package:tunassiakanugrah/pemeliharaan/modul_halaman.dart';
import 'package:tunassiakanugrah/pemeliharaan/qr_code.dart';
import 'package:tunassiakanugrah/utama/kelola_akun_page.dart';
import 'package:tunassiakanugrah/utama/inventory_page.dart';

class DasborHalaman extends StatefulWidget {
  @override
  _DasborHalamanState createState() => _DasborHalamanState();
}

class _DasborHalamanState extends State<DasborHalaman> {
  int _indeksTerpilih = 0;
  User? _currentUser;
  Map<String, dynamic> _ringkasanData = {};
  String? _dropdownTerpilih;
  bool _loadingUser = true;
  bool _loadingRingkasan = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchRingkasanData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString('user_data');
    if (userDataJson != null) {
      setState(() {
        _currentUser = User.fromJson(jsonDecode(userDataJson));
        _loadingUser = false;
      });
    } else {
      // jika tidak ada user, arahkan ke login
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  Future<void> _fetchRingkasanData() async {
    if (!mounted) return;
    setState(() => _loadingRingkasan = true);

    // Pastikan Anda menggunakan URL yang benar untuk server lokal
    final url = Uri.parse('http://10.0.2.2:8000/api/barang/ringkasan');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // 💡 PERBAIKI: Ganti kunci dari 'auth_token' menjadi 'access_token'
      String? token = prefs.getString('access_token');

      // Tambahkan log untuk debugging token
      print("Menggunakan token: $token");

      if (token == null) {
        print("Token tidak ditemukan, mengarahkan ke login.");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
        return;
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Kirim token yang sudah pasti ada
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          _ringkasanData = data;
          _loadingRingkasan = false;
        });
      } else {
        print("Gagal ambil data: ${response.statusCode}");
        print("Response Body: ${response.body}");
        setState(() => _loadingRingkasan = false);
      }
    } catch (e) {
      print("Terjadi error saat fetch data: $e");
      if (!mounted) return;
      setState(() => _loadingRingkasan = false);
    }
  }


  Widget _bangunKartuStatusKecil(String judul, String nilai, Color startColor, Color endColor, IconData icon) {
    return Flexible(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [startColor.withOpacity(0.8), endColor],
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  judul,
                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                nilai,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildRingkasanTotal() {
    if (_loadingRingkasan) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _bangunKartuStatusBaru(
            'Total Alat',
            _ringkasanData['total']?.toString() ?? '0',
            Colors.deepPurple,
            Colors.purple,
            Icons.storage
        ),
        _bangunKartuStatusBaru(
            'Kondisi Baik',
            _ringkasanData['baik']?.toString() ?? '0',
            Colors.lightGreen,
            Colors.green,
            Icons.check_circle_outline
        ),
        _bangunKartuStatusBaru(
            'Perlu Perhatian',
            _ringkasanData['perlu_cek']?.toString() ?? '0',
            Colors.deepOrange,
            Colors.orange,
            Icons.warning_amber
        ),
      ],
    );
  }

  Widget _buildRingkasanJenisAlat() {
    if (_loadingRingkasan) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_dropdownTerpilih == null) return SizedBox.shrink();

    final data = _ringkasanData[_dropdownTerpilih!.toLowerCase()];
    if (data == null) return Text('Tidak ada data untuk jenis ini');

    final total = data['total']?.toString() ?? '0';
    final baik = data['baik']?.toString() ?? '0';
    final perluCek = data['perlu_cek']?.toString() ?? '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _bangunKartuStatusKecil('Total', total, Colors.red.shade300, Colors.red, Icons.fire_extinguisher),
            _bangunKartuStatusKecil('Baik', baik, Colors.green.shade300, Colors.green, Icons.check_circle),
            _bangunKartuStatusKecil('Perlu Cek', perluCek, Colors.orange.shade300, Colors.orange, Icons.warning_amber),
          ],
        ),
      ],
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

  // Method untuk mendapatkan nama role yang lebih user-friendly
  String _getRoleName(String role) {
    switch (role) {
      case 'staff_gudang':
        return 'Staff Gudang';
      case 'supervisor_umum':
        return 'Supervisor Umum';
      case 'inspektor':
        return 'Inspektor';
      default:
        return 'Pengguna';
    }
  }

  @override
  Widget build(BuildContext context) {
    // loading user
    if (_loadingUser) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _indeksTerpilih == 4
          ? null
          : AppBar(
        automaticallyImplyLeading: false,
        title: const Text('APK Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.blue.shade800, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, '/notifikasi');
            },
          ),
        ],
      ),
      body: _indeksTerpilih == 0
          ? RefreshIndicator(
        onRefresh: _fetchRingkasanData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Selamat Datang, ${_currentUser?.username ?? "Pengguna"}!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue.shade800)
              ),
              Text(
                  '${_getRoleName(_currentUser?.role ?? '')}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic)
              ),
              SizedBox(height: 10),
              Text('Ringkasan Status Alat:', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              SizedBox(height: 25),
              _buildRingkasanTotal(),
              SizedBox(height: 30),

              // Tampilkan ringkasan jenis alat hanya untuk staff_gudang
              if (_currentUser?.role == 'staff_gudang') ...[
                Text(
                    'Ringkasan Berdasarkan Jenis Alat:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: _dropdownTerpilih,
                  hint: Text('Pilih Jenis Alat'),
                  isExpanded: true,
                  items: ['APAR', 'HYDRANT'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _dropdownTerpilih = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                if (_dropdownTerpilih != null) _buildRingkasanJenisAlat(),
                SizedBox(height: 30),
              ],

              Text('Aksi Cepat:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _bangunTombolAksiCepatBaru(Icons.report_problem_outlined, 'Rusak &\nExpired', () {}, Colors.red),
                  _bangunTombolAksiCepatBaru(Icons.shopping_bag_outlined, 'Shop', () {}, Colors.blueGrey),
                  _bangunTombolAksiCepatBaru(Icons.menu_book, 'Modul', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ModulHalaman()));
                  }, Colors.teal),
                  _bangunTombolAksiCepatBaru(Icons.qr_code_scanner, 'Scan QR', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => QrCodeHalaman()));
                  }, Colors.indigo),
                ],
              ),
              SizedBox(height: 30),
              Text('Berita Terkini:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
              SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: Icon(Icons.campaign, color: Colors.blueAccent),
                  title: Text('Pengecekan rutin akan dilakukan minggu ini'),
                  subtitle: Text('Jadwal lengkap pengecekan akan diumumkan oleh supervisor.'),
                ),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: Icon(Icons.newspaper, color: Colors.green),
                  title: Text('Perubahan SOP penggunaan APAR'),
                  subtitle: Text('Mulai bulan depan akan ada pelatihan khusus penggunaan alat.'),
                ),
              ),
            ],
          ),
        ),
      )
          : _indeksTerpilih == 1
          ? InventoryPage()
          : _indeksTerpilih == 4
          ? KelolaAkunPage()
          : Center(child: Text('Halaman belum tersedia')),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Inventory'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Modul'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _indeksTerpilih,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          if (index == 2) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QrCodeHalaman()),
            );
            if (result == 'refresh') {
              await _fetchRingkasanData();
              setState(() {
                _indeksTerpilih = 0;
              });
            }
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ModulHalaman()));
          } else {
            setState(() {
              _indeksTerpilih = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}