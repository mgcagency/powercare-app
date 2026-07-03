class UserModel {
  int? id;
  String? firstName;
  String? lastName;
  String? role;
  String? email;
  String? contactNumber;
  String? status;
  String? userImage;
  List<TimeSheetEntry>? timesheet;

  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.role,
    this.email,
    this.contactNumber,
    this.status,
    this.userImage,
    this.timesheet,
  });

  // Helper to get full name
  String get fullName => "${firstName ?? ""} ${lastName ?? ""}".trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      role: json["role"],
      email: json["email"],
      contactNumber: json["contact_number"],
      status: json["status"],
      userImage: json["user_image"],
      timesheet: json["timesheet"] != null
          ? List<TimeSheetEntry>.from(
          json["timesheet"].map((x) => TimeSheetEntry.fromJson(x)))
          : [],
    );
  }
}

class TimeSheetEntry {
  int? id;
  int? jobId;
  int? engineerId;
  String? startTime;
  String? endTime;
  String? createdAt;
  String? updatedAt;

  TimeSheetEntry({
    this.id,
    this.jobId,
    this.engineerId,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.updatedAt,
  });

  factory TimeSheetEntry.fromJson(Map<String, dynamic> json) {
    return TimeSheetEntry(
      id: json["id"],
      jobId: json["job_id"],
      engineerId: json["engineer_id"],
      startTime: json["start_time"] ?? "00:00",
      endTime: json["end_time"] ?? "00:00",
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
    );
  }
}