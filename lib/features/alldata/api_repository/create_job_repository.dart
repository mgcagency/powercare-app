import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class CreateJobRepository {

  Future<Response> getJobNumber() async {
    return await ApiClient.get(
      ApiEndpoints.jobNumber,
    );
  }

  Future<Response> getUsers() async {
    return await ApiClient.get(
      ApiEndpoints.userList,
      parameters: {
        "paginate": 1,
      },
    );
  }

  Future<Response> getJobStatus() async {
    return await ApiClient.get(
      ApiEndpoints.jobTypeStatusList,
      parameters: {
        "paginate": 1,
      },
    );
  }

  Future<Response> createJob(
      Map<String, dynamic> body) async {

    return await ApiClient.post(
      ApiEndpoints.createJob,
      body,
    );
  }
}