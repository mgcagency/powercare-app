// NotificationResponse.dart

import 'package:powercare_flutter/features/alldata/models/job_list_response.dart';

class NotificationResponse {
  final int? statusCode;
  final String? message;
  final NotificationPaginate? notification;

  NotificationResponse({
    this.statusCode,
    this.message,
    this.notification,  
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      statusCode: json["status_code"],
      message: json["message"],
      notification: json["notification"] != null
          ? NotificationPaginate.fromJson(json["notification"])
          : null,
    );
  }
}

class NotificationPaginate {
  final int? currentPage;
  final int? lastPage;
  final int? total;
  final List<NotificationData> data;

  NotificationPaginate({
    this.currentPage,
    this.lastPage,
    this.total,
    required this.data,
  });

  factory NotificationPaginate.fromJson(Map<String, dynamic> json) {
    return NotificationPaginate(
      currentPage: json["current_page"],
      lastPage: json["last_page"],
      total: json["total"],
      data: (json["data"] as List?)
          ?.map((e) => NotificationData.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class NotificationData {
  final int? id;
  final String? title;
  final String? body;
  final int? isRead;
  final String? createdAt;
  final String? jobId;
  final String? type;
  final JobModel? jobData;
  final String? status; // ✅ ADD THIS
  final bool? isProcessing; // ✅ ADD THIS

  NotificationData({
    this.id,
    this.title,
    this.body,
    this.isRead,
    this.createdAt,
    this.jobId,
    this.type,
    this.jobData,
    this.status,
    this.isProcessing,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json["id"],
      title: json["title"],
      body: json["body"],
      isRead: json["is_read"],
      createdAt: json["created_at"],
      jobId: json["job_id"]?.toString(),
      type: json["type"],
      jobData: json["job_data"] != null
          ? JobModel.fromJson(json["job_data"])
          : null,
      status: json["status"], // ✅ ADD THIS
      isProcessing: false, // ✅ ADD THIS
    );
  }

  // ✅ ADD THIS - Copy method for state updates
  NotificationData copyWith({
    int? id,
    String? title,
    String? body,
    int? isRead,
    String? createdAt,
    String? jobId,
    String? type,
    JobModel? jobData,
    String? status,
    bool? isProcessing,
  }) {
    return NotificationData(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      jobId: jobId ?? this.jobId,
      type: type ?? this.type,
      jobData: jobData ?? this.jobData,
      status: status ?? this.status,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class NotificationJobData {
  final int? leadEngineerId;
  final String? leadEngineerStatus;

  NotificationJobData({
    this.leadEngineerId,
    this.leadEngineerStatus,
  });

  factory NotificationJobData.fromJson(Map<String, dynamic> json) {
    return NotificationJobData(
      leadEngineerId: json["lead_engineer_id"],
      leadEngineerStatus: json["lead_engineer_status"],
    );
  }
}
/*
class NotificationResponse {
  final int? statusCode;
  final String? message;
  final NotificationPaginate? notification;
  NotificationResponse({
    this.statusCode,
    this.message,
    this.notification,
  });

  factory NotificationResponse.fromJson(
      Map<String, dynamic> json) {
    return NotificationResponse(
      statusCode: json["status_code"],

      message: json["message"],
      notification: json["notification"] != null
          ? NotificationPaginate.fromJson(
        json["notification"],
      )
          : null,
    );
  }
}

class NotificationPaginate {
  final int? currentPage;
  final int? lastPage;
  final int? total;
  final List<NotificationData> data;

  NotificationPaginate({
    this.currentPage,
    this.lastPage,
    this.total,
    required this.data,
  });

  factory NotificationPaginate.fromJson(
      Map<String, dynamic> json) {
    return NotificationPaginate(
      currentPage: json["current_page"],
      lastPage: json["last_page"],
      total: json["total"],
      data: (json["data"] as List?)
          ?.map(
            (e) => NotificationData.fromJson(e),
      )
          .toList() ??
          [],
    );
  }
}


class NotificationData copyWith({
  final int? id;
  final String? title;
  final String? body;
  final int? isRead;
  final String? createdAt;
  final String? jobId;
  final String? type;
  final String? status; // ✅ ADD THIS
  final bool? isProcessing; // ✅ ADD THIS

  // ADD THIS
  final NotificationJobData? jobData;

  NotificationData({
    this.id,
    this.title,
    this.body,
    this.isRead,
    this.createdAt,
    this.jobId,
    this.type,
    this.jobData, // ADD THIS
    this.status,
    this.isProcessing,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json["id"],
      title: json["title"],
      body: json["body"],
      isRead: json["is_read"],
      createdAt: json["created_at"],
      jobId: json["job_id"]?.toString(),
      type: json["type"],

      // ADD THIS HERE
      jobData: json["job_data"] != null
          ? NotificationJobData.fromJson(json["job_data"])
          : null,
      status: json["status"], // ✅ ADD THIS
      isProcessing: false, // ✅ ADD THIS
    );
  }
}

class NotificationJobData {

  final int? leadEngineerId;
  final String? leadEngineerStatus;

  NotificationJobData({
    this.leadEngineerId,
    this.leadEngineerStatus,
  });

  factory NotificationJobData.fromJson(
      Map<String, dynamic> json) {

    return NotificationJobData(

      leadEngineerId: json["lead_engineer_id"],

      leadEngineerStatus: json["lead_engineer_status"],

    );

  }

}*/
