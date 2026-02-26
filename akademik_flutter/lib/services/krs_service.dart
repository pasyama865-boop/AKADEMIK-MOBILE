import 'base_service.dart';
import '../models/krs.dart';

class KrsService extends BaseService {
  static const String _endpoint = '/admin/krs';

  Future<List<Krs>> getKrsList() async {
    final data = await authenticatedGet(_endpoint);
    return Krs.fromJsonList(data['data']);
  }

  Future<bool> createKrs(String mahasiswaId, String jadwalId) async {
    return authenticatedPost(_endpoint, {
      'mahasiswa_id': mahasiswaId,
      'jadwal_id': jadwalId,
    });
  }

  Future<bool> updateKrs(String id, String mahasiswaId, String jadwalId) async {
    return authenticatedPut('$_endpoint/$id', {
      'mahasiswa_id': mahasiswaId,
      'jadwal_id': jadwalId,
    });
  }

  Future<bool> deleteKrs(String krsId) async {
    return authenticatedDelete('$_endpoint/$krsId');
  }
}
