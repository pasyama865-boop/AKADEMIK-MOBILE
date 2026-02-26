class UserAdmin {
  final String id;
  final String name;
  final String email;
  final String role;

  UserAdmin({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserAdmin.fromJson(Map<String, dynamic> json) {
    return UserAdmin(
      id: json['id'].toString(),
      name: json['name'] ?? '-',
      email: json['email'] ?? '-',
      role: json['role'] ?? 'admin',
    );
  }

  static List<UserAdmin> fromJsonList(List<dynamic> list) {
    return list.map((item) => UserAdmin.fromJson(item)).toList();
  }
}
