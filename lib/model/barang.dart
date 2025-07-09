// model/barang.dart
class Barang {
  final int id;
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
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id_barang'],
      nama: json['nama_barang'],
      tipe: json['tipe_barang'],
      jumlah: json['jumlah_barang'],
      berat: double.tryParse(json['berat_barang'].toString()),
      satuan: json['satuan'],
      kondisi: json['kondisi'],
      hargaBeli: double.tryParse(json['harga_beli'].toString()),
      hargaJual: double.tryParse(json['harga_jual'].toString()),
      ukuran: json['ukuran_barang'],
      merek: json['merek_barang'],
    );
  }
}