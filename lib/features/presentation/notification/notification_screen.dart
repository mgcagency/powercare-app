import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/features/presentation/jobs/job_details_screen.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/widget/custom_appbar.dart';
import '../../../app/widget/custom_text.dart';
import '../../alldata/api_repository/notification_repository.dart';
import '../../alldata/models/NotificationResponse.dart';
import '../../alldata/api_repository/job_repository.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/storage/app_preferences.dart';
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationRepository repository = NotificationRepository();
  List<NotificationData> notifications = [];
  bool isLoading = false;
  bool isFirstLoad = true;
  int page = 1;
  int lastPage = 1;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    markNotificationsRead();
    callNotificationApi();

    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (!isLoading && page < lastPage) {
          page++;
          callNotificationApi();
        }
      }
    });
  }
  Future<void> openJob(NotificationData item) async {

    if (item.jobId == null) return;

    final response =
    await JobRepository().getJobDetails(item.jobId!);

    if (!mounted) return;

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => JobDetailsScreen(

          job: response.jobDetails!,

        ),

      ),

    );

  }
  Future<void> updateEngineerStatus(
      NotificationData item,
      String status,
      ) async {

    try {
      print("CLICKED JOB => ${item.jobId}");
      final userId = await AppPreferences.getUserID();
      print("USER ID => $userId");
      await JobRepository().changeEngineerStatus(

        jobId: item.jobId!,

        userId: userId,

        status: status,

      );

      page = 1;

      await callNotificationApi();

    } catch (e) {
      print("STATUS => $status");

      print(e);

    }
  }
  Future<void> markNotificationsRead() async {
    try {
      await repository.markAllAsRead();
    } catch (e) {
      debugPrint("Read Notification Error => $e");
    }
  }

  Future<void> callNotificationApi() async {

    setState(() => isLoading = true);

    try {

      final response = await repository.getNotifications(page);

      if (page == 1) {
        notifications.clear();
      }

      notifications.addAll(response.notification?.data ?? []);

      // DEBUG
      print("Notification Count => ${notifications.length}");

      for (final e in notifications) {

        print(
            "JobId => ${e.jobId} | Status => ${e.jobData?.leadEngineerStatus}");

      }

      lastPage = response.notification?.lastPage ?? 1;

    } catch (e) {

      debugPrint("Notification Error => $e");

    }

    setState(() {

      isLoading = false;

      isFirstLoad = false;

    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern off-white background
      appBar: const CustomAppBar(title: "Notifications"),
      body: isFirstLoad && isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : notifications.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          page = 1;
          await callNotificationApi();
        },
        child: ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemCount: notifications.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < notifications.length) {
              return _buildAnimatedItem(index);
            } else {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(int index) {
    final item = notifications[index];

    // Staggered Animation Logic
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index % 10 * 60)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: _buildNotificationCard(item),
    );
  }

  Widget _buildNotificationCard(NotificationData item) {
    print(
        "CARD JOB => ${item.jobId} STATUS => ${item.jobData?.leadEngineerStatus}");
    bool isUnread = item.isRead == 0;

    return
      InkWell(
        onTap: () {

          openJob(item);

        },

        child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isUnread ? Colors.blue.withOpacity(0.03) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Vertical indicator for unread notifications
              if (isUnread)
                Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isUnread
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.grey.shade100,
                            child: Icon(
                              Icons.notifications_none_rounded,
                              size: 20,
                              color: isUnread ? AppColors.primary : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  item.title ?? "",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                    color: AppColors.navyBlue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                CustomText(
                                  item.body ?? "",
                                  style: AppTextStyles.bodyExtraSmall.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (item.type?.toLowerCase() == "job" &&
                          item.jobData?.leadEngineerStatus == "PENDING")
                        const SizedBox(height: 12),

                      if (item.type?.toLowerCase() == "job" &&
                          item.jobData?.leadEngineerStatus == "PENDING")                            Row(
                              children: [
                                Spacer(),
                                _buildActionBtn(
        
                                  "Reject",
        
                                  Colors.grey.shade200,
        
                                  AppColors.navyBlue,
        
                                      (){
        
                                    updateEngineerStatus(item,"REJECT");
        
                                  },
        
                                ),
                               // _buildActionBtn("Reject", Colors.grey.shade100, AppColors.navyBlue),
                                const SizedBox(width: 8),
                                _buildActionBtn(
        
                                  "Accept",
        
                                  AppColors.primary,
        
                                  Colors.white,
        
                                      (){
        
                                    updateEngineerStatus(item,"ACCEPT");
        
                                  },
        
                                ),
                               // _buildActionBtn("Accept", AppColors.primary, Colors.white),
                                Spacer(),
                              ],
                            ),
                        ],
        
        
                  ),
                ),
              ),
            ],
          ),
        ),
            ),
      );
  }
  Widget _buildActionBtn(

      String text,

      Color bg,

      Color textCol,

      VoidCallback onTap,

      ) {

    return InkWell(
      onTap: onTap,



      child: Container(

        padding: const EdgeInsets.symmetric(

          horizontal: 16,

          vertical: 6,

        ),

        decoration: BoxDecoration(

          color: bg,

          borderRadius: BorderRadius.circular(8),

        ),

        child: CustomText(

          text,

          style: AppTextStyles.bodyExtraSmall.copyWith(

            color: textCol,

            fontWeight: FontWeight.bold,

          ),

        ),

      ),

    );

  }
/*
  Widget _buildActionBtn(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomText(
        text,
        style: AppTextStyles.bodyExtraSmall.copyWith(
          color: textCol,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
*/

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          CustomText(
            "No notifications yet",
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}