import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

/// Base service yang menyediakan method HTTP terpusat.
///
/// Semua service CRUD (Dosen, Mahasiswa, KRS, dll.)
/// harus meng-extend class ini agar tidak duplikasi kode
/// untuk autentikasi, header, dan error handling.
abstract class BaseService {
  /// URL dasar API dari config terpusat.
  final String baseUrl = ApiConfig.baseUrl;

  /// Singleton AuthService untuk mengambil token autentikasi.
  final AuthService _authService = AuthService();

  /// Membangun header standar dengan token autentikasi.
  Map<String, String> _buildHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Mengambil token yang valid dari AuthService.
  /// Throw exception jika token tidak ditemukan.
  Future<String> _getValidToken() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token tidak ditemukan');
    return token;
  }

  // ============================================================
  // HTTP METHODS
  // ============================================================

  /// GET request dengan autentikasi.
  /// Return body yang sudah di-decode sebagai dynamic.
  Future<dynamic> authenticatedGet(String endpoint) async {
    final token = await _getValidToken();
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http
          .get(url, headers: _buildHeaders(token))
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      _handleError(response);
    } on SocketException {
      throw Exception(
        'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
      );
    } on TimeoutException {
      throw Exception('Koneksi terputus (Timeout). Server sangat lambat.');
    }
  }

  /// POST request dengan autentikasi.
  /// Return `true` jika statusCode 201 (Created) atau 200 (OK).
  Future<bool> authenticatedPost(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await _getValidToken();
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http
          .post(url, headers: _buildHeaders(token), body: jsonEncode(body))
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 201 || response.statusCode == 200) return true;

      _handleError(response);
    } on SocketException {
      throw Exception(
        'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
      );
    } on TimeoutException {
      throw Exception('Koneksi terputus (Timeout). Server sangat lambat.');
    }
  }

  /// PUT request dengan autentikasi.
  /// Return `true` jika statusCode 200 (OK).
  Future<bool> authenticatedPut(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await _getValidToken();
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http
          .put(url, headers: _buildHeaders(token), body: jsonEncode(body))
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) return true;

      _handleError(response);
    } on SocketException {
      throw Exception(
        'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
      );
    } on TimeoutException {
      throw Exception('Koneksi terputus (Timeout). Server sangat lambat.');
    }
  }

  /// DELETE request dengan autentikasi.
  /// Return `true` jika statusCode 200 (OK).
  Future<bool> authenticatedDelete(String endpoint) async {
    final token = await _getValidToken();
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http
          .delete(url, headers: _buildHeaders(token))
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) return true;

      _handleError(response);
    } on SocketException {
      throw Exception(
        'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
      );
    } on TimeoutException {
      throw Exception('Koneksi terputus (Timeout). Server sangat lambat.');
    }
  }

  // ERROR HANDLING

  /// Handle error response dari server secara terpusat.
  /// Mencoba extract pesan error dan detail dari response body.
  Never _handleError(http.Response response) {
    try {
      final errorData = jsonDecode(response.body);
      final message = errorData['message'] ?? 'Terjadi kesalahan';
      final detail = errorData['detail'];
      final fullMessage = detail != null ? '$message\n$detail' : message;
      throw Exception(fullMessage);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal memproses request (${response.statusCode})');
    }
  }
}
