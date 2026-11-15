// lib/utama/dasbor_halaman.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunassiakanugrah/auth/login_page.dart';
import 'package:tunassiakanugrah/model/user.dart';
import 'package:tunassiakanugrah/model/ringkasan.dart';
import 'package:tunassiakanugrah/config/env.dart';
import 'package:tunassiakanugrah/pemeliharaan/modul_halaman.dart';
import 'package:tunassiakanugrah/pemeliharaan/qr_code.dart';
import 'package:tunassiakanugrah/utama/inventory_page.dart';
import 'package:tunassiakanugrah/utama/kelola_akun_page.dart';
import 'package:tunassiakanugrah/utama/shop_webview_halaman.dart';
import 'package:tunassiakanugrah/utama/widgets/dashboard_header.dart';
import 'package:tunassiakanugrah/utama/widgets/news_card.dart';
import 'package:tunassiakanugrah/utama/widgets/quick_action_button.dart';
import 'package:tunassiakanugrah/utama/widgets/stat_card.dart';
import 'package:tunassiakanugrah/widgets/common/section_header.dart';

class DasborHalaman extends StatefulWidget {
  final int initialIndex;

  const DasborHalaman({super.key, this.initialIndex = 0});

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
    if (mounted) await _fetchRingkasanData();
  }

  // ── Data loading ─────────────────────────────────────────────────────────

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString('user_data');
    if (userDataJson != null) {
      setState(() {
        _currentUser = User.fromJson(jsonDecode(userDataJson));
        _loadingUser = false;
      });
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  Future<void> _fetchRingkasanData() async {
    if (!mounted) return;
    setState(() => _loadingRingkasan = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginPage()));
        return;
      }

      final response = await http.get(
        Uri.parse('${Env.baseUrl}/api/barang/ringkasan'),
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

        final jenis = <String>[];
        if (ringkasan.apar != null && ringkasan.apar!.total > 0) {
          jenis.add('APAR');
        }
        if (ringkasan.hydrant != null && ringkasan.hydrant!.total > 0) {
          jenis.add('HYDRANT');
        }

        setState(() {
          _ringkasanData = ringkasan;
          _jenisAlat = jenis;
          if (_jenisAlat.isNotEmpty) _dropdownTerpilih ??= _jenisAlat.first;
          _loadingRingkasan = false;
        });
      } else {
        setState(() => _loadingRingkasan = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loadingRingkasan = false);
    }
  }

  // ── Widget builders ───────────────────────────────────────────────────────

  Widget _buildRingkasanTotal() {
    if (_loadingRingkasan) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StatCardLarge(
          title: 'Total Alat',
          value: _ringkasanData?.total.toString() ?? '0',
          icon: Icons.storage,
          startColor: Colors.deepPurple,
          endColor: Colors.purple,
        ),
        StatCardLarge(
          title: 'Kondisi Baik',
          value: _ringkasanData?.baik.toString() ?? '0',
          icon: Icons.check_circle_outline,
          startColor: Colors.lightGreen,
          endColor: Colors.green,
        ),
        StatCardLarge(
          title: 'Perlu Perhatian',
          value: _ringkasanData?.perluCek.toString() ?? '0',
          icon: Icons.warning_amber,
          startColor: Colors.deepOrange,
          endColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildRingkasanJenisAlat() {
    if (_loadingRingkasan) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_dropdownTerpilih == null) return const SizedBox.shrink();

    RingkasanJenis? data;
    if (_dropdownTerpilih == 'APAR') {
      data = _ringkasanData?.apar;
    } else if (_dropdownTerpilih == 'HYDRANT') {
      data = _ringkasanData?.hydrant;
    }

    if (data == null) return const Text('Tidak ada data untuk jenis ini');

    return Row(
      children: [
        StatCardSmall(
          title: 'Total',
          value: data.total.toString(),
          icon: Icons.fire_extinguisher,
          startColor: Colors.red.shade400,
          endColor: Colors.red.shade700,
        ),
        StatCardSmall(
          title: 'Baik',
          value: data.baik.toString(),
          icon: Icons.check_circle,
          startColor: Colors.green.shade400,
          endColor: Colors.green.shade700,
        ),
        StatCardSmall(
          title: 'Perlu Cek',
          value: data.perluCek.toString(),
          icon: Icons.warning_amber,
          startColor: Colors.orange.shade400,
          endColor: Colors.orange.shade700,
        ),
      ],
    );
  }

  Widget _buildDropdownJenisAlat() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _dropdownTerpilih,
          isExpanded: true,
          hint: Text('Pilih Jenis Alat',
              style: TextStyle(color: Colors.grey[600])),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.blue.shade600),
          items: _jenisAlat.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.grey[800])),
            );
          }).toList(),
          onChanged: (value) => setState(() => _dropdownTerpilih = value),
        ),
      ),
    );
  }

  Widget _buildHalamanBeranda() {
    return RefreshIndicator(
      color: Colors.blue.shade600,
      onRefresh: _fetchRingkasanData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header selamat datang ──────────────────────────────────────
            DashboardHeader(user: _currentUser),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Ringkasan total ──────────────────────────────────────
                  const SectionHeader(title: 'Ringkasan Status Alat'),
                  const SizedBox(height: 20),
                  _buildRingkasanTotal(),
                  const SizedBox(height: 30),

                  // ── Ringkasan per jenis ──────────────────────────────────
                  if (_jenisAlat.isNotEmpty) ...[
                    const SectionHeader(title: 'Berdasarkan Jenis Alat'),
                    const SizedBox(height: 16),
                    _buildDropdownJenisAlat(),
                    const SizedBox(height: 16),
                    if (_dropdownTerpilih != null) _buildRingkasanJenisAlat(),
                    const SizedBox(height: 30),
                  ],

                  // ── Aksi cepat ───────────────────────────────────────────
                  const SectionHeader(title: 'Aksi Cepat'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      QuickActionButton(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Shop',
                        color: Colors.blueGrey,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ShopWebViewHalaman()),
                        ),
                      ),
                      QuickActionButton(
                        icon: Icons.menu_book_rounded,
                        label: 'Modul',
                        color: Colors.teal,
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => ModulHalaman())),
                      ),
                      QuickActionButton(
                        icon: Icons.qr_code_scanner_rounded,
                        label: 'Scan QR',
                        color: Colors.indigo,
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => QrCodeHalaman())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // ── Berita terkini ───────────────────────────────────────
                  const SectionHeader(title: 'Berita Terkini'),
                  const SizedBox(height: 16),
                  NewsCard(
                    kategori: 'Jadwal',
                    kategoriColor: const Color(0xFF2563EB),
                    icon: Icons.campaign_rounded,
                    judul: 'Pengecekan rutin akan dilakukan minggu ini',
                    ringkasan:
                        'Jadwal lengkap pengecekan akan diumumkan oleh supervisor.',
                    tanggal: '3 Jul 2026',
                  ),
                  const SizedBox(height: 12),
                  NewsCard(
                    kategori: 'SOP',
                    kategoriColor: const Color(0xFF16A34A),
                    icon: Icons.article_rounded,
                    judul: 'Perubahan SOP penggunaan APAR',
                    ringkasan:
                        'Mulai bulan depan akan ada pelatihan khusus penggunaan alat.',
                    tanggal: '1 Jul 2026',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
          : _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(Icons.notifications_outlined,
                    color: Colors.blue.shade800, size: 26),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifikasi').then((_) {
                    setState(() => _adaNotifBaru = false);
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
    );
  }

  Widget _buildBody() {
    switch (_indeksTerpilih) {
      case 0:
        return _buildHalamanBeranda();
      case 1:
        return InventoryPage();
      case 4:
        return KelolaAkunPage();
      default:
        return const Center(child: Text('Halaman belum tersedia'));
    }
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded), label: 'Inventory'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_rounded), label: 'Scan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.apps_rounded), label: 'Modul'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
        currentIndex: _indeksTerpilih,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        onTap: _onNavTap,
      ),
    );
  }

  Future<void> _onNavTap(int index) async {
    if (index == 2) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QrCodeHalaman()),
      );
      if (result == 'refresh') {
        await _fetchRingkasanData();
        setState(() => _indeksTerpilih = 0);
      }
    } else if (index == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => ModulHalaman()));
    } else {
      setState(() => _indeksTerpilih = index);
    }
  }
}