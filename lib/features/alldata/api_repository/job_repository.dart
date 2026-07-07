import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:powercare_flutter/core/api/api_endpoints.dart';

import '../../../core/api/api_client.dart';
import '../models/job_details_response.dart';
import '../models/job_list_response.dart';
import '../models/job_type_status_response.dart';
import '../models/login_response.dart';

class JobRepository {
  Future<JobListResponse> getJobs(Map<String, dynamic> parameters) async {
    final response = await ApiClient.get(
      ApiEndpoints.jobList,
      parameters: parameters,
    );
    print("getJobs response ---->" + response.data.toString());
    return JobListResponse.fromJson(response.data);
  }

  Future<JobDetailsResponse> getJobDetails(String jobId) async {
    final response = await ApiClient.get(
      ApiEndpoints.jobDetails,
      parameters: {"job_id": jobId},
    );
    print("getJobDetails response ---->" + response.data.toString());
    return JobDetailsResponse.fromJson(response.data);
  }

  Future<JobTypeStatusResponse> getJobTypeStatusList({Map<String, dynamic>? parameters}) async {
    final response = await ApiClient.get(
      ApiEndpoints.jobTypeStatusList+"?paginate=1",
      // parameters: parameters,
    );
    print("getJobTypeStatusList response ---->" + response.data.toString());
    return JobTypeStatusResponse.fromJson(response.data);
  }

  Future<Response> uploadJobImage(String jobId, String imagePath) async {
    FormData formData = FormData.fromMap({
      "job_id": jobId,
      "multi_image": await MultipartFile.fromFile(
        imagePath,
        filename: imagePath.split('/').last,
      ),
    });

    return await ApiClient.postMultipart(ApiEndpoints.jobImageUpload, formData);
  }
  Future<Response> deleteJobImage(int imageId) async {
    // Assuming the API uses GET or DELETE as per your description
    return await ApiClient.delete("${ApiEndpoints.jobImageDelete}$imageId");
  }
  Future<JobListResponse> getArchivedJobs(
      Map<String,dynamic> parameters,
      ) async {

    final response = await ApiClient.get(
      ApiEndpoints.archiveJobList,
      parameters: parameters,
    );

    return JobListResponse.fromJson(response.data);
  }
  Future<dynamic> changeEngineerStatus({
    required String jobId,
    required String userId,
    required String status,
  }) async {

    final response = await ApiClient.post(

      "${ApiEndpoints.changeEngineerStatus}"
          "?job_id=$jobId"
          "&user_id=$userId"
          "&status=$status",

      {},

    );
    print("Engineer Status Response => ${response.data}");

    return response.data;
  }
  Future<Map<String, dynamic>> saveJobSheet(
      Map<String, dynamic> body,
      ) async {
    final response = await ApiClient.post(
      "/job-sheet",
      body,
    );

    return response.data;
  }
}
