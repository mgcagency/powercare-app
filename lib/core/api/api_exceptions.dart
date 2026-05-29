import 'package:dio/dio.dart';

/// Base API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status code: $statusCode)';
}

/// Specific Exceptions
class BadRequestException extends ApiException {
  BadRequestException(String message) : super(message, statusCode: 400);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, statusCode: 403);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, statusCode: 404);
}

class InternalServerErrorException extends ApiException {
  InternalServerErrorException(String message)
      : super(message, statusCode: 500);
}

class NoInternetException extends ApiException {
  NoInternetException() : super('No internet connection');
}

/// Convert DioError to ApiException
extension ApiExceptionFromDio on DioError {
  ApiException get toApiException {
    if (type == DioErrorType.connectionTimeout ||
        type == DioErrorType.sendTimeout ||
        type == DioErrorType.receiveTimeout) {
      return ApiException('Request timed out');
    } else if (type == DioErrorType.badResponse) {
      switch (response?.statusCode) {
        case 400:
          return BadRequestException(response?.data['message'] ?? 'Bad Request');
        case 401:
          return UnauthorizedException(response?.data['message'] ?? 'Unauthorized');
        case 403:
          return ForbiddenException(response?.data['message'] ?? 'Forbidden');
        case 404:
          return NotFoundException(response?.data['message'] ?? 'Not Found');
        case 500:
          return InternalServerErrorException(
              response?.data['message'] ?? 'Internal Server Error');
        default:
          return ApiException(
              response?.data['message'] ?? 'Something went wrong',
              statusCode: response?.statusCode);
      }
    } else if (type == DioErrorType.unknown) {
      return NoInternetException();
    } else {
      return ApiException(message ?? 'Something went wrong');
    }
  }
}
