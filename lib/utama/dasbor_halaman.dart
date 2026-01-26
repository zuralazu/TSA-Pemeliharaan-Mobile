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
  bool _adaNotifBaru = false;
  List<String> _jenisAlat = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initData();
  }

  Future<void> _initData() async {
    await _loadUserData();
    await _fetchRingkasanData();
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  Future<void> _fetchRingkasanData() async {
    if (!mounted) return;
    setState(() => _loadingRingkasan = true);

    final url = Uri.parse('http://10.0.2.2:8000/api/barang/ringkasan');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

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

          _jenisAlat.clear();

          if (data['apar'] != null && data['apar']['total'] > 0) {
            _jenisAlat.add('APAR');
          }
          if (data['hydrant'] != null && data['hydrant']['total'] > 0) {
            _jenisAlat.add('HYDRANT');
          }

          if (_dropdownTerpilih == null && _jenisAlat.isNotEmpty) {
            _dropdownTerpilih = _jenisAlat.first;
          }

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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [startColor, endColor],
          ),
          boxShadow: [
            BoxShadow(
              color: startColor.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {},
            child: Container(
              height: 80,
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, size: 18, color: Colors.white),
                      ),
                      Text(
                        nilai,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    judul,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bangunKartuStatusBaru(String judul, String nilai, MaterialColor color, MaterialColor endColor, IconData icon) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.shade400, endColor.shade600],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 28, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Text(
                    judul,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    nilai,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRingkasanTotal() {
    if (_loadingRingkasan) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
          ),
        ),
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
          Icons.storage,
        ),
        _bangunKartuStatusBaru(
          'Kondisi Baik',
          _ringkasanData['baik']?.toString() ?? '0',
          Colors.lightGreen,
          Colors.green,
          Icons.check_circle_outline,
        ),
        _bangunKartuStatusBaru(
          'Perlu Perhatian',
          _ringkasanData['perlu_cek']?.toString() ?? '0',
          Colors.deepOrange,
          Colors.orange,
          Icons.warning_amber,
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
            _bangunKartuStatusKecil('Total', total, Colors.red.shade400, Colors.red.shade700, Icons.fire_extinguisher),
            _bangunKartuStatusKecil('Baik', baik, Colors.green.shade400, Colors.green.shade700, Icons.check_circle),
            _bangunKartuStatusKecil('Perlu Cek', perluCek, Colors.orange.shade400, Colors.orange.shade700, Icons.warning_amber),
          ],
        ),
      ],
    );
  }

  Widget _bangunTombolAksiCepatBaru(IconData ikon, String label, VoidCallback onPressed, MaterialColor color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.shade300, color.shade600],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 70,
                height: 70,
                alignment: Alignment.center,
                child: Icon(ikon, size: 32, color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getRoleName(String role) {
    return 'Inspektor';
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _indeksTerpilih == 4 || _indeksTerpilih == 1
          ? null
          : AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'APK Tracker',
          style: TextStyle(
            color: Colors.blue.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Stack(
            children: [
              Container(
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.notifications_outlined, color: Colors.blue.shade800, size: 26),
                  onPressed: () {
                    Navigator.pushNamed(context, '/notifikasi').then((_) {
                      setState(() {
                        _adaNotifBaru = false;
                      });
                    });
                  },
                ),
              ),
              if (_adaNotifBaru)
                Positioned(
                  right: 14,
                  top: 14,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _indeksTerpilih == 0
          ? RefreshIndicator(
        color: Colors.blue.shade600,
        onRefresh: _fetchRingkasanData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section dengan Gradient
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade700, Colors.blue.shade900],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang,',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_currentUser?.username ?? "Pengguna"}!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_getRoleName(_currentUser?.role ?? '')}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Ringkasan Status Alat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildRingkasanTotal(),
                    SizedBox(height: 30),

                    if (_jenisAlat.isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Berdasarkan Jenis Alat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _dropdownTerpilih,
                            isExpanded: true,
                            hint: Text(
                              'Pilih Jenis Alat',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blue.shade600),
                            items: _jenisAlat.map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _dropdownTerpilih = value;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      if (_dropdownTerpilih != null) _buildRingkasanJenisAlat(),
                      SizedBox(height: 30),
                    ],

                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Aksi Cepat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _bangunTombolAksiCepatBaru(Icons.shopping_bag_outlined, 'Shop', () {}, Colors.blueGrey),
                        _bangunTombolAksiCepatBaru(Icons.menu_book_rounded, 'Modul', () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ModulHalaman()));
                        }, Colors.teal),
                        _bangunTombolAksiCepatBaru(Icons.qr_code_scanner_rounded, 'Scan QR', () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => QrCodeHalaman()));
                        }, Colors.indigo),
                      ],
                    ),
                    SizedBox(height: 30),

                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Berita Terkini',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.campaign_rounded, color: Colors.blueAccent, size: 26),
                        ),
                        title: Text(
                          'Pengecekan rutin akan dilakukan minggu ini',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Jadwal lengkap pengecekan akan diumumkan oleh supervisor.',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.article_rounded, color: Colors.green, size: 26),
                        ),
                        title: Text(
                          'Perubahan SOP penggunaan APAR',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Mulai bulan depan akan ada pelatihan khusus penggunaan alat.',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Inventory'),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_rounded), label: 'Scan'),
            BottomNavigationBarItem(icon: Icon(Icons.apps_rounded), label: 'Modul'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
          currentIndex: _indeksTerpilih,
          selectedItemColor: Colors.blue.shade700,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
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
        ),
      ),
    );
  }
}