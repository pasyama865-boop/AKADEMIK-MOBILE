class Mahasiswa {
  final String id;
  final String userId;
  final String nim;
  final String jurusan;
  final int angkatan;
  final String namaUser;
  final String emailUser;

  Mahasiswa({
    required this.id,
    required this.userId,
    required this.nim,
    required this.jurusan,
    required this.angkatan,
    required this.namaUser,
    required this.emailUser,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return Mahasiswa(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      nim: json['nim'] ?? '-',
      jurusan: json['jurusan'] ?? '-',
      angkatan: int.tryParse(json['angkatan']?.toString() ?? '0') ?? 0,
      namaUser: user?['name'] ?? 'Mahasiswa',
      emailUser: user?['email'] ?? '-',
    );
  }

  static List<Mahasiswa> fromJsonList(List<dynamic> list) {
    return list.map((item) => Mahasiswa.fromJson(item)).toList();
  }
}
