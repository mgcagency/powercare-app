class UserModel {
  int? id;
  String? firstName;
  String? lastName;

  UserModel({
    this.id,
    this.firstName,
    this.lastName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      firstName: json["first_name"],
      lastName: json["last_name"],
    );
  }
}