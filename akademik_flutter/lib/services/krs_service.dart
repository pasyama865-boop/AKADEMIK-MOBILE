import 'dart:convert';
import 'package:akademik_flutter/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class KrsService {
  final String baseUrl = 'http://192.168.100.42:8000/api';

  Future<List<dynamic>> getKrsList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrl/admin/krs');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['data'];
    } else {
      throw Exception('Gagal mengambil data krs');
    }
  }

  // Buat KRS
  Future<bool> createKrs(String mahasiswaId, String jadwalId) async {
    final auth = AuthService();
    final token = await auth.getToken();
    
    final response = await http.post(
      Uri.parse('$baseUrl/admin/krs'),
      headers: {
        'Authorization': 'Bearer $token', 
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'mahasiswa_id': mahasiswaId,
        'jadwal_id': jadwalId,
      }),
    );

    if (response.statusCode == 201) return true;
    
    final errorData = jsonDecode(response.body);
    final detail = errorData['detail'] != null ? "\n${errorData['detail']}" : "";
    throw Exception("${errorData['message']}$detail");
  }

  // Update KRS
  Future<bool> updateKrs(String id, String mahasiswaId, String jadwalId) async {
    final auth = AuthService();
    final token = await auth.getToken();
    
    final response = await http.put(
      Uri.parse('$baseUrl/admin/krs/$id'),
      headers: {
        'Authorization': 'Bearer $token', 
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'mahasiswa_id': mahasiswaId,
        'jadwal_id': jadwalId,
      }),
    );

    if (response.statusCode == 200) return true;
    
    final errorData = jsonDecode(response.body);
    final detail = errorData['detail'] != null ? "\n${errorData['detail']}" : "";
    throw Exception("${errorData['message']}$detail");
  }


  // Hapus KRS
  Future<bool> deleteKrs(String krsId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url = Uri.parse('$baseUrl/admin/krs/$krsId');
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
      throw Exception('Gagal menghapus mata kuliah');
    }
  }
}
