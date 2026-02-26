import 'base_service.dart';
import '../models/dosen.dart';

class DosenService extends BaseService {
  static const String _endpoint = '/admin/dosen';

  Future<List<Dosen>> getDosenList() async {
    final data = await authenticatedGet(_endpoint);
    return Dosen.fromJsonList(data['data']);
  }

  Future<bool> createDosen(Map<String, dynamic> body) async {
    return authenticatedPost(_endpoint, body);
  }

  Future<bool> updateDosen(String id, Map<String, dynamic> body) async {
    return authenticatedPut('$_endpoint/$id', body);
  }

  Future<bool> deleteDosen(String id) async {
    return authenticatedDelete('$_endpoint/$id');
  }
}
