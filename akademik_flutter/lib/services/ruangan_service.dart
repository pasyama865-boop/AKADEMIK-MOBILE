import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class RuanganService {
  final String baseUrl = 'http://192.168.100.42:8000/api';

  Future<List<dynamic>> getRuanganList() async {
    final auth = AuthService();
    final token = await auth.getToken();

    if (token == null) throw Exception('Token tidak ditemukan');
    final url = Uri.parse('$baseUrl/admin/ruangan');
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
      throw Exception('Gagal mengambil data ruangan');
    }
  }

  Future<bool> createRuangan(Map<String, dynamic> data) async {
    final auth = AuthService();
    final token = await auth.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrl/admin/ruangan');
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
      return true;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal menambah mahasiswa');
    }
  }

  Future<void> updateRuangan(String id, Map<String, dynamic> data) async {
    final auth = AuthService();
    final token = await auth.getToken();

    if (token == null) throw Exception('Token tidak ditemukan');
    final url = Uri.parse('$baseUrl/admin/ruangan/$id');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) return;
    throw Exception(jsonDecode(response.body)['message'] ??'Gagal update ruangan');
  }

  Future<void> deleteRuangan(String id) async {
    final auth = AuthService();
    final token = await auth.getToken();

    if (token == null) throw Exception('Token tidak ditemukan');
    final url = Uri.parse('$baseUrl/admin/ruangan/$id');
    final response = await http.delete(
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
      throw Exception('Gagal menghapus ruangan');
    }
  }
}
