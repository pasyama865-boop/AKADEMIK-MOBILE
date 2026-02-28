import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  /// Factory constructor mengembalikan instance yang sama.
  factory AuthService() => _instance;
  AuthService._internal();

  /// Cache SharedPreferences agar tidak dipanggil getInstance() berkali-kali.
  SharedPreferences? _prefs;

  /// URL dasar API dari config terpusat.
  final String baseUrl = ApiConfig.baseUrl;

  /// Mengambil SharedPreferences dengan caching
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // AUTENTIKASI
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

        // Simpan token autentikasi
        await simpanToken(data['access_token']);

        // Simpan role dan nama user ke penyimpanan lokal
        final p = await prefs;
        await p.setString('role', data['user']['role']);
        await p.setString('name', data['user']['name']);

        // Simpan mahasiswa_id jika role mahasiswa
        if (data['user']['mahasiswa'] != null) {
          await p.setString(
            'mahasiswa_id',
            data['user']['mahasiswa']['id'].toString(),
          );
        }

        return true;
      }

      // Login gagal - lempar exception dengan pesan dari server
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Login Gagal');
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  /// Mengambil mahasiswa_id dari penyimpanan lokal.
  Future<String?> getMahasiswaId() async {
    final p = await prefs;
    return p.getString('mahasiswa_id');
  }

  /// Melakukan proses logout.
  /// Menghapus token dari server (API) dan dari penyimpanan lokal.
  Future<void> logout() async {
    final p = await prefs;
    final token = p.getString('auth_token');

    // Panggil API logout di backend jika token tersedia
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
        // Abaikan error saat logout ke server,
      }
    }

    // Hapus token dari penyimpanan lokal
    await p.remove('auth_token');
  }

  // MANAJEMEN TOKEN

  /// Menyimpan token autentikasi ke penyimpanan lokal.
  Future<void> simpanToken(String token) async {
    final p = await prefs;
    await p.setString('auth_token', token);
  }

  /// Mengambil token autentikasi dari penyimpanan lokal.
  Future<String?> getToken() async {
    final p = await prefs;
    return p.getString('auth_token');
  }

  // DATA PROFIL & STATISTIK

  /// Mengambil data profil user yang sedang login.
  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan, silahkan login ulang');
    }

    final url = Uri.parse('$baseUrl/me');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Gagal mengambil data profil');
  }

  /// Mengambil data statistik untuk dashboard admin.
  Future<Map<String, dynamic>> getAdminStats() async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrl/admin/stats');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Gagal mengambil statistik admin');
  }

  /// Mengambil daftar jadwal mata kuliah.
  Future<List<dynamic>> getJadwalList() async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan');

    final url = Uri.parse('$baseUrl/admin/jadwal');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final dataResponse = jsonDecode(response.body);
      return dataResponse['data'];
    }

    throw Exception('Gagal mengambil daftar jadwal mata kuliah');
  }
}
