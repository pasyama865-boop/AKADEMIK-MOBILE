import 'base_service.dart';
import '../models/mata_kuliah.dart';

class MatakuliahService extends BaseService {
  static const String _endpoint = '/admin/matakuliah';

  Future<List<MataKuliah>> getMataKuliahList() async {
    final data = await authenticatedGet(_endpoint);
    return MataKuliah.fromJsonList(data['data']);
  }

  Future<bool> createMataKuliah(Map<String, dynamic> body) async {
    return authenticatedPost(_endpoint, body);
  }

  Future<bool> updateMataKuliah(String id, Map<String, dynamic> body) async {
    return authenticatedPut('$_endpoint/$id', body);
  }

  Future<bool> deleteMataKuliah(String id) async {
    return authenticatedDelete('$_endpoint/$id');
  }
}
