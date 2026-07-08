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
import '../holiday/RequestHolidayScreen.dart';
import '../job_status/job_status_screen.dart';
import '../jobs/job_list_screen.dart';
import '../landing/landing_screen.dart';
import '../timelog/TimeLogScreen.dart';
import '../../alldata/api_repository/dashboard_repository.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// One job's summary, used by both the week strip dot and the Today card.
class JobSummary {
  final String id;
  final String title;
  final String site;
  final String time;
  JobSummary({required this.id, required this.title, required this.site, required this.time});
}

class _HomeScreenState extends State<HomeScreen> {
  String fullName = "Engineer";
  DateTime selectedDay = DateTime.now();
  final DashboardRepository dashboardRepository =
  DashboardRepository();
  // TODO: replace with real data from your job repository/provider.
  Map<DateTime, List<JobSummary>> jobsByDay = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadJobs();
  }

  void _loadUserData() async {
    String firstName = await AppPreferences.getUserName() ?? "";
    if (mounted) {
      setState(() {
        fullName = firstName.trim().isEmpty ? "Engineer" : firstName.trim();
      });
    }
  }

/*  void _loadJobs() async {
    // TODO: wire this up to your actual job source (API / local DB / provider).
    final now = DateTime.now();
    setState(() {
      jobsByDay = {
        _dayKey(now.add(const Duration(days: 2))): [
          JobSummary(id: "JOB-2226", title: "Commercial Site Ph-2 Installation", site: "Stockton Engineering Complex", time: "9:00 AM"),
        ],
      };
    });
  }*/
  Future<void> _loadJobs() async {
    try {
      final response = await dashboardRepository.getDashboard();

      final upcoming = response["upcomingJobs"];

     /* if (upcoming == null) {
        return;
      }*/
      if (upcoming == null) {
        setState(() {
          jobsByDay = {};
        });
        return;
      }
      final now = DateTime.now();

      setState(() {
        jobsByDay = {
          _dayKey(now.add(const Duration(days: 2))): [
            JobSummary(
              id: upcoming["job_number"]?.toString() ?? "",
              title: upcoming["job_name"] ?? "",
              site:
              "${upcoming["job_location"] ?? ""}, ${upcoming["city"] ?? ""}",
              time: upcoming["job_time"] ?? "",
            ),
          ],
        };
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  List<JobSummary> _jobsFor(DateTime d) => jobsByDay[_dayKey(d)] ?? [];

  JobSummary? _nextUpcomingJob() {
    final sortedDays = jobsByDay.keys.where((d) => !d.isBefore(_dayKey(DateTime.now()))).toList()
      ..sort();
    for (final day in sortedDays) {
      final jobs = jobsByDay[day] ?? [];
      if (jobs.isNotEmpty) return jobs.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
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
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildOperationalMetrics(),
                  const SizedBox(height: 20),

                  _buildSectionHeader("My Jobs"),
                  const SizedBox(height: 20),
                  _buildWeekStrip(),
                  const SizedBox(height: 20),

                  _buildTodayCard(),
                  const SizedBox(height: 20),
                  _buildSectionHeader("Quick actions"),
                  const SizedBox(height: 12),
                  _buildQuickActionsScroll(),
                  const SizedBox(height: 20),
                  // _buildSectionHeader("Service Terminal"),
                  // const SizedBox(height: 16),
                  // _buildServiceTerminalList(),
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
      ],
    );
  }

  Widget _buildWeekStrip() {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final days = List.generate(
      7,
          (i) => startOfWeek.add(Duration(days: i)),
    );

    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    const weekdayLabels = [
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun"
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        CustomText(
          "${months[today.month - 1]} ${today.year}",
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.navyBlue,
          ),
        ),

        const SizedBox(height: 15),

        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {

              final day = days[index];

              final isSelected =
                  _dayKey(day) == _dayKey(selectedDay);

              final isToday =
                  _dayKey(day) == _dayKey(DateTime.now());

              final jobs = _jobsFor(day);

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();

                  setState(() {
                    selectedDay = day;
                  });
                },

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),

                  width: 62,

                  decoration: BoxDecoration(

                    color: isSelected
                        ? AppColors.primary
                        : Colors.white,

                    borderRadius: BorderRadius.circular(18),

                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade300,
                    ),

                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color:
                          AppColors.primary.withOpacity(.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Visibility(
                        visible: isToday,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: CustomText(
                            "TODAY",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),

                      Visibility(
                          visible: isToday,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: SizedBox(height: 4)),

                      CustomText(
                        weekdayLabels[index],
                        style: AppTextStyles.bodyExtraSmall.copyWith(
                          color: isSelected
                              ? Colors.white70
                              : Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 2),

                      CustomText(
                        "${day.day}",
                        style: AppTextStyles.headline4.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : AppColors.navyBlue,
                        ),
                      ),

                      const SizedBox(height: 2),
                      Visibility(
                          visible: jobs.isNotEmpty,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child:
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white24
                                : AppColors.primary
                                .withOpacity(.12),
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: CustomText(
                            "${jobs.length}",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                          ),
                        )),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
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

  Widget _buildTodayCard() {
    final selectedJobs = _jobsFor(selectedDay);
    final isToday = _dayKey(selectedDay) == _dayKey(DateTime.now());

    // Jobs available for selected day
    if (selectedJobs.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [

                Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      CustomText(
                        isToday
                            ? "Today's Jobs"
                            : _formatDate(selectedDay),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.navyBlue,
                        ),
                      ),

                      const SizedBox(height: 2),

                      CustomText(
                        "${selectedJobs.length} job${selectedJobs.length > 1 ? 's' : ''} scheduled",
                        style: AppTextStyles.bodyExtraSmall.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          ...selectedJobs.map(
                (job) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _jobCard(
                label: isToday ? "TODAY" : "SCHEDULED",
                job: job,
                dateText: _formatDate(selectedDay),
              ),
            ),
          ),
        ],
      );
    }

    // No jobs on selected day → show next upcoming job
    final next = _nextUpcomingJob();

    if (next != null) {
      return _jobCard(
        label: "NEXT JOB",
        job: next,
        dateText: "Upcoming",
      );
    }

    // No jobs at all
    return _emptyStateCard();
  }

  Widget _jobCard({required String label, required JobSummary job, required String dateText}) {
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
                      label.toUpperCase(),
                      style: AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomText(
                    "${job.id} · ${job.title}",
                    style: AppTextStyles.headline4.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 16),
                      const SizedBox(width: 6),
                      CustomText(job.site, style: AppTextStyles.bodySmall.copyWith(color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildTag(Icons.calendar_today_rounded, dateText),
                      const SizedBox(width: 12),
                      _buildTag(Icons.access_time_rounded, job.time),
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

  Widget _emptyStateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.event_available_rounded, color: Colors.grey[300], size: 32),
          const SizedBox(height: 12),
          CustomText(
            "No jobs scheduled",
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.navyBlue, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          CustomText(
            "New assignments will show up here as soon as they're scheduled.",
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${d.day} ${months[d.month - 1]}";
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

  // Things with no bottom tab of their own — one-off actions rather than
  // destinations, same idea as the existing "Add New" bottom sheet
  // (Time Log / Request Holiday) in DashboardScreen.
  Widget _buildQuickActionsScroll() {
    final items = [
      _QuickAction(
        title: "Create job",
        icon: Icons.add_task_rounded,
        color: Colors.orange,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateJobScreen())),
      ),
      _QuickAction(
        title: "Order material",
        icon: Icons.inventory_2_rounded,
        color: Colors.teal,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialScreen())),
      ),
      // _QuickAction(
      //   title: "Add jobsheet",
      //   icon: Icons.description_rounded,
      //   color: Colors.blue,
      //   onTap: () {
      //     // TODO: navigate to your jobsheet screen once it exists.
      //   },
      // ),
      _QuickAction(
        title: "Request holiday",
        icon: Icons.beach_access_rounded,
        color: Colors.green,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RequestHolidayScreen())),
      ),
      _QuickAction(
        title: "Logout",        icon: Icons.logout_rounded,
        color: Colors.red,
        onTap: () {
          // Add your logout logic here (e.g., clear preferences and navigate to Login)
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const CustomText("Logout"),
              content: const CustomText("Are you sure you want to logout?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const CustomText("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    await AppPreferences.setLoggedIn(false);
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                    );
                  },
                  child: const CustomText("Logout", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) => _buildQuickActionChip(items[index]),
      ),
    );
  }

  Widget _buildQuickActionChip(_QuickAction action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          action.onTap?.call();
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 92,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, size: 18, color: action.color),
              ),
              const SizedBox(height: 8),
              CustomText(
                action.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.navyBlue, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Full list, per client requirement — duplicates the bottom tabs
  // (Job terminal, Job status, Time logs, Contacts) deliberately, plus
  // Materials which doesn't have its own tab.
  Widget _buildServiceTerminalList() {
    final items = [
      _NavRowData(
        title: "Job terminal",
        subtitle: "View and manage active jobs",
        icon: Icons.assignment_rounded,
        color: Colors.blue,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobListScreen())),
      ),
      _NavRowData(
        title: "Job status",
        subtitle: "Check real-time progress",
        icon: Icons.analytics_outlined,
        color: Colors.purple,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobStatusScreen())),
      ),
      _NavRowData(
        title: "Materials",
        subtitle: "Order and track site supply",
        icon: Icons.inventory_2_rounded,
        color: Colors.teal,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialScreen())),
      ),
      _NavRowData(
        title: "Time logs",
        subtitle: "Review logged work hours",
        icon: Icons.history_toggle_off_rounded,
        color: Colors.amber,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimeLogScreen())),
      ),
      _NavRowData(
        title: "Contact book",
        subtitle: "Site and team contacts",
        icon: Icons.contact_phone_rounded,
        color: Colors.indigo,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactBookScreen())),
      ),
    ];

    return Column(
      children: items.map((item) => _buildNavRow(item)).toList(),
    );
  }

  Widget _buildNavRow(_NavRowData data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            data.onTap?.call();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: data.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(data.icon, color: data.color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(data.title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
                      const SizedBox(height: 2),
                      CustomText(data.subtitle, style: AppTextStyles.bodyExtraSmall.copyWith(color: Colors.grey[400])),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  _QuickAction({required this.title, required this.icon, required this.color, this.onTap});
}

class _NavRowData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  _NavRowData({required this.title, required this.subtitle, required this.icon, required this.color, this.onTap});
}