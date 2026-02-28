class Semester {
  final String id;
  final String namaSemester;
  final String tanggalMulai;
  final String tanggalSelesai;
  final bool isActive;

  Semester({
    required this.id,
    required this.namaSemester,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.isActive,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'].toString(),
      namaSemester: json['nama'] ?? json['nama_semester'] ?? '-',
      tanggalMulai: json['tanggal_mulai'] ?? '-',
      tanggalSelesai: json['tanggal_selesai'] ?? '-',
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'nama_semester': namaSemester,
    'tanggal_mulai': tanggalMulai,
    'tanggal_selesai': tanggalSelesai,
    'is_active': isActive,
  };

  static List<Semester> fromJsonList(List<dynamic> list) {
    return list.map((item) => Semester.fromJson(item)).toList();
  }
}
