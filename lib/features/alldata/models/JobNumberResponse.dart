class JobNumberResponse {
  String? jobNumber;

  JobNumberResponse({this.jobNumber});

  factory JobNumberResponse.fromJson(
      Map<String, dynamic> json) {
    return JobNumberResponse(
      jobNumber: json["job_number"],
    );
  }
}