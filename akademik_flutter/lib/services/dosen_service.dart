import 'dart:convert';
import 'package:akademik_flutter/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DosenService {
  final String baseUrl = 'http://192.168.100.42:8000/api';
  // Fungsi ambil daftar dosen
  Future<List<dynamic>> getDosenList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrl/admin/dosen');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final decodeData = jsonDecode(response.body);
      return decodeData['data'];
    } else {
      throw Exception('Gagal mengambil daftar dosen');
    }
  }

  // Fungsi mengirim data dosen baru
  Future<bool> createDosen(Map<String, dynamic> data) async {
    final auth = AuthService();
    final token = await auth.getToken();

    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrl/admin/dosen');

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
      throw Exception(errorData['message'] ?? 'Gagal menyimpan data dosen');
    }
  }

  Future<bool> deleteDosen(String id) async {
    final auth = AuthService();
    final token = await auth.getToken();

    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrl/admin/dosen/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal menghapus data dosen');
    }
  }

  // Fungsi untuk mengirim data perubahan Dosen
  Future<bool> updateDosen(String id, Map<String, dynamic> data) async {
    final auth = AuthService();
    final token = await auth.getToken();

    if (token == null) throw Exception('Token tidak ditemukan');
    final url = Uri.parse('$baseUrl/admin/dosen/$id');
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
      return true;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal mengubah data dosen');
    }
  }
}
