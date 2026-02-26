import 'base_service.dart';
import '../models/semester.dart';

class SemesterService extends BaseService {
  static const String _endpoint = '/admin/semester';

  Future<List<Semester>> getSemesterList() async {
    final data = await authenticatedGet(_endpoint);
    return Semester.fromJsonList(data['data']);
  }

  Future<bool> createSemester(Map<String, dynamic> body) async {
    return authenticatedPost(_endpoint, body);
  }

  Future<bool> updateSemester(String id, Map<String, dynamic> body) async {
    return authenticatedPut('$_endpoint/$id', body);
  }

  Future<bool> deleteSemester(String id) async {
    return authenticatedDelete('$_endpoint/$id');
  }
}
