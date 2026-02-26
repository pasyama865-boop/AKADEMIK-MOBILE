class Krs {
  final String id;
  final String mahasiswaId;
  final String jadwalId;
  final String status;
  final String? nilaiAkhir;

  // Data relasi (flatten)
  final String namaMahasiswa;
  final String nimMahasiswa;
  final String namaMatkul;
  final String namaDosen;
  final String namaRuangan;
  final String hari;
  final String jamMulai;
  final String jamSelesai;

  Krs({
    required this.id,
    required this.mahasiswaId,
    required this.jadwalId,
    required this.status,
    this.nilaiAkhir,
    required this.namaMahasiswa,
    required this.nimMahasiswa,
    required this.namaMatkul,
    required this.namaDosen,
    required this.namaRuangan,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
  });

  String get jamFormatted => '$jamMulai - $jamSelesai';

  factory Krs.fromJson(Map<String, dynamic> json) {
    final mahasiswa = json['mahasiswa'] as Map<String, dynamic>?;
    final jadwal = json['jadwal'] as Map<String, dynamic>?;

    return Krs(
      id: json['id'].toString(),
      mahasiswaId: json['mahasiswa_id']?.toString() ?? '',
      jadwalId: json['jadwal_id']?.toString() ?? '',
      status: json['status'] ?? '-',
      nilaiAkhir: json['nilai_akhir']?.toString(),
      namaMahasiswa: mahasiswa?['user']?['name'] ?? 'Mahasiswa ?',
      nimMahasiswa: mahasiswa?['nim'] ?? '-',
      namaMatkul: jadwal?['mata_kuliah']?['nama_matkul'] ?? 'Mata Kuliah ?',
      namaDosen: jadwal?['dosen']?['name'] ?? 'Dosen ?',
      namaRuangan: jadwal?['ruangan']?['nama'] ?? 'Ruangan ?',
      hari: jadwal?['hari'] ?? '-',
      jamMulai: jadwal?['jam_mulai'] ?? '',
      jamSelesai: jadwal?['jam_selesai'] ?? '',
    );
  }

  static List<Krs> fromJsonList(List<dynamic> list) {
    return list.map((item) => Krs.fromJson(item)).toList();
  }
}
