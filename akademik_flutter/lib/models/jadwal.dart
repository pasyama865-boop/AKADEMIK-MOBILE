class Jadwal {
  final String id;
  final String mataKuliahId;
  final String dosenId;
  final String semesterId;
  final String ruanganId;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final int kuota;
  final int sks;
  final int pesertaCount;

  // Data relasi (flatten)
  final String namaMatkul;
  final String namaDosen;
  final String namaSemester;
  final String namaRuangan;

  Jadwal({
    required this.id,
    required this.mataKuliahId,
    required this.dosenId,
    required this.semesterId,
    required this.ruanganId,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.kuota,
    this.sks = 0,
    this.pesertaCount = 0,
    required this.namaMatkul,
    required this.namaDosen,
    required this.namaSemester,
    required this.namaRuangan,
  });

  String get jamFormatted => '$jamMulai - $jamSelesai';

  bool get isFull => pesertaCount >= kuota;

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      id: json['id'].toString(),
      mataKuliahId: json['mata_kuliah_id']?.toString() ?? '',
      dosenId: json['dosen_id']?.toString() ?? '',
      semesterId: json['semester_id']?.toString() ?? '',
      ruanganId: json['ruangan_id']?.toString() ?? '',
      hari: json['hari'] ?? '-',
      jamMulai: json['jam_mulai'] ?? '',
      jamSelesai: json['jam_selesai'] ?? '',
      kuota: int.tryParse(json['kuota']?.toString() ?? '0') ?? 0,
      sks:
          int.tryParse(json['sks']?.toString() ?? '0') ??
          int.tryParse(json['mata_kuliah']?['sks']?.toString() ?? '0') ??
          0,
      pesertaCount: int.tryParse(json['peserta_count']?.toString() ?? '0') ?? 0,
      namaMatkul: json['mata_kuliah']?['nama_matkul'] ?? 'Mata Kuliah ?',
      namaDosen: json['dosen']?['name'] ?? 'Dosen ?',
      namaSemester: json['semester']?['nama'] ?? 'Semester ?',
      namaRuangan: json['ruangan']?['nama'] ?? 'Ruangan ?',
    );
  }

  static List<Jadwal> fromJsonList(List<dynamic> list) {
    return list.map((item) => Jadwal.fromJson(item)).toList();
  }
}
