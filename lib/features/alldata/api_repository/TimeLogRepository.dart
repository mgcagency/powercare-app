import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/TimeLogResponse.dart';

class TimeLogRepository {

  Future<TimeLogResponse> getTimeLogs({
    required String date,
    required String engineerId,
    required String dateKey,
    required String specificDate,
  }) async {

    final response =
    await ApiClient.get(
      ApiEndpoints.timeLogList,
      parameters: {
        "date": date,
        "engineer_id": engineerId,
        "date_key": dateKey,
        "specific_date": specificDate,
      },
    );
    print("TIME LOG API => ${response.data}");

    return TimeLogResponse.fromJson(
      response.data,
    );
  }
}