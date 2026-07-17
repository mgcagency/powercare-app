import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/UserModel.dart';

class TimeSheetRepository {

  Future<dynamic> addTimeSheet(
      Map<String,dynamic> payload,
      ) async {

    final response =
    await ApiClient.postForm(
      ApiEndpoints.timeSheetCreate,
      payload,
    );
print("addTimeSheet---->"+response.data.toString());
    return response.data;
  }

  Future<List<UserModel>> getUsers() async {

    final response =
    await ApiClient.get(
      ApiEndpoints.userList,
      parameters: {
        "paginate": 1,
      },
    );

    print(
      "USER LIST RESPONSE => ${response.data}",
    );

    final List list =
        response.data["user"] ?? [];

    return list
        .map(
          (e) => UserModel.fromJson(e),
    )
        .toList();
  }
}