class TimeLogResponse {

  bool? success;
  List<TimeLogJob> jobs;

  TimeLogResponse({
    this.success,
    required this.jobs,
  });

  factory TimeLogResponse.fromJson(
      Map<String,dynamic> json) {

    return TimeLogResponse(
      success: json["success"],
      jobs: (json["job"] as List? ?? [])
          .map(
            (e) =>
            TimeLogJob.fromJson(e),
      )
          .toList(),
    );
  }
}

class TimeLogJob {

  int? id;
  String? jobName;
  String? jobTime;
  String? jobDate;
  String? jobEndTime;
  String? jobNumber;
  String? jobStatus;
  String? jobLocation;

  TimeLogJob({
    this.id,
    this.jobName,
    this.jobTime,
    this.jobDate,
    this.jobEndTime,
    this.jobNumber,
    this.jobStatus,
    this.jobLocation,
  });

  factory TimeLogJob.fromJson(
      Map<String,dynamic> json) {

    return TimeLogJob(
      id: json["id"],
      jobName: json["job_name"],
      jobDate: json["job_date"],
      jobTime: json["job_time"],
      jobEndTime: json["job_end_time"],
      jobNumber: json["job_number"],
      jobStatus: json["job_status"],
      jobLocation: json["job_location"],
    );
  }
}