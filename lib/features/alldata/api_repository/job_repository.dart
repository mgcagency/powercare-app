import 'dart:convert';

import 'package:powercare_flutter/core/api/api_endpoints.dart';

import '../../../core/api/api_client.dart';
import '../models/job_list_response.dart';
import '../models/login_response.dart';

class JobRepository {

  Future<JobListResponse> getJobs(
      Map<String, dynamic> parameters
      ) async {

    final response = await ApiClient.get(ApiEndpoints.jobList,parameters:parameters);
print("getJobs response ---->"+response.data.toString());
    return JobListResponse.fromJson(response.data);

  }

}