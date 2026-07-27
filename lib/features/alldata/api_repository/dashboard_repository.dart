import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class DashboardRepository {
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await ApiClient.get(
      ApiEndpoints.dashboard,
    );

    return response.data;
  }
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String role,
    required String email,
    required String contactNumber,
    File? image,
  }) async {

    final formData = FormData.fromMap({
      "first_name": firstName,
      "last_name": lastName,
      "role": role,
      "email": email,
      "contact_number": contactNumber,
      if (image != null)
        "image": await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
    });

    final response = await ApiClient.postMultipart(
      "${ApiEndpoints.userEdit}?user_id=$userId",
      formData,
    );

    return response.data;
  }
}