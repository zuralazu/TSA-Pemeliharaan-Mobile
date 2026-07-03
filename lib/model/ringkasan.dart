class RingkasanJenis {
  final int total;
  final int baik;
  final int perluCek;

  RingkasanJenis({
    required this.total,
    required this.baik,
    required this.perluCek,
  });

  factory RingkasanJenis.fromJson(Map<String, dynamic> json) {
    return RingkasanJenis(
      total: json['total'] ?? 0,
      baik: json['baik'] ?? 0,
      perluCek: json['perlu_cek'] ?? 0,
    );
  }
}

class RingkasanDashboard {
  final int total;
  final int baik;
  final int perluCek;
  final RingkasanJenis? apar;
  final RingkasanJenis? hydrant;

  RingkasanDashboard({
    required this.total,
    required this.baik,
    required this.perluCek,
    this.apar,
    this.hydrant,
  });

  factory RingkasanDashboard.fromJson(Map<String, dynamic> json) {
    return RingkasanDashboard(
      total: json['total'] ?? 0,
      baik: json['baik'] ?? 0,
      perluCek: json['perlu_cek'] ?? 0,
      apar: json['apar'] != null ? RingkasanJenis.fromJson(json['apar']) : null,
      hydrant: json['hydrant'] != null ? RingkasanJenis.fromJson(json['hydrant']) : null,
    );
  }
}
