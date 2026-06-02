class LoginResponse {
  String? token;
  String? message;
  int? statusCode;
  LoginUser? data;

  LoginResponse({this.token, this.message, this.statusCode, this.data});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    token = json["token"];
    message = json["message"];
    statusCode = json["status_code"];
    data = json["data"] != null ? LoginUser.fromJson(json["data"]) : null;
  }
}

class LoginUser {
  int? id;
  String? firstName;
  String? lastName;
  String? role;
  String? email;
  String? emailVerifiedAt;
  String? contactNumber;
  String? accessToken;
  String? userToken;
  String? deviceId;
  int? secretCode;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? userImage;

  LoginUser({
    this.id,
    this.firstName,
    this.lastName,
    this.role,
    this.email,
    this.emailVerifiedAt,
    this.contactNumber,
    this.accessToken,
    this.userToken,
    this.deviceId,
    this.secretCode,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.userImage,
  });

  LoginUser.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    firstName = json["first_name"];
    lastName = json["last_name"];
    role = json["role"];
    email = json["email"];
    emailVerifiedAt = json["email_verified_at"];
    contactNumber = json["contact_number"];
    accessToken = json["access_token"];
    userToken = json["user_token"];
    deviceId = json["device_id"];
    secretCode = json["secret_code"];
    status = json["status"];
    createdAt = json["created_at"];
    updatedAt = json["updated_at"];
    userImage = json["user_image"];
  }
}