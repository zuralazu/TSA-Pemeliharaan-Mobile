import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InventoryDetailPage extends StatefulWidget {
  final int idBarang;

  const InventoryDetailPage({super.key, required this.idBarang});

  @override
  State<InventoryDetailPage> createState() => _InventoryDetailPageState();
}

class _InventoryDetailPageState extends State<InventoryDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  String _buildFotoUrl(String foto) {
    if (foto.startsWith('http')) {
      return foto;
    }

    if (foto.startsWith('storage/')) {
      return 'http://10.0.2.2:8000/$foto';
    }

    return 'http://10.0.2.2:8000/storage/$foto';
  }


  String formatTanggal(String? isoDate) {
    if (isoDate == null) return '-';
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return "${date.day.toString().padLeft(2, '0')}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.year}";
    } catch (e) {
      return isoDate;
    }
  }

  Future<void> fetchDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/barang/detail/${widget.idBarang}'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _data = json.decode(response.body)['data'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Gagal memuat detail alat'),
              ],
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Color _getKondisiColor(String? kondisi) {
    if (kondisi == null) return Colors.grey;
    switch (kondisi.toLowerCase()) {
      case 'baik':
        return Colors.green;
      case 'rusak':
        return Colors.red;
      case 'perbaikan':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String? status) {
    if (status == null) return Icons.help_outline;
    switch (status.toLowerCase()) {
      case 'aktif':
        return Icons.check_circle;
      case 'tidak aktif':
        return Icons.cancel;
      case 'perbaikan':
        return Icons.build_circle;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Memuat detail...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final inspection = _data?['laporan_terakhir'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // App Bar dengan Gradient
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF1976D2),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1976D2)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Foto
                  inspection != null && inspection['foto'] != null
                      ? Image.network(
                    _buildFotoUrl(inspection['foto']),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 64, color: Colors.white54),
                        ),
                      );
                    },
                  )

                      : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1976D2),
                          const Color(0xFF42A5F5),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.inventory_2,
                        size: 80,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Title at bottom
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _data?['nama_barang'] ?? 'Detail Alat',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _data?['tipe_barang'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Status Card dengan Kondisi
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getKondisiColor(_data?['kondisi']).withOpacity(0.1),
                        _getKondisiColor(_data?['kondisi']).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getKondisiColor(_data?['kondisi']).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getKondisiColor(_data?['kondisi']),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getStatusIcon(_data?['kondisi']),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status Kondisi',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF666666),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _data?['kondisi'] ?? 'Tidak diketahui',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _getKondisiColor(_data?['kondisi']),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Informasi Barang Card
                _buildSectionCard(
                  title: 'Informasi Barang',
                  icon: Icons.info_outline,
                  children: [
                    _buildInfoRow(
                      icon: Icons.inventory_2,
                      label: 'Nama Alat',
                      value: _data?['nama_barang'],
                      color: const Color(0xFF1976D2),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.category,
                      label: 'Tipe',
                      value: _data?['tipe_barang'],
                      color: const Color(0xFF42A5F5),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.assignment,
                      label: 'Kondisi',
                      value: _data?['kondisi'],
                      color: _getKondisiColor(_data?['kondisi']),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Informasi Inspeksi Card
                _buildSectionCard(
                  title: 'Informasi Inspeksi',
                  icon: Icons.search,
                  children: inspection == null
                      ? [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum ada inspeksi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Belum pernah dilakukan inspeksi',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
                      : [
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Tanggal Inspeksi',
                      value: formatTanggal(inspection['tanggal_inspeksi']),
                      color: const Color(0xFF1976D2),
                    ),
                    const SizedBox(height: 12),

                    _buildInfoRow(
                      icon: Icons.place,
                      label: 'Lokasi Alat',
                      value: inspection['lokasi_alat'],
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 12),

                    _buildInfoRow(
                      icon: Icons.health_and_safety,
                      label: 'Kondisi Fisik',
                      value: inspection['kondisi_fisik'],
                      color: const Color(0xFF42A5F5),
                    ),
                    const SizedBox(height: 12),

                    _buildInfoRow(
                      icon: Icons.build,
                      label: 'Tindakan',
                      value: inspection['tindakan'],
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),

                    _buildInfoRow(
                      icon: Icons.verified,
                      label: 'Status Laporan',
                      value: inspection['status'],
                      color: inspection['status'] == 'Pending'
                          ? Colors.orange
                          : Colors.green,
                    ),
                    const SizedBox(height: 12),

                    _buildInfoRow(
                      icon: Icons.person,
                      label: 'Inspektor',
                      value: inspection['username'],
                      color: Colors.teal,
                    ),

                    // ===== KHUSUS APAR (conditional) =====
                    if (inspection['selang'] != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.linear_scale,
                        label: 'Selang',
                        value: inspection['selang'],
                        color: Colors.redAccent,
                      ),
                    ],

                    if (inspection['pressure_gauge'] != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.speed,
                        label: 'Pressure Gauge',
                        value: inspection['pressure_gauge'],
                        color: Colors.indigo,
                      ),
                    ],

                    if (inspection['safety_pin'] != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.lock,
                        label: 'Safety Pin',
                        value: inspection['safety_pin'],
                        color: Colors.brown,
                      ),
                    ],
                  ],

                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey.shade100,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String? value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
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