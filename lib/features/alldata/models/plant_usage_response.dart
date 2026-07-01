class PlantUsageResponse {
  final bool? success;
  final String? message;
  final int? statusCode;
  final dynamic data;

  PlantUsageResponse({
    this.success,
    this.message,
    this.statusCode,
    this.data,
  });

  factory PlantUsageResponse.fromJson(Map<String, dynamic> json) {
    return PlantUsageResponse(
      success: json["success"],
      message: json["message"],
      statusCode: json["status_code"],
      data: json["data"],
    );
  }
}