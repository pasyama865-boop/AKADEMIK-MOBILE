import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class JadwalService {
  final String baseUrl = 'http://192.168.100.42:8000/api';

  // Ambil semua jadwal yang tersedia
  Future<List<dynamic>> getJadwal() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$baseUrl/admin/jadwal');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['data'];
    } else {
      throw Exception('Gagal memuat jadwal kuliah');
    }
  }

  // 1. TAMBAH JADWAL
  Future<bool> createJadwal(Map<String, dynamic> data) async {
    final auth = AuthService();
    final token = await auth.getToken();
    final url = Uri.parse('$baseUrl/admin/jadwal');
    
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) return true;
    throw Exception(jsonDecode(response.body)['message'] ?? 'Gagal buat jadwal');
  }

  // 2. UPDATE JADWAL
  Future<bool> updateJadwal(String id, Map<String, dynamic> data) async {
    final auth = AuthService();
    final token = await auth.getToken();
    final url = Uri.parse('$baseUrl/admin/jadwal/$id');
    
    final response = await http.put(
      url,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) return true;
    throw Exception(jsonDecode(response.body)['message'] ?? 'Gagal update jadwal');
  }

  // 3. DELETE JADWAL
  Future<bool> deleteJadwal(String id) async {
    final auth = AuthService();
    final token = await auth.getToken();
    final url = Uri.parse('$baseUrl/admin/jadwal/$id');
    
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) return true;
    throw Exception(jsonDecode(response.body)['message'] ?? 'Gagal hapus jadwal');
  }
}
