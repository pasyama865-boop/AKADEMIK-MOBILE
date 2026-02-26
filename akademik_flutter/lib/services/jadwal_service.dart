import 'base_service.dart';
import '../models/jadwal.dart';

class JadwalService extends BaseService {
  static const String _endpoint = '/admin/jadwal';

  Future<List<Jadwal>> getJadwal() async {
    final data = await authenticatedGet(_endpoint);
    return Jadwal.fromJsonList(data['data']);
  }

  Future<bool> createJadwal(Map<String, dynamic> body) async {
    return authenticatedPost(_endpoint, body);
  }

  Future<bool> updateJadwal(String id, Map<String, dynamic> body) async {
    return authenticatedPut('$_endpoint/$id', body);
  }

  Future<bool> deleteJadwal(String id) async {
    return authenticatedDelete('$_endpoint/$id');
  }
}
