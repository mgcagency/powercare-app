import 'package:powercare_flutter/features/alldata/models/job_list_response.dart';

class JobTypeStatusResponse {
  bool? success;
  List<JobTypeStatus>? jobTypeStatusLists;
  String? message;
  int? statusCode;

  JobTypeStatusResponse({
    this.success,
    this.jobTypeStatusLists,
    this.message,
    this.statusCode,
  });

  factory JobTypeStatusResponse.fromJson(Map<String, dynamic> json) {
    return JobTypeStatusResponse(
      success: json['success'],
      jobTypeStatusLists: json['jobTypeStatusLists'] != null
          ? (json['jobTypeStatusLists'] as List)
          .map((e) => JobTypeStatus.fromJson(e))
          .toList()
          : [],
      message: json['message'],
      statusCode: json['status_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'jobTypeStatusLists':
      jobTypeStatusLists?.map((e) => e.toJson()).toList(),
      'message': message,
      'status_code': statusCode,
    };
  }
}

