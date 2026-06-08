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

class NotificationData {
  final int? id;
  final String? title;
  final String? body;
  final int? isRead;
  final String? createdAt;
  final String? jobId;
  final String? type;

  NotificationData({
    this.id,
    this.title,
    this.body,
    this.isRead,
    this.createdAt,
    this.jobId,
    this.type,
  });

  factory NotificationData.fromJson(
      Map<String, dynamic> json) {
    return NotificationData(
      id: json["id"],
      title: json["title"],
      body: json["body"],
      isRead: json["is_read"],
      createdAt: json["created_at"],
      jobId: json["job_id"]?.toString(),
      type: json["type"],
    );
  }
}