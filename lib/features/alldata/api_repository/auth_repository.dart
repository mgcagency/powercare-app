import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRepository {

  Future<Map<String, dynamic>> login(
      String email,
      String password,
      ) async {

    final response = await http.post(
      Uri.parse(
        'YOUR_LOGIN_API_URL',
      ),
      headers: {
        'Content-Type':
        'application/json',
      },
      body: jsonEncode({
        "email": email,
        "password": password,
        "user_token": "",
        "device_id": "",
      }),
    );

    return jsonDecode(
      response.body,
    );
  }
}