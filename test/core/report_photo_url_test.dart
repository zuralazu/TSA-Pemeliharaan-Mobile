import 'package:flutter_test/flutter_test.dart';
import 'package:tunassiakanugrah/core/utils/report_photo_url.dart';

void main() {
  group('reportPhotoUrl', () {
    test('keeps empty and absolute photo values unchanged', () {
      expect(reportPhotoUrl('', 'https://api.example.test'), '');
      expect(
        reportPhotoUrl(
          'https://cdn.example.test/report.jpg',
          'https://api.example.test',
        ),
        'https://cdn.example.test/report.jpg',
      );
    });

    test('uses the backend base URL and filename for relative paths', () {
      expect(
        reportPhotoUrl(
          '/storage/reports/report.jpg',
          'https://api.example.test',
        ),
        'https://api.example.test/foto-laporan/report.jpg',
      );
    });
  });
}
