import 'base_service.dart';
import '../models/mahasiswa.dart';

class MahasiswaService extends BaseService {
  static const String _endpoint = '/admin/mahasiswa';

  Future<List<Mahasiswa>> getMahasiswaList() async {
    final data = await authenticatedGet(_endpoint);
    return Mahasiswa.fromJsonList(data['data']);
  }

  Future<bool> createMahasiswa(Map<String, dynamic> body) async {
    return authenticatedPost(_endpoint, body);
  }

  Future<bool> updateMahasiswa(String id, Map<String, dynamic> body) async {
    return authenticatedPut('$_endpoint/$id', body);
  }

  Future<bool> deleteMahasiswa(String id) async {
    return authenticatedDelete('$_endpoint/$id');
  }
}
