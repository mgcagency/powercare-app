class JobStatusModel {
  int? id;
  String? status;

  JobStatusModel({
    this.id,
    this.status,
  });

  factory JobStatusModel.fromJson(Map<String, dynamic> json) {
    return JobStatusModel(
      id: json["id"],
      status: json["status"],
    );
  }
}