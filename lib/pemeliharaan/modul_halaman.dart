import 'package:flutter/material.dart';
import 'package:tunassiakanugrah/pemeliharaan/modul_detail_halaman.dart';
import 'package:tunassiakanugrah/pemeliharaan/qr_code.dart';
import 'package:tunassiakanugrah/utama/dasbor_halaman.dart';

class ModulHalaman extends StatelessWidget {
  const ModulHalaman({super.key});

  // Index "Modul" pada bottom nav dashboard adalah 3.
  static const int _kIndeksModul = 3;

  Future<void> _onNavTap(BuildContext context, int index) async {
    if (index == _kIndeksModul) return; // sudah di halaman ini

    if (index == 2) {
      // Scan QR: sama seperti perilaku di dashboard.
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QrCodeHalaman()),
      );
      if (result == 'refresh') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DasborHalaman()),
              (route) => false,
        );
      }
      return;
    }

    // Beranda (0), Inventory (1), Profil (4): kembali ke dashboard
    // dengan tab yang sesuai, sekaligus membersihkan tumpukan halaman
    // supaya tidak menumpuk banyak route.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => DasborHalaman(initialIndex: index)),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Modul Pemeliharaan',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          const Text(
            'Pilih Jenis Modul',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih peralatan yang ingin dilihat SOP pemeliharaannya',
            style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          _ModulCard(
            title: 'Modul APAR',
            subtitle: 'SOP pemeliharaan tabung pemadam api ringan',
            modulType: 'sop_apar',
            accent: const Color(0xFFE04B3E),
            icon: Icons.local_fire_department_rounded,
          ),
          const SizedBox(height: 14),
          _ModulCard(
            title: 'Modul Fire Hydrant',
            subtitle: 'SOP pemeliharaan hydrant dan kelengkapannya',
            modulType: 'sop_fire_hydrant',
            accent: const Color(0xFF1E6FBF),
            icon: Icons.water_drop_rounded,
          ),
        ],
      ),
      bottomNavigationBar: Container(
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
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Inventory'),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_rounded), label: 'Scan'),
            BottomNavigationBarItem(icon: Icon(Icons.apps_rounded), label: 'Modul'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
          currentIndex: _kIndeksModul,
          selectedItemColor: Colors.blue.shade700,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: (index) => _onNavTap(context, index),
        ),
      ),
    );
  }
}

class _ModulCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String modulType;
  final Color accent;
  final IconData icon;

  const _ModulCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.modulType,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModulDetailHalaman(
                modulType: modulType,
                modulTitle: title,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE9ECF2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}