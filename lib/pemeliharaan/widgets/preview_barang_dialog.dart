import 'package:flutter/material.dart';
import 'package:tunassiakanugrah/pemeliharaan/form_laporan.dart';

class PreviewBarangDialog extends StatelessWidget {
  final Map<String, dynamic> data;
  final String qrCode;
  final Map<String, dynamic> inspectionStatus;
  final VoidCallback onBatal;

  const PreviewBarangDialog({
    Key? key,
    required this.data,
    required this.qrCode,
    required this.inspectionStatus,
    required this.onBatal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDue = inspectionStatus['is_due'] == true;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ───────────────────────────────────────────────────────
            _buildHeader(),

            // ── Konten ───────────────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        'Nama Alat',
                        data['nama_barang']?.toString() ?? '-',
                        Icons.label_rounded,
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Tipe',
                        data['tipe_barang_kategori']?.toString() ?? '-',
                        Icons.category_rounded,
                        Colors.purple,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Kode QR',
                        qrCode,
                        Icons.qr_code_rounded,
                        Colors.teal,
                      ),
                      const SizedBox(height: 20),
                      _buildInspectionStatus(isDue),
                    ],
                  ),
                ),
              ),
            ),

            // ── Tombol aksi ───────────────────────────────────────────────────
            _buildActions(context, isDue),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preview Alat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Verifikasi data alat',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[900],
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionStatus(bool isDue) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDue ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDue ? Colors.green.shade300 : Colors.orange.shade300,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isDue ? Icons.check_circle_rounded : Icons.lock_clock_rounded,
                color: isDue ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  inspectionStatus['status_text'] ?? '-',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDue
                        ? Colors.green.shade800
                        : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          if (inspectionStatus['last_inspection'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'Terakhir inspeksi: ${inspectionStatus['last_inspection']}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Colors.grey.shade700),
            ),
          ],
          if (inspectionStatus['next_inspection'] != null)
            Text(
              'Jadwal berikutnya: ${inspectionStatus['next_inspection']}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Colors.grey.shade700),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isDue) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: [
          // Tombol Batal
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: onBatal,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade300, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close_rounded, color: Colors.red, size: 15),
                    const SizedBox(width: 6),
                    const Text(
                      'Batal',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Tombol Lanjut Inspeksi
          Expanded(
            flex: 2,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: isDue
                    ? LinearGradient(colors: [
                        Colors.blue.shade600,
                        Colors.blue.shade800
                      ])
                    : LinearGradient(colors: [
                        Colors.grey.shade400,
                        Colors.grey.shade500
                      ]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isDue
                    ? () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FormulirLaporanHalaman(
                              idAlat: data['id_barang'].toString(),
                              namaAlat: data['nama_barang'] ?? '-',
                              tipeBarang: data['tipe_barang_kategori'],
                              lokasiAlat: data['lokasi_barang'] ?? '-',
                              qrCodeData: qrCode,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.fact_check_rounded,
                        color: Colors.white, size: 17),
                    SizedBox(width: 8),
                    Text(
                      'Lanjut Inspeksi',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
