import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/NotificationResponse.dart';

class NotificationRepository {

  Future<NotificationResponse>
  getNotifications(
      int page,
      ) async {

    final response =
    await ApiClient.get(
      ApiEndpoints.notificationList,
      parameters: {
        "page": page,
      },
    );
print("NotificationResponse---->"+response.data.toString());
    return NotificationResponse.fromJson(
      response.data,
    );
  }
  Future<void> markAllAsRead() async {

    await ApiClient.post(
      ApiEndpoints.readNotification,
      {},
    );
  }
}