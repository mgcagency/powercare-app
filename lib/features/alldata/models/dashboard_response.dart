import 'package:powercare_flutter/features/alldata/models/job_list_response.dart';

class DashboardResponse {
  final bool success;
  final int statusCode;
  final String message;
  final int notificationCount;
  final String? totalTimesheetTime;
  final int workedJobs;
  final int pendingJobs;
  final List<JobModel> upcomingJobs; // Changed from JobModel? to List<JobModel>

  DashboardResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.notificationCount,
    this.totalTimesheetTime,
    required this.workedJobs,
    required this.pendingJobs,
    required this.upcomingJobs,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'] ?? false,
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? "",
      notificationCount: json['notification_count'] ?? 0,
      totalTimesheetTime: json['total_timesheet_time'],
      workedJobs: json['worked_jobs'] ?? 0,
      pendingJobs: json['pending_jobs'] ?? 0,
      // Handle the list of upcoming jobs
      upcomingJobs: json['upcoming_jobs'] != null && json['upcoming_jobs'] is List
          ? (json['upcoming_jobs'] as List)
          .map((jobJson) => JobModel.fromJson(jobJson))
          .toList()
          : [],
    );
  }
}