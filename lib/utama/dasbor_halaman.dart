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
import 'package:tunassiakanugrah/config/env.dart';
import 'package:tunassiakanugrah/model/ringkasan.dart';
import 'package:tunassiakanugrah/utama/shop_webview_halaman.dart';

class DasborHalaman extends StatefulWidget {
  final int initialIndex;

  const DasborHalaman({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _DasborHalamanState createState() => _DasborHalamanState();
}

class _DasborHalamanState extends State<DasborHalaman> {
  late int _indeksTerpilih;
  User? _currentUser;
  RingkasanDashboard? _ringkasanData;
  String? _dropdownTerpilih;
  bool _loadingUser = true;
  bool _loadingRingkasan = true;
  bool _adaNotifBaru = false;
  List<String> _jenisAlat = [];

  @override
  void initState() {
    super.initState();
    _indeksTerpilih = widget.initialIndex;
    _initData();
  }

  Future<void> _initData() async {
    await _loadUserData();
    if (mounted) {
      await _fetchRingkasanData();
    }
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

    final url = Uri.parse('${Env.baseUrl}/api/barang/ringkasan');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
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
        final decoded = jsonDecode(response.body);

        final ringkasan = RingkasanDashboard.fromJson(decoded);

        final List<String> jenis = [];

        if (ringkasan.apar != null && ringkasan.apar!.total > 0) {
          jenis.add('APAR');
        }

        if (ringkasan.hydrant != null && ringkasan.hydrant!.total > 0) {
          jenis.add('HYDRANT');
        }

        setState(() {
          _ringkasanData = ringkasan;
          _jenisAlat = jenis;

          if (_jenisAlat.isNotEmpty) {
            _dropdownTerpilih ??= _jenisAlat.first;
          }

          _loadingRingkasan = false;
        });

        // DEBUG LOG
        print("RINGKASAN: ${response.body}");
        print("JENIS: $_jenisAlat");
        print("DROPDOWN: $_dropdownTerpilih");
      } else {
        setState(() => _loadingRingkasan = false);
      }
    } catch (e) {
      print("ERROR RINGKASAN: $e");
      if (mounted) {
        setState(() => _loadingRingkasan = false);
      }
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
          _ringkasanData?.total.toString() ?? '0',
          Colors.deepPurple,
          Colors.purple,
          Icons.storage,
        ),
        _bangunKartuStatusBaru(
          'Kondisi Baik',
          _ringkasanData?.baik.toString() ?? '0',
          Colors.lightGreen,
          Colors.green,
          Icons.check_circle_outline,
        ),
        _bangunKartuStatusBaru(
          'Perlu Perhatian',
          _ringkasanData?.perluCek.toString() ?? '0',
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

    RingkasanJenis? data;

    if (_dropdownTerpilih == 'APAR') {
      data = _ringkasanData?.apar;
    } else if (_dropdownTerpilih == 'HYDRANT') {
      data = _ringkasanData?.hydrant;
    }

    if (data == null) return Text('Tidak ada data untuk jenis ini');

    final total = data.total.toString();
    final baik = data.baik.toString();
    final perluCek = data.perluCek.toString();

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

  // ---------- Kartu Berita (redesign) ----------
  Widget _bangunKartuBerita({
    required String kategori,
    required Color kategoriColor,
    required IconData icon,
    required String judul,
    required String ringkasan,
    required String tanggal,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDF0F5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kategoriColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: kategoriColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: kategoriColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            kategori.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: kategoriColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tanggal,
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ringkasan,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 22),
            ],
          ),
        ),
      ),
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
                        _bangunTombolAksiCepatBaru(Icons.shopping_bag_outlined, 'Shop', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ShopWebViewHalaman(),
                            ),
                          );
                        }, Colors.blueGrey),
                        _bangunTombolAksiCepatBaru(Icons.menu_book_rounded, 'Modul', () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ModulHalaman()));
                        }, Colors.teal),
                        _bangunTombolAksiCepatBaru(Icons.qr_code_scanner_rounded, 'Scan QR', () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => QrCodeHalaman()));
                        }, Colors.indigo),
                      ],
                    ),
                    SizedBox(height: 30),

                    // ---------- Berita Terkini (redesign) ----------
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
                    _bangunKartuBerita(
                      kategori: 'Jadwal',
                      kategoriColor: const Color(0xFF2563EB),
                      icon: Icons.campaign_rounded,
                      judul: 'Pengecekan rutin akan dilakukan minggu ini',
                      ringkasan: 'Jadwal lengkap pengecekan akan diumumkan oleh supervisor.',
                      tanggal: '3 Jul 2026',
                    ),
                    SizedBox(height: 12),
                    _bangunKartuBerita(
                      kategori: 'SOP',
                      kategoriColor: const Color(0xFF16A34A),
                      icon: Icons.article_rounded,
                      judul: 'Perubahan SOP penggunaan APAR',
                      ringkasan: 'Mulai bulan depan akan ada pelatihan khusus penggunaan alat.',
                      tanggal: '1 Jul 2026',
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