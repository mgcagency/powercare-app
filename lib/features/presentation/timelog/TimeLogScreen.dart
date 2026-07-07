import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:powercare_flutter/app/theme/colors.dart';

import '../../../app/theme/text_styles.dart';
import '../../../app/widget/custom_appbar.dart';
import '../../../app/widget/custom_text.dart';
import '../../../core/storage/app_preferences.dart';
import '../../alldata/api_repository/TimeLogRepository.dart';
import '../../alldata/models/TimeLogResponse.dart';
import 'TimeSheetScreen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/services.dart';

class TimeLogScreen extends StatefulWidget {
  final bool showAppBar;

  const TimeLogScreen({super.key, this.showAppBar = true});

  @override
  State<TimeLogScreen> createState() => TimeLogScreenState();
}

class TimeLogScreenState extends State<TimeLogScreen> {
  final TimeLogRepository repository = TimeLogRepository();
  DateTime selectedDate = DateTime.now();
  DateTime selectedWeekDate = DateTime.now();
  List<DateTime> currentWeek = [];
  List<TimeLogJob> jobs = [];

  bool isLoading = false;
  String selectedTab = "Day";

  @override
  void initState() {
    super.initState();
    generateWeek();
    callTimeLogApi();
  }

  void generateWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    currentWeek = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );
  }

  Future<void> callTimeLogApi() async {
    try {
      setState(() => isLoading = true);
      final userId = await AppPreferences.getUserID();
      String apiDateKey = selectedTab.toUpperCase();

      final response = await repository.getTimeLogs(
        date: DateFormat("dd-MM-yyyy").format(DateTime.now()),
        engineerId: userId,
        dateKey: apiDateKey,
        specificDate: selectedTab == "Month"
            ? DateFormat("yyyy-MM-dd").format(selectedDate)
            : selectedTab == "Week"
                ? DateFormat("yyyy-MM-dd").format(selectedWeekDate)
                : DateFormat("yyyy-MM-dd").format(selectedDate),
      );

      setState(() {
        jobs = response.jobs;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {    return Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: widget.showAppBar ? const CustomAppBar(title: "Time Logs") : null,
    body: CustomScrollView( // Changed to CustomScrollView for better scrolling
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildTopTabs(),
              const SizedBox(height: 10),

              // Selection Area (Day, Week, or Month)
              if (selectedTab == "Day") _buildSimpleDayDisplay(),
              if (selectedTab == "Week") _buildWeekSelector(),
              if (selectedTab == "Month") _buildMonthSelector(),

              const SizedBox(height: 10),

              // Section Label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 2, height: 20,
                      decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2)
                      ),
                    ),
                    const SizedBox(width: 10),
                    CustomText(
                      "Work Log Entries",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    if (!isLoading && jobs.isNotEmpty)
                      CustomText(
                        "${jobs.length} Entries",
                        style: AppTextStyles.bodyExtraSmall.copyWith(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.bold
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // The Log List Area
        isLoading
            ? const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        )
            : jobs.isEmpty
            ? SliverFillRemaining(child: _buildEmptyState())
            : SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildEngineeringLogCard(jobs[index]),
              childCount: jobs.length,
            ),
          ),
        ),
      ],
    ),
  );
  }

  Widget _buildTopTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 4)),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / 3;
            final selectedIndex = selectedTab == "Day" ? 0 : selectedTab == "Week" ? 1 : 2;

            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  left: selectedIndex * tabWidth + (selectedIndex == 0 ? 4 : (selectedIndex == 1 ? 2 : 0)),
                  top: 4, bottom: 4,
                  child: Container(
                    width: tabWidth - 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    _tabButton("Day", 0),
                    _tabButton("Week", 1),
                    _tabButton("Month", 2),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSimpleDayDisplay() {
    return Container(
      decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            DateFormat("EEEE").format(selectedDate).toUpperCase(),
            style: AppTextStyles.bodyExtraSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                DateFormat("MMMM d, yyyy").format(selectedDate),
                style: AppTextStyles.headline4.copyWith(
                  color: AppColors.navyBlue,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
              IconButton(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_month_rounded, color: AppColors.navyBlue, size: 24),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.navyBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      callTimeLogApi();
    }
  }

  Widget _buildWeekSelector() {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: currentWeek.length,
        itemBuilder: (_, index) {
          final day = currentWeek[index];
          final isSelected = isSameDay(day, selectedWeekDate);
          final isToday = isSameDay(day, DateTime.now());

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => selectedWeekDate = day);
              callTimeLogApi();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 58,
              margin: const EdgeInsets.only(right: 10, top: 4, bottom: 10),
              decoration: BoxDecoration(

                color: isSelected ? AppColors.navyBlue : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected 
                      ? AppColors.navyBlue 
                      : (isToday ? AppColors.primary.withOpacity(0.3) : Colors.grey.shade100),
                  width: isToday ? 2 : 1,
                ),
                boxShadow: isSelected 
                    ? [BoxShadow(color: AppColors.navyBlue.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))] 
                    : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    DateFormat("EEE").format(day).toUpperCase(),
                    style: AppTextStyles.bodyExtraSmall.copyWith(
                      color: isSelected ? Colors.white70 : Colors.grey[400],
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  CustomText(
                    day.day.toString(),
                    style: AppTextStyles.headline4.copyWith(
                      color: isSelected ? Colors.white : AppColors.navyBlue,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  if (isToday && !isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4, height: 4,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: selectedDate,
        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          HapticFeedback.lightImpact();
          setState(() => selectedDate = selectedDay);
          callTimeLogApi();
        },
        headerStyle: const HeaderStyle(
          titleCentered: true, formatButtonVisible: false,
          titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.navyBlue),
          leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primary),
          rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primary),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 12),
          weekendStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 12),
        ),
        calendarBuilders: CalendarBuilders(
          selectedBuilder: (context, day, focusedDay) => Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.navyBlue, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: AppColors.navyBlue.withOpacity(0.3), blurRadius: 8)]),
            child: Center(child: CustomText('${day.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),
          todayBuilder: (context, day, focusedDay) => Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primary, width: 1)),
            child: Center(child: CustomText('${day.day}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
          ),
        ),
      ),
    );
  }

  Widget _buildEngineeringLogCard(TimeLogJob item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(context, MaterialPageRoute(builder: (_) => TimeSheetScreen(jobId: item.id.toString())));
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 56, width: 56,
                  decoration: BoxDecoration(
                    color: AppColors.navyBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.navyBlue.withOpacity(0.05)),
                  ),
                  child: Center(
                    child: CustomText(
                      item.jobName?.substring(0, 1).toUpperCase() ?? "J",
                      style: AppTextStyles.headline4.copyWith(color: AppColors.navyBlue, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        item.jobName ?? "Unnamed Job",
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.navyBlue),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 12, color: AppColors.primary.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          CustomText(
                            "${item.jobTime ?? "--:--"} - ${item.jobEndTime ?? "--:--"}",
                            style: AppTextStyles.bodyExtraSmall.copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)]),
            child: Icon(Icons.history_toggle_off_rounded, size: 48, color: Colors.grey.shade200),
          ),
          const SizedBox(height: 24),
          CustomText("No Work Log Records", style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          CustomText("No time logs found for the selected period.", style: AppTextStyles.bodyExtraSmall.copyWith(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  Widget _tabButton(String title, int index) {
    final active = selectedTab == title;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          if (selectedTab != title) {
            HapticFeedback.selectionClick();
            setState(() => selectedTab = title);
            callTimeLogApi();
          }
        },
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: AppTextStyles.button.copyWith(
              color: active ? Colors.white : Colors.black87,
              fontWeight: active ? FontWeight.w900 : FontWeight.w500,
              fontSize: 14,
            ),
            child: CustomText(title,txtColor:   active ? Colors.white : Colors.black87,style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),),

          ),
        ),
      ),
    );
  }
}
