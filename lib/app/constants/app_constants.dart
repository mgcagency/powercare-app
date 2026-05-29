import '../../flavor_config.dart';

/// App-level constants
class AppConstants {
  // App info
  static String get appName => FlavorConfig.instance.name;
  static const String appVersion = '1.0.0';

  // API & Auth
  static String get baseUrl => FlavorConfig.instance.baseUrl;
  static String get socketBaseUrl => FlavorConfig.instance.socketBaseUrl;
  
  static const String accessTokenKey = 'ACCESS_TOKEN';
  static const String refreshTokenKey = 'REFRESH_TOKEN';
  static const int requestTimeout = 10000; // milliseconds

  // Pagination
  static const int defaultPage = 1;
  static const int defaultPageSize = 20;


  // App settings
  static const int maxRetryAttempts = 3;
  static const Duration socketReconnectDelay = Duration(seconds: 5);



  // Misc
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String defaultAvatarUrl =
      'https://example.com/default_avatar.png';

  // Feature flags
  static const bool enableDebugLogging = true;
  static const bool enableAnalytics = true;
}
