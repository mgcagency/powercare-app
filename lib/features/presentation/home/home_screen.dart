import 'package:flutter/material.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/theme/colors.dart';
import '../../../app/widget/custom_button.dart';
import '../../../app/widget/custom_text.dart';
import '../../../core/storage/app_preferences.dart';
import '../Material/material_screen.dart';
import '../contactbook/contact_book_screen.dart';
import '../createjob/CreateJobScreen.dart';
import '../landing/landing_screen.dart';
import '../timelog/TimeLogScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const primaryColor = Color(0xFFff5b1f);
  String fullName = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    // These methods must exist in your AppPreferences
    String firstName = await AppPreferences.getUserName() ?? "";

    setState(() {
      fullName = "$firstName".trim();
      if (fullName.isEmpty) fullName = "User";
    });
  }
  Future<void> _showLogoutDialog() async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close,
                      size: 22,
                    ),
                  ),
                ),

                const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 50,
                ),

                const SizedBox(height: 15),

                const Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Are you sure you want to log out?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  children: [

                    Expanded(
                      child:    CustomButton(
                        title: "No",
                        background: AppColors.darkGrey,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child:
                      CustomButton(
                        title: "Yes",
                        background: AppColors.primary,
                        onPressed: () async {
                          // Clear Login Data
                          await AppPreferences.setLoggedIn(false);

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const LoginScreen(),
                            ),
                                (route) => false,
                          );                        },
                      ),

                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GREETING: Using headline4 (Size 20, w600)
            CustomText(
               "Hi, $fullName",
              style: AppTextStyles.headline4,
            ),
            const SizedBox(height: 20),

            // UPCOMING JOBS CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
               // color: primaryColor,
                color: AppColors.navyBlue,

                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    "Upcoming Jobs",
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    "Commercial Generator Installation",
                    // Using bodyLarge (Size 18) and forcing bold
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                     "Stockton College",
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      CustomText(
                         "02 Jun 2026",
                        style: AppTextStyles.caption.copyWith(color: Colors.white),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      CustomText(
                         "10:00 AM",
                        style: AppTextStyles.caption.copyWith(color: Colors.white),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),

            // GRID OF MENU ITEMS
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: [
                _buildMenuCard("View Jobs", Icons.work_rounded, primaryColor),
                _buildMenuCard(
                  "Create a Job",
                  Icons.assignment_add,
                  const Color(0xFFd4a373),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const CreateJobScreen(),
                      ),
                    );
                  },
                ),
               // _buildMenuCard("Create a Job", Icons.assignment_add, const Color(0xFFd4a373)),
                _buildMenuCard("Job Status", Icons.history_rounded, const Color(0xFF6b5b95)),
                _buildMenuCard(
                  "Materials",
                  Icons.layers_rounded,
                  const Color(0xffcab526),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const MaterialScreen(),
                      ),
                    );
                  },
                ),
               // _buildMenuCard("Materials", Icons.layers_rounded, const Color(0xFFb5a642)),
                _buildMenuCard("Archived Jobs", Icons.inventory_2_rounded, const Color(0xFF7b9ebc)),
                _buildMenuCard(
                  "Time Logs",
                  Icons.update_rounded,
                  const Color(0xff1dc852),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const TimeLogScreen(),
                      ),
                    );
                  },
                ),
              //  _buildMenuCard("Time Logs", Icons.update_rounded, const Color(0xFF67ab7c)),
                _buildMenuCard(
                  "Contact Book",
                  Icons.contact_phone_rounded,
                  const Color(0xff1846ed),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const ContactBookScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  "Log out",
                  Icons.logout_rounded,
                  const Color(0xfff31403),
                  onTap: () {
                    _showLogoutDialog();
                  },
                ),
              ]
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
  Widget _buildMenuCard(
      String title,
      IconData icon,
      Color iconColor, {
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black.withOpacity(0.05),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            CustomText(
              title,
              style: AppTextStyles.bodyMedium
                  .copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const Spacer(),
            Align(
              alignment:
              Alignment.bottomRight,
              child: Icon(
                icon,
                size: 40,
                color: iconColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
/*
  Widget _buildMenuCard(String title, IconData icon, Color iconColor,  VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
               title,
              // Using bodyMedium (Size 14) and making it bold
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                icon,
                size: 40,
                color: iconColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
*/
}