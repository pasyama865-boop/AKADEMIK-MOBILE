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

  /// Mengambil daftar mahasiswa bimbingan & KRS
  Future<List<dynamic>> getMahasiswaBimbingan() async {
    final data = await authenticatedGet('/dosen/mahasiswa');
    return data['data'] as List<dynamic>;
  }

  /// Menyetujui KRS mahasiswa tertentu
  Future<bool> approveKrsMahasiswa(String mahasiswaId) async {
    final success = await authenticatedPost(
      '/dosen/mahasiswa/$mahasiswaId/approve-krs',
      {},
    );
    return success;
  }

  /// Mengambil daftar mahasiswa dalam suatu jadwal/kelas
  Future<List<dynamic>> getKelasMahasiswa(String jadwalId) async {
    final data = await authenticatedGet('/dosen/kelas/$jadwalId/mahasiswa');
    return data['data'] as List<dynamic>;
  }

  /// Menginput/mengedit nilai mahasiswa dalam KRS
  Future<bool> inputNilai(String krsId, String nilai) async {
    final success = await authenticatedPost('/dosen/krs/$krsId/nilai', {
      'nilai_akhir': nilai,
    });
    return success;
  }
}
