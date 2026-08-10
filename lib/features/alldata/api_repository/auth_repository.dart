import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:powercare_flutter/core/api/api_endpoints.dart';

import '../../../core/api/api_client.dart';
import '../models/login_response.dart';

class AuthRepository {
  Future<Map<String, dynamic>> userEdit({
    required String userId,required String firstName,
    required String lastName,
    required String role,
    required String email,
    required String contactNumber,
    File? imageFile,
  }) async {
    // 1. Construct the endpoint with the Query Parameter directly in the string
    // This satisfies the Kotlin @Query("user_id") requirement
    final String endPoint = "/user/edit?user_id=$userId";

    // 2. Prepare the Map for FormData
    final Map<String, dynamic> map = {
      "first_name": firstName,
      "last_name": lastName,
      "role": role,
      "email": email,
      "contact_number": contactNumber,
    };

    // 3. Add the image file if it exists
    if (imageFile != null) {
      map["image"] = await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      );
    }

    // 4. Create the FormData object
    final formData = FormData.fromMap(map);

    // 5. Call the existing postMultipart method without changing it
    final response = await ApiClient.postMultipart(endPoint, formData);

    return response.data;
  }
  Future<LoginResponse> login(
      Map<String, dynamic> body
      ) async {

    final response = await ApiClient.post(ApiEndpoints.login,body);
print("login response ---->"+response.data.toString());
    return LoginResponse.fromJson(response.data);

  }
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await ApiClient.postForm(
      ApiEndpoints.forgotPassword,
      {
        "email": email,
      },
    );
    print("Forgot Password Response => ${response.data}");

    return response.data;
  }
}