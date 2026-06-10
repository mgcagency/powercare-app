import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class LeaveRepository {

  Future<dynamic> createLeave(
      Map<String, dynamic> payload,
      ) async {

    final response =
    await ApiClient.post(
      ApiEndpoints.leaveCreate,
      payload,
    );

    return response.data;
  }
}