import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/theme/colors.dart';
import '../../../app/widget/custom_button.dart';
import '../../../app/widget/custom_text.dart';
import '../../../core/storage/app_preferences.dart';
import '../Material/material_screen.dart';
import '../contactbook/contact_book_screen.dart';
import '../createjob/CreateJobScreen.dart';
import '../job_status/job_status_screen.dart';
import '../jobs/job_list_screen.dart';
import '../landing/landing_screen.dart';
import '../timelog/TimeLogScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fullName = "Engineer";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    String firstName = await AppPreferences.getUserName() ?? "";
    if (mounted) {
      setState(() {
        fullName = firstName.trim().isEmpty ? "Engineer" : firstName.trim();
      });
    }
  }

  Future<void> _showLogoutDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent, size: 60),
                const SizedBox(height: 16),
                CustomText(
                  "Session Termination",
                  style: AppTextStyles.headline4.copyWith(color: AppColors.navyBlue, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CustomText(
                  "Confirm logout from the engineering portal?",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        title: "CANCEL",
                        background: Colors.grey.shade100,
                        textClr: AppColors.navyBlue,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        title: "LOGOUT",
                        background: Colors.redAccent,
                        onPressed: () async {
                          await AppPreferences.setLoggedIn(false);
                          if (!mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        },
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Design Elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.03),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildOperationalMetrics(),
                  const SizedBox(height: 20),
                  _buildActiveJobCard(),
                  const SizedBox(height: 20),
                  _buildSectionHeader("Service Terminal"),
                  const SizedBox(height: 16),
                  _buildNavigationGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          "Greetings, $fullName",
          style: AppTextStyles.headline3.copyWith(
            color: AppColors.navyBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        // Row(
        //   children: [
        //     Container(
        //       width: 10,
        //       height: 10,
        //       decoration: BoxDecoration(
        //         color: Colors.greenAccent,
        //         shape: BoxShape.circle,
        //         boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 6)],
        //       ),
        //     ),
        //     const SizedBox(width: 8),
        //     CustomText(
        //       "FIELD UNIT ACTIVE",
        //       style: AppTextStyles.bodyExtraSmall.copyWith(
        //         color: Colors.blueGrey[400],
        //         fontWeight: FontWeight.w900,
        //         letterSpacing: 1.2,
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildOperationalMetrics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMetric("Active Jobs", "04", Colors.blue),
          _buildDivider(),
          _buildMetric("Pending", "07", AppColors.primary),
          _buildDivider(),
          _buildMetric("Log Hours", "32.5", Colors.teal),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        CustomText(value, style: AppTextStyles.headline4.copyWith(color: color, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        CustomText(label, style: AppTextStyles.bodyExtraSmall.copyWith(color: Colors.grey[400], fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 30, color: Colors.grey.shade100);
  }


  Widget _buildMetricBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            CustomText(value, style: AppTextStyles.headline4.copyWith(color: color, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            CustomText(
              label,
              style: AppTextStyles.bodyExtraSmall.copyWith(color: Colors.grey[400], fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveJobCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),

      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Icon(Icons.bolt_rounded, size: 180, color: Colors.white.withOpacity(0.04)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: CustomText(
                      "Upcoming Assignment",
                      style: AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomText(
                    "Commercial Site Ph-2 Installation",
                    style: AppTextStyles.headline4.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 16),
                      const SizedBox(width: 6),
                      CustomText("Stockton Engineering Complex", style: AppTextStyles.bodySmall.copyWith(color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildTag(Icons.calendar_today_rounded, "04 Jun"),
                      const SizedBox(width: 12),
                      _buildTag(Icons.access_time_rounded, "09:00 AM"),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 14),
          const SizedBox(width: 8),
          CustomText(text, style: AppTextStyles.bodyExtraSmall.copyWith(color: Colors.black, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 2, height: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        CustomText(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _buildNavCard("View Jobs", Icons.assignment_rounded, Colors.blue, "Job Terminal", onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const JobListScreen()));
        }),
        _buildNavCard("Create Job", Icons.add_task_rounded, Colors.orange, "New Entry", onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateJobScreen()));
        }),
        _buildNavCard("Job Status", Icons.analytics_outlined, Colors.purple, "Live Progress", onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const JobStatusScreen()));
        }),
        _buildNavCard("Materials", Icons.inventory_2_rounded, Colors.amber, "Site Supply", onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialScreen()));
        }),
        _buildNavCard("Time Logs", Icons.history_toggle_off_rounded, Colors.green, "Work Records", onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TimeLogScreen()));
        }),
        _buildNavCard("Staff Index", Icons.contact_phone_rounded, Colors.indigo, "Contact Book", onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactBookScreen()));
        }),
        _buildNavCard("Archives", Icons.archive_rounded, Colors.blueGrey, "History"),
        _buildNavCard("Termination", Icons.power_settings_new_rounded, Colors.redAccent, "Sign Out", onTap: _showLogoutDialog),
      ],
    );
  }

  Widget _buildNavCard(String title, IconData icon, Color color, String subtitle, {VoidCallback? onTap}) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            CustomText(
              title,
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w900, color: AppColors.navyBlue),
            ),
            CustomText(
              subtitle,
              style: AppTextStyles.bodyExtraSmall.copyWith(color: Colors.grey[400], fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
