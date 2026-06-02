import 'dart:convert';

import 'package:powercare_flutter/core/api/api_endpoints.dart';

import '../../../core/api/api_client.dart';
import '../models/login_response.dart';

class AuthRepository {

  Future<LoginResponse> login(
      Map<String, dynamic> body
      ) async {

    final response = await ApiClient.post(ApiEndpoints.login,body);
print("login response ---->"+response.data.toString());
    return LoginResponse.fromJson(response.data);

  }

}