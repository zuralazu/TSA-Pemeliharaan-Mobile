class InventoryItem {
  final String nomorIdentifikasi;
  final String idBarang;
  final String namaBarang;
  final String tipeKategori;
  final String? kondisi;
  final String? lokasi;
  final String? status;

  InventoryItem({
    required this.nomorIdentifikasi,
    required this.idBarang,
    required this.namaBarang,
    required this.tipeKategori,
    this.kondisi,
    this.lokasi,
    this.status,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      nomorIdentifikasi: json['nomor_identifikasi'],
      idBarang: json['id_barang'].toString(),
      namaBarang: json['nama_barang'],
      tipeKategori: json['tipe_barang_kategori'],
      kondisi: json['kondisi'],
      lokasi: json['lokasi'],
      status: json['status'],
    );
  }
}
