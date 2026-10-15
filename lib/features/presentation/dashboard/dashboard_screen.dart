import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/widget/custom_appbar.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
import 'package:powercare_flutter/features/presentation/holiday/RequestHolidayScreen.dart';
import 'package:powercare_flutter/features/presentation/job_status/job_status_screen.dart';
import 'package:powercare_flutter/features/presentation/jobs/job_list_screen.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../app/widget/custom_button.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/storage/app_preferences.dart';
import '../../alldata/api_repository/job_repository.dart';
import '../../alldata/api_repository/notification_repository.dart';
import '../../alldata/models/job_list_response.dart';
import '../contactbook/contact_book_screen.dart';
import '../home/home_screen.dart';
import '../notification/notification_screen.dart';
import '../profile/profile_screen.dart';
import '../timelog/TimeLogScreen.dart';
import 'dart:io';

import '../timelog/TimeSheetScreen.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const primary = Color(0xFFff5b1f);
  String profileImage = "";
  final JobRepository jobRepository = JobRepository();
  final NotificationRepository notificationRepository = NotificationRepository();

  int unreadCount = 0;
  List<JobModel> activeJobs = [];

  bool isJobLoading = false;
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomeScreen(),
    const JobListScreen(showAppBar: false),
    const JobStatusScreen(showAppBar: false),
    const TimeLogScreen(showAppBar: false),
    const ContactBookScreen(showAppBar: false),
  ];
/*  final List<Widget> _pages = [
    const HomeScreen(showAppBar: false),
    const JobListScreen(),
    const JobStatusScreen(),
    const TimeLogScreen(),
    const ContactBookScreen(),
    //const Center(child: CustomText("Timelog Content", style: TextStyle(fontSize: 20))),
   // const Center(child: CustomText("Contact Book Content", style: TextStyle(fontSize: 20))),
  ];*/
  final List<String> _titles = [
    "Home",
    "View Jobs",
    "Job Status",
    "Time Logs",
    "Contact Book",
  ];
  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.grid_view_rounded,
    Icons.access_time_filled_rounded,
    Icons.insert_chart_rounded,
    Icons.contact_phone_rounded,
  ];
  Future<void> loadNotificationCount() async {
    try {
      final response = await notificationRepository.getNotifications(1);

      final list = response.notification?.data ?? [];

      unreadCount = list.where((e) => e.isRead == 0).length;

      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  Future<void> loadActiveJobs() async {
    try {
      setState(() {
        isJobLoading = true;
      });

      // 1. Get the current logged-in User ID
      final String? userId = await AppPreferences.getUserID();

      final response = await jobRepository.getJobs({
        "page": "1",
        "my_job": 1,
        "job_date": "",
      });

      activeJobs.clear();

      if (response.job?.data != null && userId != null) {
        // 2. Filter: Only keep jobs where the login user has "ACCEPT" status
        final List<JobModel> filteredJobs = response.job!.data!.where((job) {

          // Check if user is the Lead Engineer and has accepted
          if (job.leadEngineer?.id.toString() == userId) {
            return job.leadEngineerStatus == "ACCEPT";
          }

          // Otherwise, check if user is in Other Engineers and has accepted
          if (job.otherEngineers != null) {
            final myEntry = job.otherEngineers!.any((e) =>
            (e.user?.id.toString() == userId || e.id?.toString() == userId) &&
                e.status == "ACCEPT"
            );
            return myEntry;
          }

          return false;
        }).toList();

        activeJobs.addAll(filteredJobs);
      }

      debugPrint("TOTAL FILTERED ACTIVE JOBS = ${activeJobs.length}");

      setState(() {
        isJobLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading active jobs: $e");
      setState(() {
        isJobLoading = false;
      });
    }
  }
  Future<void> loadProfileImage() async {

    profileImage =
        await AppPreferences.getUserImage() ?? "";

    print("DASHBOARD IMAGE => $profileImage");

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadProfileImage();
    loadNotificationCount();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title:_titles[_selectedIndex],
         onBack: () {
    AppNavigator.showExitDialog();
    },
        actions: [
          // 1. Add Button - Using a slight background or just a clean icon
          IconButton(
            tooltip: 'Add New',
            icon: const Icon(
              Icons.add_circle_outline_rounded, // A more modern 'plus' icon
              color: Colors.white,
              size: 30,
            ),
            onPressed: () => showAddOptions(),
          ),

          // 2. Notification Button with a refined badge
        // In your Dashboard actions/AppBar
        ValueListenableBuilder<int>(
          valueListenable: NotificationService.unreadCountNotifier,
          builder: (context, count, child) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white,size: 30,),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationScreen()),
                    ).then((_) {
                      // Refresh count when coming back from notification screen
                      NotificationService().refreshNotificationCount();
                    });
                  },
                ),
                if (count > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.navyBlue,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                      child: CustomText(
                        txtColor: Colors.white,
                        count > 9 ? "9+" : "$count",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

          // 3. Profile Avatar with a subtle border
          Padding(
            padding: const EdgeInsets.only(left: 8.0),  child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );

              print("result---->"+result.toString());
              // result == true means the user updated their profile
              if (result == true) {
                setState(() {
                  _pages[_selectedIndex] = _recreatePage(_selectedIndex, key: UniqueKey());                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
              ),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white24,
                backgroundImage: profileImage.isNotEmpty
                    ? (profileImage.startsWith('http')
                    ? NetworkImage(profileImage) // If it's a URL from the API
                    : FileImage(File(profileImage))) as ImageProvider // If it's a local path saved in Prefs
                    : null,
                child: profileImage.isEmpty
                    ? const Icon(Icons.person, size: 20, color: Colors.white)
                    : null,
              ),
            ),
          ),
          ),


          const SizedBox(width: 16), // Proper end spacing
        ],),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          return Stack(
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: Container(
          key: ValueKey(_selectedIndex),
          child: Material(
            type: MaterialType.transparency,
            child: _pages[_selectedIndex],
        )),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          // Padding around the bar to keep it floating
          padding: const EdgeInsets.fromLTRB(16, 7, 16, 7),
          child: Container(
            height: 60, // Reduced height since labels are removed
            decoration: BoxDecoration(
             // color: Colors.white,
              color: AppColors.pureWhite,

              borderRadius: BorderRadius.circular(30), // Circular rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: List.generate(_icons.length, (index) {
                final bool isSelected = _selectedIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: isSelected ? 1.2 : 1.0, // Slight pop effect when selected
                        child: Icon(
                          _icons[index],
                          size: 26,
                          color: isSelected ? AppColors.primary : const Color(0xFFBBBBBB),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
  // Add {Key? key} to the parameters
  Widget _recreatePage(int index, {Key? key}) {
    print("_recreatePage--->" + index.toString());
    switch (index) {
      case 0:
        return HomeScreen(key: key);
      case 1:
        return JobListScreen(key: key, showAppBar: false);
      case 2:
        return JobStatusScreen(key: key, showAppBar: false);
      case 3:
        return TimeLogScreen(key: key, showAppBar: false);
      case 4:
        return ContactBookScreen(key: key, showAppBar: false);
      default:
        return HomeScreen(key: key);
    }
  }
  void showAddOptions() {

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              ListTile(
                leading: const Icon(
                  Icons.access_time,
                  color: Colors.orange,
                ),
                title: const CustomText(
                  "Add Time Log",
                ),
                onTap: () async {

                  Navigator.pop(context);
                  await loadActiveJobs();
                  _showSelectJobDialog();
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.beach_access,
                  color: Colors.green,
                ),
                title: const CustomText(
                  "Request Holiday",
                ),
                onTap: () {

                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const RequestHolidayScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
  void _showSelectJobDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.pureWhite,
          surfaceTintColor: AppColors.pureWhite,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7, // Responsive height
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.assignment_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomText(
                          "Select Active Job",
                          style: AppTextStyles.headline4.copyWith(
                            color: AppColors.navyBlue,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        visualDensity: VisualDensity.compact,
                      )
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 5),
                  child: Divider(height: 1, thickness: 0.5),
                ),

                // Job List section
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: activeJobs.length,
                   // itemCount: 10, // Replace with your actual list length
                    itemBuilder: (context, index) {
                      return _buildPremiumJobCard(activeJobs[index]);
                    },
                  ),
                ),

                // Footer section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomButton(
                    background: AppColors.primary,
                    title: "Close",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

             /*       OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: CustomText(
                        "CLOSE",
                        style: AppTextStyles.button.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),*/
                  

              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumJobCard(JobModel job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () { Navigator.pop(context);
          Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) => TimeSheetScreen(

              jobId: job.id.toString(),

            ),

          ),

        );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Prefix
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.maps_home_work_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                  job.jobName ?? ""  ,
                  style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CustomText(
                        "Job No : ${job.jobNumber}",
                        style: AppTextStyles.bodyExtraSmall.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Trailing
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
/*
  void _showSelectJobDialog() {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(

          title: const CustomText(
            "Select Job",
          ),

          content: SizedBox(
            width: double.maxFinite,
            height: 300,

            child: ListView.builder(
              itemCount: 10,
              itemBuilder:
                  (context, index) {

                return ListTile(
                  title: CustomText(
                    "Job ${index + 1}",
                  ),
                  onTap: () {

                    Navigator.pop(
                      context,
                    );

                    // Open Add Time Log Screen
                  },
                );

              },
            ),

          ),

        );

      },
    );
  }
*/
}
