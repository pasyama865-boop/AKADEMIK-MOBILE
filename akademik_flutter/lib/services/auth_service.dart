import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://192.168.100.42:8000/api';

  // Fungsi Login
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Simpan token ke shared preferences
        await saveToken(data['access_token']);
        // Simpan role dan nama
        String role = data['user']['role'];
        String name = data['user']['name'];
        // Buka memori hape dan simpan role serta nama
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', role);
        await prefs.setString('name', name);
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login Gagal');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  // Fungsi Simpan token baru
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Fungsi ambil token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Fungsi logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Panggil API logout ke laravel jika ada
    final token = prefs.getString('auth_token');
    if (token != null) {
      final url = Uri.parse('$baseUrl/logout');
      try {
        await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      } catch (e) {
        throw Exception();
      }
    }
    await prefs.remove('auth_token');
  }

  // Fungsi Ambil data profil user
  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak di temukan, Silahkan login ulang');

    final url = Uri.parse('$baseUrl/me');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil data profil');
    }
  }

  // Fungsi ambil statistik admin
  Future<Map<String, dynamic>> getAdminStats() async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrl/admin/stats');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accep': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil statistik admin');
    }
  }

  

  // Fungsi ambil daftar jadwal mata kuliah
  Future<List<dynamic>> getJadwalList() async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrl/admin/jadwal');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final decodeData = jsonDecode(response.body);
      return decodeData['data'];
    } else {
      throw Exception('Gagal mengambil daftar jadwal mata kuliah');
    }
  }
}
