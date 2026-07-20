class BaseResponse {
  int? statusCode;
  String? message;

  BaseResponse({
    this.statusCode,
    this.message,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      statusCode: json["status_code"],
      message: json["message"],
    );
  }
}