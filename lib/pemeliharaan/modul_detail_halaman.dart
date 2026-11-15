import 'package:flutter/material.dart';

class ModulDetailHalaman extends StatelessWidget {
  final String modulType;
  final String modulTitle;

  const ModulDetailHalaman({
    super.key,
    required this.modulType,
    required this.modulTitle,
  });

  static const Map<String, List<String>> sopData = {
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

  // Warna aksen berbeda tergantung jenis modul, biar user gampang bedain
  // APAR vs Hydrant secara visual.
  Color get _accentColor {
    switch (modulType) {
      case 'sop_apar':
        return const Color(0xFFE04B3E); // merah - identik dgn APAR
      case 'sop_fire_hydrant':
        return const Color(0xFF1E6FBF); // biru - identik dgn hydrant/air
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData get _headerIcon {
    switch (modulType) {
      case 'sop_apar':
        return Icons.local_fire_department_rounded;
      case 'sop_fire_hydrant':
        return Icons.water_drop_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> sopList =
        sopData[modulType] ?? ['Modul tidak ditemukan.'];
    final accent = _accentColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          modulTitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ---------- Header info card ----------
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_headerIcon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        modulTitle,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SOP Pemeliharaan • ${sopList.length} langkah',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'LANGKAH PEMELIHARAAN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 10),

          // ---------- Step list (timeline style) ----------
          for (int i = 0; i < sopList.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE9ECF2)),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          sopList[i],
                          style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.45,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          // ---------- Footer note ----------
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFCE7A5)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: Color(0xFFB7791F)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pastikan setiap langkah dicentang dan didokumentasikan saat inspeksi lapangan.',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF7A5B12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}