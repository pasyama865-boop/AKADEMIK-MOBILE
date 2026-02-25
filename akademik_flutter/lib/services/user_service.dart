import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserService {
  final String baseUrl = 'http://192.168.100.42:8000/api';

  Future<List<dynamic>> getUserList() async {
    final auth = AuthService();
    final token = await auth.getToken();

    if (token == null) throw Exception('Token tidak ditemukan');
    final url = Uri.parse('$baseUrl/admin/users');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodeData = jsonDecode(response.body);
      return decodeData['data'];
    } else {
      throw Exception('Gagal mengambil data user');
    }
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    final auth = AuthService();
    final token = await auth.getToken();

    if (token == null) throw Exception('Token tidak ditemukan');
    final url = Uri.parse('$baseUrl/admin/users');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal menambah user');
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    final auth = AuthService();
    final token = await auth.getToken();

    if (token == null) throw Exception('Token tidak ditemukan');
    final url = Uri.parse('$baseUrl/admin/users/$id');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal update user');
    }
  }

  Future<void> deleteUser(String id) async {
    final auth = AuthService();
    final token = await auth.getToken();

    if (token == null) throw Exception('Token tidak ditemukan');
    final url = Uri.parse('$baseUrl/admin/users/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal menghapus user');
    }

  }
}
