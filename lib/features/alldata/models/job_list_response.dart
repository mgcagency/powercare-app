import 'dart:convert';

import 'package:powercare_flutter/features/alldata/models/UserModel.dart';

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
  String? customerPoNumber;

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
  UserModel? leadEngineer;
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
    this.customerPoNumber,
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
      customerPoNumber: json["customer_po_number"],
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
          ? UserModel.fromJson(json['engineer'])
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
  String? createdAt;
  String? updatedAt;
  String? isVisibleEngineer;

  JobTypeStatus({
    this.id,
    this.status,
    this.colorCode,
    this.createdAt,
    this.updatedAt,
    this.isVisibleEngineer,
  });

  factory JobTypeStatus.fromJson(Map<String, dynamic> json) {
    return JobTypeStatus(
      id: json['id'],
      status: json['status'],
      colorCode: json['color_code'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isVisibleEngineer: json['is_visible_engineer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'color_code': colorCode,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_visible_engineer': isVisibleEngineer,
    };
  }

  /// Convenient getter
  bool get visibleToEngineer =>
      (isVisibleEngineer ?? '').toUpperCase() == 'YES';
}

class OtherEngineer {
  int? id;
  int? other_engineers_id;
  String? status;
  UserModel? user;

  OtherEngineer({this.id, this.other_engineers_id, this.status, this.user});

  factory OtherEngineer.fromJson(Map<String, dynamic> json) {
    return OtherEngineer(
      id: json['id'],
      other_engineers_id: json['other_engineers_id'],
      status: json['status'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
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

/*class JobSheet {
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
}*/
class JobSheet {
  int? id;
  int? jobId;
  int? companyId;
  String? clientName;
  String? companyName;
  String? email;
  String? officeNumber;
  String? mobileNumber;
  String? officeAddress;
  String? siteAddress;
  String? description;
  String? serviceRequest;
  String? dateOfOrder;
  String? dateRequired;
  String? purchaseOrderNumber;
  String? document;
  String? jobStatus;
  String? materialSubTotal;
  String? purchaseSubTotal;
  String? wageSubTotal;
  String? invoiceNumber;
  String? invoiceDate;
  String? invoiceAmount;
  String? notes;
  String? createdAt;
  String? updatedAt;
  String? documentFullLink;
  List<JobSheetMaterial>? jobSheetRelation;
  List<PurchaseSheetMaterial>? purchaseSheetRelation;

  JobSheet({
    this.id,
    this.jobId,
    this.companyId,
    this.clientName,
    this.companyName,
    this.email,
    this.officeNumber,
    this.mobileNumber,
    this.officeAddress,
    this.siteAddress,
    this.description,
    this.serviceRequest,
    this.dateOfOrder,
    this.dateRequired,
    this.purchaseOrderNumber,
    this.document,
    this.jobStatus,
    this.materialSubTotal,
    this.purchaseSubTotal,
    this.wageSubTotal,
    this.invoiceNumber,
    this.invoiceDate,
    this.invoiceAmount,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.documentFullLink,
    this.jobSheetRelation,
    this.purchaseSheetRelation,
  });

  factory JobSheet.fromJson(Map<String, dynamic> json) {
    print("jobsheet doc--->"+json['id'].toString()+",,,,"+ json['document_full_link']);
    return JobSheet(
      id: json['id'],
      jobId: json['job_id'],
      companyId: json['company_id'],
      clientName: json['client_name']?.toString(),
      companyName: json['company_name']?.toString(),
      email: json['email']?.toString(),
      officeNumber: json['office_number']?.toString(),
      mobileNumber: json['mobile_number']?.toString(),
      officeAddress: json['office_address']?.toString(),
      siteAddress: json['site_address']?.toString(),
      description: json['description']?.toString(),
      serviceRequest: json['service_request']?.toString(),
      dateOfOrder: json['date_of_order']?.toString(),
      dateRequired: json['date_required']?.toString(),
      purchaseOrderNumber: json['purchase_order_number']?.toString(),
      document: json['document']?.toString(),
      jobStatus: json['job_status']?.toString(),
      materialSubTotal: json['material_sub_total']?.toString(),
      purchaseSubTotal: json['purchase_sub_total']?.toString(),
      wageSubTotal: json['wage_sub_total']?.toString(),
      invoiceNumber: json['invoice_number']?.toString(),
      invoiceDate: json['invoice_date']?.toString(),
      invoiceAmount: json['invoice_amount']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      documentFullLink: json['document_full_link']??"",
      jobSheetRelation: json['job_sheet_relation'] != null
          ? (json['job_sheet_relation'] as List)
          .map((i) => JobSheetMaterial.fromJson(i))
          .toList()
          : null,
      purchaseSheetRelation: json['purchase_sheet_relation'] != null
          ? (json['purchase_sheet_relation'] as List)
          .map((i) => PurchaseSheetMaterial.fromJson(i))
          .toList()
          : null,
    );
  }
}

class JobSheetMaterial {
  int? id;
  int? jobsheetId;
  int? materialId;
  String? materialName;
  int? orderQty;
  int? usedQty;
  String? unitPrice;
  String? totalPrice;
  String? isFromWeb;

  JobSheetMaterial({
    this.id,
    this.jobsheetId,
    this.materialId,
    this.materialName,
    this.orderQty,
    this.usedQty,
    this.unitPrice,
    this.totalPrice,
    this.isFromWeb,
  });

  factory JobSheetMaterial.fromJson(Map<String, dynamic> json) {
    return JobSheetMaterial(
      id: json['id'],
      jobsheetId: json['jobsheet_id'],
      materialId: json['material_id'],
      materialName: json['material_name'],
      orderQty: json['order_qty'],
      usedQty: json['used_qty'],
      unitPrice: json['unit_price']?.toString(),
      totalPrice: json['total_price']?.toString(),
      isFromWeb: json['is_from_web'],
    );
  }
}

class PurchaseSheetMaterial {
  int? id;
  int? jobsheetId;
  int? materialId;
  String? purchaseMaterialName;
  int? purchaseOrderQty;
  int? purchaseQtyUsed;
  String? purchaseUnitPrice;
  String? purchaseTotalPrice;

  PurchaseSheetMaterial({
    this.id,
    this.jobsheetId,
    this.materialId,
    this.purchaseMaterialName,
    this.purchaseOrderQty,
    this.purchaseQtyUsed,
    this.purchaseUnitPrice,
    this.purchaseTotalPrice,
  });

  factory PurchaseSheetMaterial.fromJson(Map<String, dynamic> json) {
    return PurchaseSheetMaterial(
      id: json['id'],
      jobsheetId: json['jobsheet_id'],
      materialId: json['material_id'],
      purchaseMaterialName: json['purchase_material_name'],
      purchaseOrderQty: json['purchase_order_qty'],
      purchaseQtyUsed: json['purchase_qty_used'],
      purchaseUnitPrice: json['purchase_unit_price']?.toString(),
      purchaseTotalPrice: json['purchase_total_price']?.toString(),
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