class ApiEndpoints {
  // Base URL (can also use separate file for environment-specific URLs)

  // Authentication
  static const String login = '/auth/login';
  static const String jobList = '/job/list';
  static const String jobDetails = '/job/details';
  static const String editJobSheet = "/jobsheet/edit";
  static const String jobTypeStatusList = '/jobtypestatus/list';
  static const String jobImageUpload = '/job/image';
  static const String jobImageDelete = '/job/image-delete/';
  static const String contactList = '/contact/list';
  static const String materialList = '/material/list';
  static const String materialPurchaseList = '/material/purchase-list';
  static const String createJob = '/job/create';
  static const String userList = '/user/list';
  static const String jobNumber = '/job/job-number';
  static const String notificationList = '/user/notification';
  static const String readNotification = '/user/read-notification';
  static const String leaveCreate = '/holiday/leaveCreate';
  static const String timeLogList = '/timesheets/get';
  static const String timeSheetCreate =
      '/timesheets/create';
  static const archiveJobList = "/archives/list";
  static const String createPlantUsage = "/plant-usage/create";
  static const String createRaisePO = "/raispos/create";
  static const changeEngineerStatus =
      "/job/change-engineer-status";
  static const String dashboard = "/dashboard";

}