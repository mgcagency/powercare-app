import 'job_list_response.dart';

class JobDetailsResponse {
  bool? success;
  String? jobDetailsId;
  JobModel? jobDetails;
  List<JobImage>? images;
  int? photoCount;
  int? photoLimit;
  int? statusCode;

  JobDetailsResponse({
    this.success,
    this.jobDetailsId,
    this.jobDetails,
    this.images,
    this.photoCount,
    this.photoLimit,
    this.statusCode,
  });

  factory JobDetailsResponse.fromJson(Map<String, dynamic> json) {
    return JobDetailsResponse(
      success: json['success'],
      jobDetailsId: json['job_details_id']?.toString(),
      jobDetails: json['jobDetails'] != null
          ? JobModel.fromJson(json['jobDetails'])
          : null,
      images: json['images'] != null
          ? (json['images'] as List).map((i) => JobImage.fromJson(i)).toList()
          : null,
      photoCount: json['photo_count'],
      photoLimit: json['photo_limit'],
      statusCode: json['status_code'],
    );
  }
}
