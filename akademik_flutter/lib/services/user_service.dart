import 'base_service.dart';
import '../models/user_admin.dart';

class UserService extends BaseService {
  static const String _endpoint = '/admin/users';

  Future<List<UserAdmin>> getUserList() async {
    final data = await authenticatedGet(_endpoint);
    return UserAdmin.fromJsonList(data['data']);
  }

  Future<bool> createUser(Map<String, dynamic> body) async {
    return authenticatedPost(_endpoint, body);
  }

  Future<bool> updateUser(String id, Map<String, dynamic> body) async {
    return authenticatedPut('$_endpoint/$id', body);
  }

  Future<bool> deleteUser(String id) async {
    return authenticatedDelete('$_endpoint/$id');
  }
}
