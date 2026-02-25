import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class MatakuliahService {
  final String baseUrl = 'http://192.168.100.42:8000/api';

  Future<List<dynamic>> getMataKuliahList() async {
    final auth = AuthService();
    final token = await auth.getToken();

    if (token == null) throw Exception('Token tidak ditemukan');
    final url = Uri.parse('$baseUrl/admin/matakuliah');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Typer': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodeData = jsonDecode(response.body);
      return decodeData['data'];
    } else {
      throw Exception('Gagal mengambil data matakuliah');
    }
  }

  //  Tambah matakuliah
  Future<bool> createMataKuliah(Map<String, dynamic> data) async {
    final auth = AuthService();
    final token = await auth.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrl/admin/matakuliah');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) return true;
    throw Exception(jsonDecode(response.body)['message'] ?? 'Gagal menambah matkul');
  }

  //  Update matakuliah
  Future<bool> updateMataKuliah(String id, Map<String, dynamic> data) async {
    final auth = AuthService();
    final token = await auth.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrl/admin/matakuliah/$id');
    final response = await http.put(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) return true;
    throw Exception(jsonDecode(response.body)['message'] ?? 'Gagal mengubah matkul');
  }

  // Hapus matakuliah
  Future<bool> deleteMataKuliah(String id) async {
    final auth = AuthService();
    final token = await auth.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrl/admin/matakuliah/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal menghapus matakuliah');
    }
  }
}
