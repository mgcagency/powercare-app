import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/widget/custom_appbar.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
import 'package:powercare_flutter/features/presentation/holiday/RequestHolidayScreen.dart';
import 'package:powercare_flutter/features/presentation/job_status/job_status_screen.dart';
import 'package:powercare_flutter/features/presentation/jobs/job_list_screen.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../core/storage/app_preferences.dart';
import '../contactbook/contact_book_screen.dart';
import '../home/home_screen.dart';
import '../notification/notification_screen.dart';
import '../profile/profile_screen.dart';
import '../timelog/TimeLogScreen.dart';
import 'dart:io';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const primary = Color(0xFFff5b1f);
  String profileImage = "";

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
    //const Center(child: Text("Timelog Content", style: TextStyle(fontSize: 20))),
   // const Center(child: Text("Contact Book Content", style: TextStyle(fontSize: 20))),
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
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title:_titles[_selectedIndex],
        actions: [
          // 1. Add Button - Using a slight background or just a clean icon
          IconButton(
            tooltip: 'Add New',
            icon: const Icon(
              Icons.add_circle_outline_rounded, // A more modern 'plus' icon
              color: Colors.white,
              size: 26,
            ),
            onPressed: () => showAddOptions(),
          ),

          // 2. Notification Button with a refined badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded, // Outlined looks cleaner
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationScreen()),
                  );
                },
              ),
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5), // Matches AppBar color
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child:  CustomText(
                    "1",
                    style:  AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.navyBlue),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),

          // 3. Profile Avatar with a subtle border
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
                if (result == true) loadProfileImage();
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                ),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  backgroundImage: profileImage.isNotEmpty
                      ? FileImage(File(profileImage))
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
                title: const Text(
                  "Add Time Log",
                ),
                onTap: () {

                  Navigator.pop(context);

                  _showSelectJobDialog();
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.beach_access,
                  color: Colors.green,
                ),
                title: const Text(
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
      builder: (context) {

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(25),
          ),
          child: Container(
            height: 450,
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [

                const Text(
                  "Select Job",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView.builder(
                    itemCount: 10,
                    itemBuilder:
                        (context, index) {

                      return ListTile(
                        title: Text(
                          "Job ${index + 1}",
                        ),
                        subtitle: Text(
                          "Job Number ${(index + 1) * 100}",
                        ),
                        onTap: () {

                          Navigator.pop(
                            context,
                          );

                          // Open Screen
                        },
                      );
                    },
                  ),
                ),

                Align(
                  alignment:
                  Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    child: const Text(
                      "CANCEL",
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
/*
  void _showSelectJobDialog() {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(

          title: const Text(
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
                  title: Text(
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
