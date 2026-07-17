import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class DashboardRepository {
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await ApiClient.get(
      ApiEndpoints.dashboard,
    );
print("response.data---->"+response.data.toString());
    return response.data;
  }
}