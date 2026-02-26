class Ruangan {
  final String id;
  final String nama;
  final String? gedung;
  final int kapasitas;

  Ruangan({
    required this.id,
    required this.nama,
    this.gedung,
    required this.kapasitas,
  });

  factory Ruangan.fromJson(Map<String, dynamic> json) {
    return Ruangan(
      id: json['id'].toString(),
      nama: json['nama'] ?? '-',
      gedung: json['gedung'],
      kapasitas: int.tryParse(json['kapasitas']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'nama': nama,
    'gedung': gedung,
    'kapasitas': kapasitas,
  };

  static List<Ruangan> fromJsonList(List<dynamic> list) {
    return list.map((item) => Ruangan.fromJson(item)).toList();
  }
}
