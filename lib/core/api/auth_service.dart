import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {

  static const String baseUrl =
      "https://powercare.resolveddevelopment.co.uk/api/";

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String deviceId,
    required String fcmToken,
  }) async {

    final response = await http.post(
      Uri.parse("${baseUrl}auth/login"),
      body: {
        "email": email,
        "password": password,
        "user_token": fcmToken,
        "device_id": deviceId,
      },
    );

    return jsonDecode(response.body);
  }
}