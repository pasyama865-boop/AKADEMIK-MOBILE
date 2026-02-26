import 'base_service.dart';
import '../models/ruangan.dart';

class RuanganService extends BaseService {
  static const String _endpoint = '/admin/ruangan';

  Future<List<Ruangan>> getRuanganList() async {
    final data = await authenticatedGet(_endpoint);
    return Ruangan.fromJsonList(data['data']);
  }

  Future<bool> createRuangan(Map<String, dynamic> body) async {
    return authenticatedPost(_endpoint, body);
  }

  Future<bool> updateRuangan(String id, Map<String, dynamic> body) async {
    return authenticatedPut('$_endpoint/$id', body);
  }

  Future<bool> deleteRuangan(String id) async {
    return authenticatedDelete('$_endpoint/$id');
  }
}
