class DashboardResponse {
  bool? success;
  DashboardUser? user;

  DashboardResponse({
    this.success,
    this.user,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json["success"],
      user: json["user"] != null
          ? DashboardUser.fromJson(json["user"])
          : null,
    );
  }
}
class DashboardUser {
  int? id;
  String? firstName;
  String? lastName;
  String? role;
  String? email;
  String? contactNumber;
  String? userImage;

  DashboardUser({
    this.id,
    this.firstName,
    this.lastName,
    this.role,
    this.email,
    this.contactNumber,
    this.userImage,
  });

  factory DashboardUser.fromJson(Map<String, dynamic> json) {
    return DashboardUser(
      id: json["id"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      role: json["role"],
      email: json["email"],
      contactNumber: json["contact_number"],
      userImage: json["user_image"],
    );
  }
}