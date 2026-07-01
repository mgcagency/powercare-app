import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:powercare_flutter/app/theme/colors.dart';

import '../../../app/theme/text_styles.dart';
import '../../../app/widget/custom_appbar.dart';
import '../../../app/widget/custom_text.dart';
import '../../../core/storage/app_preferences.dart';
import '../../../main.dart';
import '../../alldata/api_repository/TimeLogRepository.dart';
import '../../alldata/models/TimeLogResponse.dart';
import 'TimeSheetScreen.dart';
import 'package:table_calendar/table_calendar.dart';
class TimeLogScreen extends StatefulWidget {

  final bool showAppBar;

  const TimeLogScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<TimeLogScreen> createState() =>
      TimeLogScreenState();
}
/*class TimeLogScreen extends StatefulWidget {
  const TimeLogScreen({super.key});

  @override
  State<TimeLogScreen> createState() =>
      TimeLogScreenState();
}*/

class TimeLogScreenState
    extends State<TimeLogScreen> {


  final TimeLogRepository repository =
  TimeLogRepository();
  DateTime selectedWeekDate = DateTime.now();
  DateTime selectedDate =
  DateTime.now();
  List<DateTime> currentWeek = [];
  List<TimeLogJob> jobs = [];

  bool isLoading = false;

  String selectedTab = "DAY";

/*  List<dynamic> _getEventsForDay(DateTime day) {
    return jobs.where((job) {
      if (job.jobDate == null) return false;

      final jobDate = DateTime.parse(job.jobDate!);

      return isSameDay(jobDate, day);
    }).toList();
  }*/
  @override
  void initState() {
    super.initState();
    generateWeek();
    callTimeLogApi();
  }
  void generateWeek() {

    final now = DateTime.now();

    final startOfWeek =
    now.subtract(
      Duration(days: now.weekday % 7),
    );

    currentWeek = List.generate(
      7,
          (index) => startOfWeek.add(
        Duration(days: index),
      ),
    );
  }
  Future<void> callTimeLogApi() async {

    try {

      setState(() {
        isLoading = true;
      });

      final userId =
      await AppPreferences.getUserID();

      final response =
      await repository.getTimeLogs(

        date: DateFormat(
          "dd-MM-yyyy",
        ).format(
          DateTime.now(),
        ),

        engineerId: userId,

        dateKey: selectedTab,

        specificDate:
        selectedTab == "MONTH"
            ? DateFormat(
          "yyyy-MM-dd",
        ).format(
          selectedDate,
        )
            : selectedTab == "WEEK"
            ? DateFormat(
          "yyyy-MM-dd",
        ).format(
          selectedWeekDate,
        )
            : "",
      );

      print(
        "Total Jobs => ${response.jobs.length}",
      );

      setState(() {

        jobs = response.jobs;

        isLoading = false;
      });

    } catch (e) {

      print(
        "TimeLog Error => $e",
      );

      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: widget.showAppBar
          ? const CustomAppBar(
        title: "Time Logs",
      )
          : null,

      body: Column(

        children: [

          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {

                  final tabWidth =
                      constraints.maxWidth / 3;

                  return Stack(
                    children: [

                      AnimatedPositioned(
                        duration:
                        const Duration(
                          milliseconds: 350,
                        ),
                        curve:
                        Curves.easeOutCubic,

                        left:
                        selectedTab == "DAY"
                            ? 0
                            : selectedTab == "WEEK"
                            ? tabWidth
                            : tabWidth * 2,

                        top: 4,
                        bottom: 4,


                        child: Container(
                          width: tabWidth - 4,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                            BorderRadius.circular(
                              26,
                            ),
                          ),
                        ),
                      ),

                      Row(
                        children: [

                          _tabButton(
                            "DAY",
                            0,
                          ),

                          _tabButton(
                            "WEEK",
                            1,
                          ),

                          _tabButton(
                            "MONTH",
                            2,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
/*          Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [

              _tabButton("DAY"),

              const SizedBox(width: 10),

              _tabButton("WEEK"),

              const SizedBox(width: 10),

              _tabButton("MONTH"),
            ],
          ),*/

          const SizedBox(height: 15),

        if (selectedTab == "WEEK")
    Container(
      height: 90,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: currentWeek.length,
        itemBuilder: (_, index) {

          final day = currentWeek[index];

          final isSelected =
              DateFormat("yyyy-MM-dd").format(day) ==
                  DateFormat("yyyy-MM-dd").format(selectedWeekDate);

          return GestureDetector(
            onTap: () {

              setState(() {
                selectedWeekDate = day;
              });

              callTimeLogApi();
            },

            child: Container(
              width: 65,
              margin: const EdgeInsets.symmetric(horizontal: 4),

              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.navyBlue
                    : Colors.white,

                borderRadius: BorderRadius.circular(12),

                border: Border.all(
                  color: AppColors.navyBlue,
                ),
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  Text(
                    DateFormat("EEE").format(day),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    DateFormat("dd").format(day),
                    style: TextStyle(
                      fontSize: 18,
                      color: isSelected
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
          if (selectedTab == "MONTH")
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: selectedDate,

                selectedDayPredicate: (day) =>
                    isSameDay(selectedDate, day),
               // eventLoader: _getEventsForDay,
                onDaySelected: (selectedDay, focusedDay) {

                  setState(() {
                    selectedDate = selectedDay;
                  });

                  callTimeLogApi();
                },

                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Colors.orange,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Colors.orange,
                  ),
                ),

                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  weekendStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) return const SizedBox();

                    return Positioned(
                      bottom: 4,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.navyBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },

                  todayBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
               /* calendarStyle: CalendarStyle(

                  todayDecoration: BoxDecoration(
                    color: Colors.orange.shade300,
                    shape: BoxShape.circle,
                  ),

                  selectedDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),

                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),

                  todayTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),

                  outsideDaysVisible: false,

                  weekendTextStyle: const TextStyle(
                    color: Colors.red,
                  ),
                ),*/

              ),
            ),
/*
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: selectedDate,

                selectedDayPredicate: (day) {
                  return isSameDay(
                    selectedDate,
                    day,
                  );
                },

                onDaySelected: (
                    selectedDay,
                    focusedDay,
                    ) {

                  setState(() {
                    selectedDate = selectedDay;
                  });

                  callTimeLogApi();
                },

                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.deepOrangeAccent,
                    shape: BoxShape.circle,
                  ),

                  selectedDecoration: BoxDecoration(
                    color: AppColors.navyBlue,
                    shape: BoxShape.circle,
                  ),
                ),

                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
*/

          Expanded(

            child: isLoading

                ? const Center(
              child:
              CircularProgressIndicator(),
            )

                :       ListView.builder(

    itemCount: jobs.length,

    itemBuilder:
    (_, index) {
    final item =
    jobs[index];

    return Card(

    margin:
    const EdgeInsets.all(10),
    child: ListTile(

    leading: CircleAvatar(backgroundColor: AppColors.navyBlue,
    child: CustomText(
    item.jobName?.substring(0, 1) ?? "J",
    style: AppTextStyles.bodyMedium.copyWith(
    fontWeight: FontWeight.bold,
    color: AppColors.pureWhite,
    ),
    ),
    ),

    title: CustomText(
    item.jobName ?? "",
    style: AppTextStyles.bodyMedium.copyWith(
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
    ),
    ),

    subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

    const SizedBox(height: 4),

    CustomText(
    "Start Time : ${item.jobTime ?? "-"}",
    style: AppTextStyles.bodySmall.copyWith(
    color: AppColors.textColor,
    ),
    ),

    const SizedBox(height: 2),

    CustomText(
    "End Time : ${item.jobEndTime ?? "-"}",
    style: AppTextStyles.bodySmall.copyWith(
    color: AppColors.textColor,
    ),
    ),
    ],
    ),

    onTap: () {

    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (_) => TimeSheetScreen(
    jobId: item.id.toString(),
    ),
    ),
    );
    },
    ),
    );
    }
    )
/*
            ListView.builder(

              itemCount: jobs.length,

              itemBuilder:
                  (_, index) {
                final item =
                jobs[index];

                return Card(

                  margin:
                  const EdgeInsets.all(10),

                  child: ListTile(

                    leading:
                    CircleAvatar(
                      child: Text(
                        item.jobName
                            ?.substring(0, 1) ??
                            "J",
                      ),
                    ),

                    title: Text(
                      item.jobName ?? "",
                    ),

                 */
/*   subtitle: Text(
                      "${item.jobTime ?? ""} - ${item.jobEndTime ?? ""}",
                    ),*//*

                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Start Time : ${item.jobTime ?? "-"}",
                        ),

                        Text(
                          "End Time : ${item.jobEndTime ?? "-"}",
                        ),
                      ],
                    ),
                    onTap: () {
                      print(
                        item.id,
                      );
                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              TimeSheetScreen(
                                jobId:
                                item.id.toString(),
                              ),
                        ),
                      );
                      // Open TimeSheetScreen
                    },
                  ),
                );
              },
            ),
*/
          ),
        ],
      ),
    );
  }
  Widget _tabButton(
      String title,
      int index,
      ) {

    final active =
        selectedTab == title;

    return Expanded(
      child: InkWell(

        borderRadius:
        BorderRadius.circular(
          30,
        ),

        onTap: () {

          setState(() {
            selectedTab = title;
          });

          callTimeLogApi();
        },

        child: Center(
          child:
          AnimatedDefaultTextStyle(
            duration:
            const Duration(
              milliseconds: 250,
            ),

            style: TextStyle(
              color: active
                  ? Colors.white
                  : Colors.black87,

              fontWeight:
              active
                  ? FontWeight.w700
                  : FontWeight.w500,

              fontSize: 15,
            ),

            child: Text(title),
          ),
        ),
      ),
    );
  }
/*  Widget _tabButton(
      String title) {

    return GestureDetector(

      onTap: () {

        setState(() {

          selectedTab =
              title;
        });

        callTimeLogApi();
      },

      child: Container(

        padding:
        const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),

        decoration: BoxDecoration(

          color:
          selectedTab == title
              ? Colors.orange
              : Colors.grey.shade300,

          borderRadius:
          BorderRadius.circular(
            25,
          ),
        ),

        child: Text(
          title,
          style: TextStyle(
            color:
            selectedTab == title
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
  }*/
}
