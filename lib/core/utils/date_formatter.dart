// lib/core/utils/date_formatter.dart
// Helper untuk memformat tanggal agar konsisten di seluruh aplikasi.

class DateFormatter {
  DateFormatter._();

  static const _bulan = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  /// Format: "20 Okt 2026"
  static String formatTanggal(String? isoDate) {
    if (isoDate == null) return '-';
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return '${date.day.toString().padLeft(2, '0')} ${_bulan[date.month]} ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  /// Format: "2026-10-20"
  static String formatYMD(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Format: "5 hari lalu"
  static String inspectionAge(String isoDate) {
    try {
      final last = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(last).inDays;
      return '$diff hari lalu';
    } catch (_) {
      return '-';
    }
  }
}
