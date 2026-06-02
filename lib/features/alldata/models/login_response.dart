class LoginResponse {

  String? token;
  String? message;
  int? statusCode;
  LoginUser? data;

  LoginResponse.fromJson(Map<String,dynamic> json){

    token = json["token"];
    message = json["message"];
    statusCode = json["status_code"];

    data = json["data"] != null
        ? LoginUser.fromJson(json["data"])
        : null;
  }
}

class LoginUser {

  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? role;
  String? contactNumber;
  int? secretCode;

  LoginUser.fromJson(Map<String,dynamic> json){

    id = json["id"];
    firstName = json["first_name"];
    lastName = json["last_name"];
    email = json["email"];
    role = json["role"];
    contactNumber = json["contact_number"];
    secretCode = json["secret_code"];
  }
}