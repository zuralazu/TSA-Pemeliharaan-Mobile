import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunassiakanugrah/config/env.dart';

class InventoryDetailPage extends StatefulWidget {
  final String nomorIdentifikasi;

  const InventoryDetailPage({
    super.key,
    required this.nomorIdentifikasi,
  });

  @override
  State<InventoryDetailPage> createState() => _InventoryDetailPageState();
}

class _InventoryDetailPageState extends State<InventoryDetailPage>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ─── THEME COLORS ──────────────────────────────────────────────────────────
  static const Color _primary       = Color(0xFF0A6EBD);
  static const Color _primaryLight  = Color(0xFF3B9FE8);
  static const Color _accent        = Color(0xFF00D4AA);
  static const Color _bgPage        = Color(0xFFF0F4F8);
  static const Color _bgCard        = Color(0xFFFFFFFF);
  static const Color _textPrimary   = Color(0xFF0F1B2D);
  static const Color _textSecondary = Color(0xFF637083);
  static const Color _divider       = Color(0xFFE8EEF4);

  static const Color _goodColor     = Color(0xFF00C897);
  static const Color _badColor      = Color(0xFFFF4C6A);
  static const Color _warnColor     = Color(0xFFFF9500);
  static const Color _infoColor     = Color(0xFF3B9FE8);

  @override
  void initState() {
    super.initState();
    _fadeController  = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnimation   = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnimation  = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    fetchDetail();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────
  String _buildFotoUrl(String foto) {
    if (foto.isEmpty) return '';
    if (foto.startsWith('http')) return foto;
    // Backend kirim: "foto_laporan/xxxx.jpg" -> kita ambil nama file-nya aja,
    // karena route /foto-laporan/{filename} sudah otomatis nambahin folder itu.
    final filename = foto.split('/').last;
    final url = '${Env.baseUrl}/foto-laporan/$filename';
    print("🔗 URL foto yang dibangun: $url"); // DEBUG LOG
    return url;
  }

  String formatTanggal(String? isoDate) {
    if (isoDate == null) return '-';
    try {
      final date = DateTime.parse(isoDate).toLocal();
      const bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return "${date.day.toString().padLeft(2, '0')} ${bulan[date.month]} ${date.year}";
    } catch (_) {
      return isoDate;
    }
  }

  Future<void> fetchDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse('${Env.baseUrl}/api/barang/detail/${widget.nomorIdentifikasi}'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("STATUS CODE: ${response.statusCode}");
    print("RAW BODY: ${response.body}");


    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      setState(() {
        _data = body['data'];
        _isLoading = false;
      });
      _fadeController.forward();
      _slideController.forward();

      // DEBUG: cek langsung status HTTP dari URL foto (tanpa lewat Image.network)
      final inspection = _data?['laporan_terakhir'];
      if (inspection != null && inspection['foto'] != null) {
        _debugCekFotoUrl(inspection['foto']);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  // ─── DEBUG: cek manual status HTTP dari URL foto ───────────────────────────
  Future<void> _debugCekFotoUrl(String foto) async {
    final url = _buildFotoUrl(foto);
    print("🕵️ [DEBUG FOTO] Mengecek URL: $url");
    try {
      final res = await http.get(Uri.parse(url));
      print("🕵️ [DEBUG FOTO] Status Code: ${res.statusCode}");
      print("🕵️ [DEBUG FOTO] Content-Type: ${res.headers['content-type']}");
      print("🕵️ [DEBUG FOTO] Content-Length: ${res.headers['content-length']}");
      if (res.statusCode != 200) {
        print("🕵️ [DEBUG FOTO] Body (jika error, biasanya HTML/JSON pesan error): "
            "${res.body.substring(0, res.body.length > 300 ? 300 : res.body.length)}");
      }
    } catch (e) {
      print("🕵️ [DEBUG FOTO] Exception saat fetch: $e");
    }
  }

  Color _kondisiColor(String? k) {
    if (k == null) return Colors.grey;
    switch (k.toLowerCase()) {
      case 'baik':       return _goodColor;
      case 'rusak':      return _badColor;
      case 'perbaikan':
      case 'perlu cek':  return _warnColor;
      default:           return _infoColor;
    }
  }

  IconData _kondisiIcon(String? k) {
    if (k == null) return Icons.help_outline_rounded;
    switch (k.toLowerCase()) {
      case 'baik':       return Icons.verified_rounded;
      case 'rusak':      return Icons.cancel_rounded;
      case 'perbaikan':  return Icons.handyman_rounded;
      case 'perlu cek':  return Icons.search_rounded;
      default:           return Icons.info_rounded;
    }
  }

  // ─── LOADING SCREEN ────────────────────────────────────────────────────────
  Widget _buildLoading() => Scaffold(
    backgroundColor: _bgPage,
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primary, _primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.35),
                  blurRadius: 24, offset: const Offset(0, 8),
                )
              ],
            ),
            child: const Center(
              child: SizedBox(
                width: 36, height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Memuat data...',
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: _textSecondary, letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    ),
  );

  // ─── HERO IMAGE (banner atas, tetap ada sebagai dekorasi) ──────────────────
  Widget _buildHeroImage(Map<String, dynamic>? inspection) {
    if (inspection != null && inspection['foto'] != null) {
      return Image.network(
        _buildFotoUrl(inspection['foto']),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("❌ [HERO IMAGE] Gagal load: $error"); // DEBUG LOG
          return _heroFallback();
        },
      );
    }
    return _heroFallback();
  }

  Widget _heroFallback() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF063970), _primary, _primaryLight],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
    ),
    child: Stack(children: [
      Positioned(top: -40, right: -40,
          child: Container(width: 180, height: 180,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06)))),
      Positioned(bottom: -20, left: -30,
          child: Container(width: 140, height: 140,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05)))),
      const Center(child: Icon(Icons.inventory_2_rounded, size: 72, color: Colors.white38)),
    ]),
  );

  // ─── FOTO LAPORAN (preview jelas + tap untuk fullscreen) ───────────────────
  void _bukaFotoFullscreen(BuildContext context, String url) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => _FotoFullscreenViewer(url: url),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  Widget _buildFotoLaporan(BuildContext context, String? foto) {
    if (foto == null || foto.isEmpty) {
      return Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _bgPage,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined, color: _textSecondary.withOpacity(0.5), size: 32),
            const SizedBox(height: 8),
            Text('Tidak ada foto pada laporan ini',
                style: TextStyle(fontSize: 12.5, color: _textSecondary.withOpacity(0.8))),
          ],
        ),
      );
    }

    final url = _buildFotoUrl(foto);

    return GestureDetector(
      onTap: () => _bukaFotoFullscreen(context, url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: _bgPage,
                    child: const Center(
                      child: SizedBox(
                        width: 28, height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: _primary),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  // DEBUG LOG — lihat ini di console pas foto gagal load
                  print("❌ GAGAL LOAD FOTO");
                  print("❌ URL yang dicoba: $url");
                  print("❌ Error: $error");
                  print("❌ Error type: ${error.runtimeType}");
                  return Container(
                    color: _bgPage,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_rounded, color: _textSecondary.withOpacity(0.5), size: 32),
                        const SizedBox(height: 8),
                        Text('Gagal memuat foto',
                            style: TextStyle(fontSize: 12.5, color: _textSecondary.withOpacity(0.8))),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: 10, bottom: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STATUS BADGE ──────────────────────────────────────────────────────────
  Widget _buildStatusBadge() {
    final kondisi = _data?['kondisi'];
    final color   = _kondisiColor(kondisi);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4),
                blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Icon(_kondisiIcon(kondisi), color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Status Kondisi',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: _textSecondary, letterSpacing: 0.8)),
          const SizedBox(height: 4),
          Text(kondisi ?? '-',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                  color: color, letterSpacing: -0.3)),
        ]),
        const Spacer(),
      ]),
    );
  }

  // ─── SECTION TITLE ─────────────────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon, Color accent) => Row(children: [
    Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
          color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 20, color: accent),
    ),
    const SizedBox(width: 12),
    Text(title, style: const TextStyle(
        fontSize: 17, fontWeight: FontWeight.w800,
        color: _textPrimary, letterSpacing: -0.2)),
  ]);

  // ─── INFO ROW ──────────────────────────────────────────────────────────────
  Widget _infoRow(String label, dynamic value, {Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 130,
              child: Text(label, style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _textSecondary))),
          const Text('  ·  ',
              style: TextStyle(color: Color(0xFFCFD8E3), fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(value?.toString() ?? '-',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: valueColor ?? _textPrimary))),
        ]),
      );

  Widget _infoDivider() => const Divider(color: _divider, height: 1);

  // ─── KOMPONEN CHIP ─────────────────────────────────────────────────────────
  Widget _chipRow(String label, String? value) {
    Color chipColor;
    IconData chipIcon;
    if (value == null || value.isEmpty || value == '-') {
      chipColor = Colors.grey; chipIcon = Icons.remove_circle_outline_rounded;
    } else if (value.toLowerCase() == 'baik' || value.toLowerCase() == 'ok') {
      chipColor = _goodColor; chipIcon = Icons.check_circle_rounded;
    } else {
      chipColor = _warnColor; chipIcon = Icons.warning_rounded;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(width: 130,
            child: Text(label, style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: _textSecondary))),
        const Text('  ·  ',
            style: TextStyle(color: Color(0xFFCFD8E3), fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: chipColor.withOpacity(0.12), borderRadius: BorderRadius.circular(50),
              border: Border.all(color: chipColor.withOpacity(0.3))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(chipIcon, size: 13, color: chipColor),
            const SizedBox(width: 5),
            Text(value ?? '-',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: chipColor)),
          ]),
        ),
      ]),
    );
  }

  // ─── CARD WRAPPER ──────────────────────────────────────────────────────────
  Widget _card({required Widget child, EdgeInsets? margin}) => Container(
    margin: margin ?? const EdgeInsets.fromLTRB(20, 0, 20, 0),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _bgCard,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(color: const Color(0xFF0A6EBD).withOpacity(0.06),
            blurRadius: 24, offset: const Offset(0, 8)),
        BoxShadow(color: Colors.black.withOpacity(0.03),
            blurRadius: 6, offset: const Offset(0, 2)),
      ],
    ),
    child: child,
  );

  Widget _buildEmptyInspection() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: 64, height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: _divider, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.assignment_late_rounded, color: _textSecondary, size: 32),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text('Belum Ada Laporan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textPrimary)),
        ),
        const SizedBox(height: 6),
        const Center(
          child: Text('Laporan inspeksi belum tersedia\nuntuk alat ini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _textSecondary, height: 1.5)),
        ),
      ],
    ),
  );

  // ─── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoading();

    final inspection = _data?['laporan_terakhir'];

    return Scaffold(
      backgroundColor: _bgPage,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [

              // ── SLIVER APP BAR ───────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                stretch: true,
                backgroundColor: _primary,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12),
                        blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: _primary, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildHeroImage(inspection),

                      // overlay gradient
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 0.45, 1.0],
                            colors: [Colors.transparent, Colors.transparent, Color(0xE0001E3A)],
                          ),
                        ),
                      ),

                      // title block
                      Positioned(
                        bottom: 20, left: 20, right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_data?['tipe_barang_kategori'] != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _accent.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _data!['tipe_barang_kategori'].toString().toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10,
                                      fontWeight: FontWeight.w800, letterSpacing: 1.5),
                                ),
                              ),
                            Text(
                              _data?['nama_barang'] ?? 'Detail Alat',
                              style: const TextStyle(
                                color: Colors.white, fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5, height: 1.2,
                                shadows: [Shadow(color: Colors.black38,
                                    blurRadius: 12, offset: Offset(0, 2))],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.qr_code_2_rounded,
                                  color: Colors.white60, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                _data?['qr_code'] ?? widget.nomorIdentifikasi,
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── CONTENT ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  children: [

                    // STATUS BADGE
                    _buildStatusBadge(),
                    const SizedBox(height: 20),

                    // ── INFORMASI ALAT ────────────────────────────────────
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('Informasi Alat',
                              Icons.inventory_2_rounded, _primary),
                          const SizedBox(height: 18),
                          _infoRow('QR Code',    _data?['qr_code']),
                          _infoDivider(),
                          _infoRow('ID Barang',  _data?['id_barang']?.toString()),
                          _infoDivider(),
                          _infoRow('Nama Barang', _data?['nama_barang']),
                          _infoDivider(),
                          _infoRow('Tipe Barang Kategori', _data?['tipe_barang_kategori']),
                          _infoDivider(),
                          _infoRow('Kondisi', _data?['kondisi'],
                              valueColor: _kondisiColor(_data?['kondisi'])),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── LAPORAN TERAKHIR ──────────────────────────────────
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('Laporan Inspeksi Terakhir',
                              Icons.assignment_turned_in_rounded, _accent),
                          const SizedBox(height: 18),

                          if (inspection == null)
                            _buildEmptyInspection()
                          else ...[
                            // ── FOTO LAPORAN (preview jelas) ──────────────
                            _buildFotoLaporan(context, inspection['foto']),
                            const SizedBox(height: 16),

                            // date highlight
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: _primary.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(children: [
                                const Icon(Icons.calendar_today_rounded,
                                    color: _primary, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  formatTanggal(inspection['tanggal_inspeksi']),
                                  style: const TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w700, color: _primary),
                                ),
                              ]),
                            ),

                            _infoRow('Kondisi Fisik', inspection['kondisi_fisik'],
                                valueColor: _kondisiColor(inspection['kondisi_fisik'])),
                            _infoDivider(),
                            _infoRow('Status', inspection['status'],
                                valueColor: _kondisiColor(inspection['status'])),
                            _infoDivider(),
                            _infoRow('Lokasi',   inspection['lokasi_alat']),
                            _infoDivider(),
                            _infoRow('Tindakan', inspection['tindakan']),
                            _infoDivider(),
                            _infoRow('Petugas',  inspection['username']),

                            const SizedBox(height: 16),

                            // komponen chips
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _bgPage,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Komponen',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: _textSecondary,
                                          letterSpacing: 0.8)),
                                  const SizedBox(height: 10),

                                  // ===== APAR =====
                                  if ((_data?['tipe_barang_kategori'] ?? '').toString().toLowerCase() == 'apar') ...[
                                    _chipRow('Selang', inspection['selang']?.toString()),
                                    _chipRow('Pressure Gauge', inspection['pressure_gauge']?.toString()),
                                    _chipRow('Safety Pin', inspection['safety_pin']?.toString()),
                                  ]

                                  // ===== HYDRANT =====
                                  else if ((_data?['tipe_barang_kategori'] ?? '').toString().toLowerCase() == 'hydrant') ...[
                                    _chipRow('Tekanan Air', inspection['tekanan_air']?.toString()),
                                    _chipRow('Katup', inspection['katup']?.toString()),
                                    _chipRow('Selang Hydrant', inspection['selang_hydrant']?.toString()),
                                  ],
                                ],
                              ),
                            ),

                            // ===== CATATAN VALIDASI JIKA DITOLAK =====
                            if ((inspection['status'] ?? '').toString().toLowerCase() == 'ditolak') ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _badColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: _badColor.withOpacity(0.3)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.error_rounded, color: _badColor, size: 22),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Catatan Validasi',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: _badColor,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            inspection['catatan_validasi'] ?? 'Tidak ada catatan.',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF8A1C2B),
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

// ─── FULLSCREEN VIEWER ────────────────────────────────────────────────────
class _FotoFullscreenViewer extends StatelessWidget {
  final String url;

  const _FotoFullscreenViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white54,
                  size: 48,
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}