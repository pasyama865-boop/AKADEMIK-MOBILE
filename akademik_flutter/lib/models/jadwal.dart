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
    required this.namaMatkul,
    required this.namaDosen,
    required this.namaSemester,
    required this.namaRuangan,
  });

  String get jamFormatted => '$jamMulai - $jamSelesai';

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
