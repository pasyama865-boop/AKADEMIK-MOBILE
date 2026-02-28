import 'base_service.dart';

/// Service untuk mengambil data dashboard dosen.
class DosenDashboardService extends BaseService {
  /// Mengambil statistik dashboard dosen (total kelas, mahasiswa, SKS).
  Future<Map<String, dynamic>> getMyStats() async {
    final data = await authenticatedGet('/dosen/stats');
    return data as Map<String, dynamic>;
  }

  /// Mengambil jadwal kelas yang diajar oleh dosen.
  Future<List<dynamic>> getMyJadwal() async {
    final data = await authenticatedGet('/dosen/jadwal');
    return data['data'] as List<dynamic>;
  }
}
