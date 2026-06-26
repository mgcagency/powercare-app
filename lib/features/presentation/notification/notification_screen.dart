import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/theme/colors.dart';

import '../../../app/theme/text_styles.dart';
import '../../../app/widget/custom_appbar.dart';
import '../../../app/widget/custom_text.dart';
import '../../alldata/api_repository/notification_repository.dart';
import '../../alldata/models/NotificationResponse.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationRepository repository = NotificationRepository();

  List<NotificationData> notifications = [];

  bool isLoading = false;

  int page = 1;
  int lastPage = 1;
  final ScrollController
  scrollController =
  ScrollController();
  @override
  void initState() {
    super.initState();
    markNotificationsRead();

    callNotificationApi();

    scrollController.addListener(() {

      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {

        if (!isLoading &&
            page < lastPage) {

          page++;

          callNotificationApi();
        }
      }
    });
  }
  Future<void> markNotificationsRead() async {

    try {

      await repository.markAllAsRead();

      print(
        "Notifications marked as read",
      );

    } catch (e) {

      print(
        "Read Notification Error => $e",
      );
    }
  }
  Future<void> callNotificationApi() async {
    if(page == 1){
      notifications.clear();
    }
    setState(() {
      isLoading = true;
    });

    try {
      final response = await repository.getNotifications(page);

      notifications.addAll(response.notification?.data ?? []);

      lastPage = response.notification?.lastPage ?? 1;

      print("Notification Count = ${notifications.length}");

      setState(() {});
    } catch (e) {
      print("Notification Error => $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(title: "Notifications"),
  /*    body: isLoading && notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(child: Text("No Notification Available"))

          : ListView.builder(
        controller: scrollController,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];*/
        body: isLoading &&
            notifications.isEmpty
            ? const Center(
          child:
          CircularProgressIndicator(),
        )
            : notifications.isEmpty
            ?  Center(
          child: CustomText(
            "No Notification Available",
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textColor,
            ),
          ),
        )
            : RefreshIndicator(
          onRefresh: () async {

            page = 1;
            notifications.clear();

            await callNotificationApi();
          },
          child: ListView.builder(
            controller: scrollController,
            itemCount:
            notifications.length,
            itemBuilder:
                (context, index) {

              final item =
              notifications[index];
                return Card(color: item.isRead == 0
                    ? Colors.orange.shade50
                    : Colors.white,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  elevation: 2,

                  child: ListTile(
      /*              onTap:  () {

                    if(item.jobId != null){

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              JobDetailsScreen(
                                jobId:
                                item.jobId!,
                              ),
                        ),
                      );
                    }
                  },*/
                    leading: CircleAvatar(
                      backgroundColor: item.isRead == 0
                          ? AppColors.primary
                          : AppColors.grey,

                      child: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ),
                    ),
                    title: CustomText(
                      item.title ?? "",
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                 /*   title: Text(
                      item.title ?? "",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),*/
                   // working custom text  code
/*
                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        const SizedBox(height: 5),

                        CustomText(
                          item.body ?? "",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textColor,
                          ),
                        ),

                        const SizedBox(height: 5),

                        CustomText(
                          item.createdAt ?? "",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey,
                            fontSize: 11,
                          ),
                        ),

                        if(item.type == "job_invitation")
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                            ),
                            child: Row(
                              children: [

                                ElevatedButton(
                                  onPressed: () {
                                    print("Accept Click");
                                  },
                                  child: CustomText(
                                    "Accept",
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                OutlinedButton(
                                  onPressed: () {
                                    print("Reject Click");
                                  },
                                  child: CustomText(
                                    "Reject",
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
*/

                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        const SizedBox(height: 5),

                        Text(item.body ?? ""),

                        const SizedBox(height: 5),

                        Text(
                          item.createdAt ?? "",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),

                        if(item.type == "job_invitation")
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                            ),
                            child: Row(
                              children: [

                                ElevatedButton(
                                  onPressed: () {

                                    print(
                                      "Accept Click",
                                    );
                                  },
                                  child: const Text(
                                    "Accept",
                                  ),
                                ),

                                const SizedBox(width: 10),

                                OutlinedButton(
                                  onPressed: () {

                                    print(
                                      "Reject Click",
                                    );
                                  },
                                  child: const Text(
                                    "Reject",
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                  ),
                );
              },
            ),
    ));
  }
}
