class Dosen {
  final String id;
  final String userId;
  final String nip;
  final String? gelar;
  final String? noHp;
  final String namaLengkap;
  final String email;

  Dosen({
    required this.id,
    required this.userId,
    required this.nip,
    this.gelar,
    this.noHp,
    required this.namaLengkap,
    required this.email,
  });

  factory Dosen.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return Dosen(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      nip: json['nip'] ?? '-',
      gelar: json['gelar'],
      noHp: json['no_hp'],
      namaLengkap: user?['name'] ?? 'Dosen',
      email: user?['email'] ?? '-',
    );
  }

  static List<Dosen> fromJsonList(List<dynamic> list) {
    return list.map((item) => Dosen.fromJson(item)).toList();
  }
}
