class MataKuliah {
  final String id;
  final String kodeMatkul;
  final String namaMatkul;
  final int sks;
  final int semesterPaket;

  MataKuliah({
    required this.id,
    required this.kodeMatkul,
    required this.namaMatkul,
    required this.sks,
    required this.semesterPaket,
  });

  factory MataKuliah.fromJson(Map<String, dynamic> json) {
    return MataKuliah(
      id: json['id'].toString(),
      kodeMatkul: json['kode_matkul'] ?? '-',
      namaMatkul: json['nama_matkul'] ?? 'Tidak diketahui',
      sks: int.tryParse(json['sks']?.toString() ?? '0') ?? 0,
      semesterPaket:
          int.tryParse(json['semester_paket']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'kode_matkul': kodeMatkul,
    'nama_matkul': namaMatkul,
    'sks': sks,
    'semester_paket': semesterPaket,
  };

  static List<MataKuliah> fromJsonList(List<dynamic> list) {
    return list.map((item) => MataKuliah.fromJson(item)).toList();
  }
}
