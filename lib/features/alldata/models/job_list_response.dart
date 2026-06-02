import 'dart:convert';

class JobListResponse {
  bool? success;
  JobPagination? job;
  List<JobModel>? jobLists;
  List<JobModel>? jobListData;
  String? message;
  int? statusCode;
  int? currentPage;
  int? lastPage;
  int? total;

  JobListResponse({
    this.success,
    this.job,
    this.jobLists,
    this.jobListData,
    this.message,
    this.statusCode,
    this.currentPage,
    this.lastPage,
    this.total,
  });

  factory JobListResponse.fromJson(Map<String, dynamic> json) {
    return JobListResponse(
      success: json['success'],
      job: json['job'] != null ? JobPagination.fromJson(json['job']) : null,
      jobLists: json['job_lists'] != null
          ? (json['job_lists'] as List).map((i) => JobModel.fromJson(i)).toList()
          : null,
      jobListData: json['job_list_data'] != null
          ? (json['job_list_data'] as List).map((i) => JobModel.fromJson(i)).toList()
          : null,
      message: json['message'],
      statusCode: json['status_code'],
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      total: json['total'],
    );
  }
}

class JobPagination {
  int? currentPage;
  List<JobModel>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  JobPagination({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory JobPagination.fromJson(Map<String, dynamic> json) {
    return JobPagination(
      currentPage: json['current_page'],
      data: json['data'] != null
          ? (json['data'] as List).map((i) => JobModel.fromJson(i)).toList()
          : null,
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class JobModel {
  int? id;
  String? leadEngineerStatus;
  String? jobNumber;
  String? jobName;
  String? siteContactName;
  String? email;
  String? mobileNo;
  String? jobLocation;
  String? city;
  String? state;
  String? jobDate;
  String? jobTime;
  String? jobDescription;
  String? documentFullLink;
  JobTypeStatus? jobTypeStatus;
  Engineer? leadEngineer;
  List<OtherEngineer>? otherEngineers;
  List<JobImage>? images;
  List<JobSheet>? jobSheets;
  Quote? quote;

  JobModel({
    this.id,
    this.leadEngineerStatus,
    this.jobNumber,
    this.jobName,
    this.siteContactName,
    this.email,
    this.mobileNo,
    this.jobLocation,
    this.city,
    this.state,
    this.jobDate,
    this.jobTime,
    this.jobDescription,
    this.documentFullLink,
    this.jobTypeStatus,
    this.leadEngineer,
    this.otherEngineers,
    this.images,
    this.jobSheets,
    this.quote,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'],
      leadEngineerStatus: json['lead_engineer_status'],
      jobNumber: json['job_number']?.toString(),
      jobName: json['job_name'],
      siteContactName: json['site_contact_name'],
      email: json['email'],
      mobileNo: json['mobile_no'],
      jobLocation: json['job_location'],
      city: json['city'],
      state: json['state'],
      jobDate: json['job_date'],
      jobTime: json['job_time'],
      jobDescription: json['job_description'],
      documentFullLink: json['document_full_link'],
      jobTypeStatus: json['jobtypestatus'] != null
          ? JobTypeStatus.fromJson(json['jobtypestatus'])
          : null,
      leadEngineer: json['engineer'] != null
          ? Engineer.fromJson(json['engineer'])
          : null,
      otherEngineers: json['other_engineer'] != null
          ? (json['other_engineer'] as List).map((i) => OtherEngineer.fromJson(i)).toList()
          : null,
      images: json['images'] != null
          ? (json['images'] as List).map((i) => JobImage.fromJson(i)).toList()
          : null,
      jobSheets: json['job_sheet'] != null
          ? (json['job_sheet'] as List).map((i) => JobSheet.fromJson(i)).toList()
          : null,
      quote: json['quote'] != null ? Quote.fromJson(json['quote']) : null,
    );
  }
}

class JobTypeStatus {
  int? id;
  String? status;
  String? colorCode;

  JobTypeStatus({this.id, this.status, this.colorCode});

  factory JobTypeStatus.fromJson(Map<String, dynamic> json) {
    return JobTypeStatus(
      id: json['id'],
      status: json['status'],
      colorCode: json['color_code'],
    );
  }
}

class OtherEngineer {
  int? id;
  String? status;
  Engineer? user;

  OtherEngineer({this.id, this.status, this.user});

  factory OtherEngineer.fromJson(Map<String, dynamic> json) {
    return OtherEngineer(
      id: json['id'],
      status: json['status'],
      user: json['user'] != null ? Engineer.fromJson(json['user']) : null,
    );
  }
}

class Engineer {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? contactNumber;
  String? userImage;

  Engineer({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.contactNumber,
    this.userImage,
  });

  factory Engineer.fromJson(Map<String, dynamic> json) {
    return Engineer(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      contactNumber: json['contact_number'],
      userImage: json['user_image']?.toString(),
    );
  }

  String get fullName => "${firstName ?? ''} ${lastName ?? ''}".trim();
}

class JobImage {
  int? id;
  String? imageFullLink;

  JobImage({this.id, this.imageFullLink});

  factory JobImage.fromJson(Map<String, dynamic> json) {
    return JobImage(
      id: json['id'],
      imageFullLink: json['image_full_link'],
    );
  }
}

class JobSheet {
  int? id;
  String? description;
  String? documentFullLink;

  JobSheet({this.id, this.description, this.documentFullLink});

  factory JobSheet.fromJson(Map<String, dynamic> json) {
    return JobSheet(
      id: json['id'],
      description: json['description'],
      documentFullLink: json['document_full_link'],
    );
  }
}

class Quote {
  int? id;
  String? quoteNumber;
  String? amountDue;
  String? status;

  Quote({this.id, this.quoteNumber, this.amountDue, this.status});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      quoteNumber: json['quote_number'],
      amountDue: json['amount_due'],
      status: json['status'],
    );
  }
}