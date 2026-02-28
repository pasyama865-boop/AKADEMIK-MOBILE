import 'base_service.dart';
import '../models/jadwal.dart';
import '../models/krs.dart';

/// Service khusus untuk alur KRS mahasiswa.
/// Menggunakan endpoint /jadwal dan /krs (bukan /admin/...).
class MahasiswaKrsService extends BaseService {
  /// Mengambil daftar semua jadwal yang tersedia untuk diambil.
  Future<List<Jadwal>> getJadwalTersedia() async {
    final data = await authenticatedGet('/jadwal');
    return Jadwal.fromJsonList(data['data']);
  }

  /// Mengambil KRS milik mahasiswa yang sedang login.
  Future<Map<String, dynamic>> getMyKrs() async {
    final data = await authenticatedGet('/krs');
    return {
      'krs': Krs.fromJsonList(data['data']),
      'totalSks': data['total_sks'] ?? 0,
    };
  }

  /// Mahasiswa mengambil jadwal kuliah (POST /krs).
  Future<bool> ambilJadwal(String jadwalId) async {
    return authenticatedPost('/krs', {'jadwal_id': jadwalId});
  }

  /// Mahasiswa membatalkan KRS (DELETE /krs/{id}).
  Future<bool> batalkanKrs(String krsId) async {
    return authenticatedDelete('/krs/$krsId');
  }
}
