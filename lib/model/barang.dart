// model/barang.dart
class Barang {
  final String id;
  final String nama;
  final String tipe;
  final int jumlah;
  final double? berat;
  final String? satuan;
  final String? kondisi;
  final double? hargaBeli;
  final double? hargaJual;
  final String? ukuran;
  final String? merek;
  final String? createdByRole;

  Barang({
    required this.id,
    required this.nama,
    required this.tipe,
    required this.jumlah,
    this.berat,
    this.satuan,
    this.kondisi,
    this.hargaBeli,
    this.hargaJual,
    this.ukuran,
    this.merek,
    this.createdByRole,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id_barang'].toString(),
      nama: json['nama_barang'].toString(),
      tipe: json['tipe_barang'].toString(),
      jumlah: int.parse(json['jumlah_barang'].toString()),
      berat: json['berat_barang'] != null
          ? double.tryParse(json['berat_barang'].toString())
          : null,
      satuan: json['satuan']?.toString(),
      kondisi: json['kondisi']?.toString(),
      hargaBeli: json['harga_beli'] != null
          ? double.tryParse(json['harga_beli'].toString())
          : null,
      hargaJual: json['harga_jual'] != null
          ? double.tryParse(json['harga_jual'].toString())
          : null,
      ukuran: json['ukuran_barang']?.toString(),
      merek: json['merek_barang']?.toString(),
      createdByRole: json['created_by_role']?.toString(),
    );
  }
}