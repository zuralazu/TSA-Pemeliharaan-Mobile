String reportPhotoUrl(String photo, String baseUrl) {
  if (photo.isEmpty) return '';
  if (photo.startsWith('http')) return photo;
  final filename = photo.split('/').last;
  return '$baseUrl/foto-laporan/$filename';
}
