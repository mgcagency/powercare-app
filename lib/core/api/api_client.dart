import 'package:dio/dio.dart';


import '../../app/constants/app_constants.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  static final _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(minutes: 1),
      receiveTimeout: const Duration(minutes: 1),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<Response> get(String path, {
    Map<String, dynamic>? parameters,
  }) async {
    String? token = await SecureStorage.getToken();
    try {
      print("get method url--->" + AppConstants.baseUrl+path);
      print("get method parameters--->$parameters");

      return await _dio.get(
        path,
        queryParameters: parameters,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
    } on DioError catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  static Future<Response> post(String endPoint, Map<String, dynamic> body) async {
    String? token = await SecureStorage.getToken();
    try {
      print('✅ API URL: $endPoint');
      print('📤 REQUEST BODY: $body');

      var request = await _dio.post(
        endPoint,
        data: body,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      print('📥 RESPONSE BODY: ${request.data}');
      return request;
    } on DioError catch (e) {
      print("❌ POST ERROR STATUS => ${e.response?.statusCode}");
      print("❌ POST ERROR DATA => ${e.response?.data}");
      throw ApiException.fromDioError(e);
    }
  }

  static Future<Response> postMultipart(String endPoint, FormData formData) async {
    String? token = await SecureStorage.getToken();
    try {
      print('✅ API URL (MULTIPART): $endPoint');
      var request = await _dio.post(
        endPoint,
        data: formData,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      print('📥 RESPONSE BODY: ${request.data}');
      return request;
    } on DioError catch (e) {
      print("❌ MULTIPART ERROR => ${e.message}");
      throw ApiException.fromDioError(e);
    }
  }

  static Future<Response> delete(String endPoint, {Map<String, dynamic>? body}) async {
    String? token = await SecureStorage.getToken();
    try {
      print('🗑️ API URL (DELETE): ${AppConstants.baseUrl}$endPoint');
      var response = await _dio.delete(
        endPoint,
        data: body,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      print('📥 DELETE RESPONSE: ${response.data}');
      return response;
    } on DioError catch (e) {
      print("❌ DELETE ERROR => ${e.message}");
      throw ApiException.fromDioError(e);
    }
  }

  static Future<Response> put(String endPoint, {Map<String, dynamic>? body}) async {
    String? token = await SecureStorage.getToken();
    try {
      var request = await _dio.put(
        endPoint,
        data: body,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      print('✅ API URL: ${request.realUri}');
      print('📥 RESPONSE BODY: ${request.data}');
      return request;
    } on DioError catch (e) {
      print("❌ PUT ERROR => ${e.message}");
      throw ApiException.fromDioError(e);
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  factory ApiException.fromDioError(DioError error) {
    String message = error.message ?? "An unknown error occurred";
    
    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map && data.containsKey('message')) {
        message = data['message'].toString();
      } else if (data is String && data.isNotEmpty) {
        message = data;
      }
    }
    
    return ApiException(message);
  }

  @override
  String toString() => message;
}
