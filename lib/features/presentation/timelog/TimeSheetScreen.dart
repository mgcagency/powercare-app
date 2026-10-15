import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:powercare_flutter/app/widget/custom_response_dialogs.dart';
import 'package:powercare_flutter/core/navigation/app_navigator.dart';
import 'package:powercare_flutter/features/alldata/models/UserModel.dart';
import 'package:powercare_flutter/features/alldata/models/job_list_response.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/widget/custom_appbar.dart';
import '../../../app/widget/custom_button.dart';
import '../../../app/widget/custom_text.dart';
import '../../../app/widget/custom_textfield.dart';
import '../../../core/storage/app_preferences.dart';
import '../../alldata/api_repository/TimeSheetRepository.dart';
import '../../alldata/api_repository/job_repository.dart';
import '../jobs/job_list_screen.dart';

class TimeSheetScreen extends StatefulWidget {
  final String jobId;
  const TimeSheetScreen({super.key, required this.jobId});

  @override
  State<TimeSheetScreen> createState() => _TimeSheetScreenState();
}

class _TimeSheetScreenState extends State<TimeSheetScreen> {
  final TimeSheetRepository repository = TimeSheetRepository();
  final TextEditingController leadEngineerController = TextEditingController();
  bool isLoading = false;
  String jobName = "";
  late JobModel detailJob;
  List<UserModel> users = [];
  String? _currentUserId; // Add this


  // Logic: Holds list of engineers, each containing a list of time slots
  List<Map<String, dynamic>> engineers = [];

  @override
  void initState() {
    super.initState();
    _initialFetch();
  }
  Future<void> _initialFetch() async {
    setState(() => isLoading = true);
    await Future.wait([
      loadUsers(),
      callJobDetails(),
      _loadCurrentUserId()
    ]);
    setState(() => isLoading = false);
  }
  Future<void> _loadCurrentUserId() async {
    final id = await AppPreferences.getUserID();
    setState(() {
      _currentUserId = id;
    });
  }
  Future<void> loadUsers() async {
    try {
      users = await repository.getUsers();
      setState(() {});
    } catch (e) {
      debugPrint("User Error => $e");
    }
  }


  Future<void> callJobDetails() async {
    try {
      final response = await JobRepository().getJobDetails(
        widget.jobId.toString(),
      );

       detailJob = response.jobDetails!;




      setState(() {
        jobName = detailJob.jobName ?? "";

        engineers.clear();
        // inside callJobDetails() ...

        if (detailJob.leadEngineer != null) {
          leadEngineerController.text = detailJob.leadEngineer!.fullName;

          // 1. Map existing timesheets if available, otherwise start with one empty slot
          List<Map<String, dynamic>> leadTimeSlots = [];

          if (detailJob.leadEngineer!.timesheet != null &&
              detailJob.leadEngineer!.timesheet!.isNotEmpty) {
            for (var ts in detailJob.leadEngineer!.timesheet!) {
              leadTimeSlots.add({
                "date": DateTime.parse(ts.createdAt ?? ""),
                "id": ts.id.toString(),
                "isDeletable": false,
                "startTime": ts.startTime ?? "",
                "endTime": ts.endTime ?? "",
                "total": calculateTotal(ts.startTime ?? "", ts.endTime ?? ""),
              });
            }
          }
        }
        if (detailJob.otherEngineers != null) {
          for (final other in detailJob.otherEngineers!) {
            if (other.user != null) {
              // 2. Map existing timesheets for other engineers
              List<Map<String, dynamic>> otherTimeSlots = [];

              if (other.user!.timesheet != null &&
                  other.user!.timesheet!.isNotEmpty) {
                for (var ts in other.user!.timesheet!) {
                  otherTimeSlots.add({
                    "date": DateTime.parse(ts.createdAt ?? ""),
                    "id": ts.id.toString(),
                    "isDeletable": false,
                    "startTime": ts.startTime ?? "",
                    "endTime": ts.endTime ?? "",
                    "total": calculateTotal(
                      ts.startTime ?? "",
                      ts.endTime ?? "",
                    ),
                  });
                }


                engineers.add({
                  "isDeletable": false,
                  "name": other.user!.fullName,
                  "userId": other.user!.id.toString(),
                  "isLead": false,
                  "timeSlots": otherTimeSlots,
                });
              }
            }
          }
        }
      }
        );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void addEngineerBlock() {
    setState(() {
      engineers.add({
        "name": "",
        "userId": "",
        "isLead": false,
        "isEditable": true,
        "timeSlots": [
          {"date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
            "isDeletable": true,
            "startTime": "", "endTime": ""}
        ],
      });
    });
  }

  void addTimeSlot(int engIdx) {
    setState(() {
      engineers[engIdx]["timeSlots"].add({
        "isDeletable": true,
        "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "startTime": "",
        "endTime": ""
      });
    });
  }

  Future<void> _pickTime(int engIdx, int slotIdx, String key) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        final timeStr = "${picked.hour.toString().padLeft(2, "0")}:${picked.minute.toString().padLeft(2, "0")}";
        engineers[engIdx]["timeSlots"][slotIdx][key] = timeStr;
      });
    }
  }

  String calculateTotal(String start, String end) {
    if (start.isEmpty || end.isEmpty) return "00:00";
    try {
      final s = start.split(":");
      final e = end.split(":");
      int diff = (int.parse(e[0]) * 60 + int.parse(e[1])) - (int.parse(s[0]) * 60 + int.parse(s[1]));
      if (diff < 0) return "00:00";
      return "${(diff ~/ 60).toString().padLeft(2, "0")}:${(diff % 60).toString().padLeft(2, "0")}";
    } catch (_) { return "00:00"; }
  }

  String calculateGrandTotal() {
    int totalMinutes = 0;
    for (var eng in engineers) {
      for (var slot in eng["timeSlots"]) {
        String start = slot["startTime"];
        String end = slot["endTime"];
        if (start.isNotEmpty && end.isNotEmpty) {
          final s = start.split(":");
          final e = end.split(":");
          int diff = (int.parse(e[0]) * 60 + int.parse(e[1])) - (int.parse(s[0]) * 60 + int.parse(s[1]));
          if (diff > 0) totalMinutes += diff;
        }
      }
    }
    return "${(totalMinutes ~/ 60).toString().padLeft(2, '0')}:${(totalMinutes % 60).toString().padLeft(2, '0')} hrs";
  }

  Future<void> saveTimeSheet() async {
    try {
      setState(() => isLoading = true);
      Map<String, dynamic> payload = {"job_id": widget.jobId};
      int apiIndex = 0;

      for (var engineer in engineers) {
        if (engineer["userId"].toString().isEmpty) continue;
        for (var slot in engineer["timeSlots"]) {
          if (slot["startTime"].isNotEmpty && slot["endTime"].isNotEmpty) {
            payload["engineer_id[$apiIndex]"] = engineer["userId"];
                       payload["time_sheet_id[$apiIndex]"] = slot["id"];

            payload["start_time[$apiIndex]"] = slot["startTime"];
            payload["end_time[$apiIndex]"] = slot["endTime"];
            apiIndex++;
          }
        }
      }

      if (apiIndex == 0) {
showErrorDialog(context, "Please add at least one complete time log");
setState(() => isLoading = false);
        return;
      }

      final response = await repository.addTimeSheet(payload);
      if (response["success"] == true) {
        showSuccessDialog(context, "Timesheet saved successfully",onOk: (){AppNavigator.pop();   });

      }
    } catch (e) {
      debugPrint("Save Error => $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: "Time Sheet Entry"),
      body: isLoading && engineers.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          :Column(
        children: [
          _buildGrandTotalHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: engineers.length,
                    itemBuilder: (context, engIdx) => _buildEngineerSection(engIdx),
                  ),
                  // const SizedBox(height: 20),
                  // _buildAddEngineerButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomActions(),
    );
  }

  Widget _buildGrandTotalHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CustomText("Total Project Hours", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          CustomText(calculateGrandTotal(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildEngineerSection(int engIdx) {
    final engineer = engineers[engIdx];
    final bool isLead = engineer["isLead"] == true;
    final bool isEditable = engineer["isEditable"] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isLead ? Colors.blue.shade50 : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(isLead ? Icons.stars : Icons.person, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomText(
                    isLead ? "Lead Engineer" : "Additional Engineer",
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (!isEditable)
                  CustomTextField(
                    controller: TextEditingController(text: engineer["name"]),
                    label: "Engineer Name",
                    readOnly: true,
                  )
                else
                  _buildEngineerPicker(engIdx),

                const SizedBox(height: 16),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: engineer["timeSlots"].length,
                  itemBuilder: (context, slotIdx) => _buildTimeSlotRow(engIdx, slotIdx),
                ),
                // if(_currentUserId == detailJob?.leadEngineer?.id.toString())
                //
                // const Divider(),
                // if(_currentUserId == detailJob?.leadEngineer?.id.toString())
                //
                //   TextButton.icon(
                //   onPressed: () {
                //
                //     addTimeSlot(engIdx);},
                //   icon: const Icon(Icons.add_alarm, size: 18),
                //   label: const CustomText("Add Shift/Slot"),
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotRow(int engIdx, int slotIdx) {
    final slot = engineers[engIdx]["timeSlots"][slotIdx];

    // 1. Extract the current date string (part before the space)
    String? currentDate = slot["date"]?.toString().split(" ")[0];

    // 2. Extract the previous date string if slotIdx > 0
    String? prevDate = slotIdx > 0
        ? engineers[engIdx]["timeSlots"][slotIdx - 1]["date"]?.toString().split(" ")[0]
        : null;

    // 3. Determine if we should show the date header
    // Show if it's the first item OR if the date has changed from the previous row
    bool showDateHeader = currentDate != null && currentDate != prevDate;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                child: CustomText(
                    currentDate!,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold,color: AppColors.navyBlue)
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: _timeField(
                    "In",
                    slot["startTime"],
                    !(slot["isDeletable"]??false)
                        ? null
                        : () => _pickTime(engIdx, slotIdx, "startTime"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _timeField(
                    "Out",
                    slot["endTime"],
                    !(slot["isDeletable"]??false)
                        ? null
                        : () => _pickTime(engIdx, slotIdx, "endTime"),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomText(
                    calculateTotal(slot["startTime"], slot["endTime"]),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (slot["isDeletable"] &&  _currentUserId == detailJob?.leadEngineer?.id.toString())
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                    onPressed: () => setState(
                          () => engineers[engIdx]["timeSlots"].removeAt(slotIdx),
                    ),
                  ),
              ],
            )]),
    );
  }

  Widget _timeField(String label, String value, VoidCallback? onTap) {
    return InkWell(
      onTap:

          _currentUserId != detailJob?.leadEngineer?.id.toString()
          ? null
          : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            CustomText(
              value.isEmpty ? "--:--" : value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddEngineerButton() {
    return InkWell(
      onTap: () => addEngineerBlock(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primary.withOpacity(0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            CustomText("Add Additional Engineer", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineerPicker(int engIdx) {
    final engineer = engineers[engIdx];
    return GestureDetector(
      onTap: () => showEngineerBottomSheet(engineer),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.person_search_rounded, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: CustomText(
                engineer["name"].isEmpty ? "Select Engineer" : engineer["name"],
                style: AppTextStyles.bodyMedium.copyWith(color: engineer["name"].isEmpty ? Colors.grey : Colors.black87),
              ),
            ),
            const Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          Expanded(child: CustomButton(title: "Cancel", background: Colors.grey.shade200, textClr: Colors.black87, onPressed: () => Navigator.pop(context))),
          const SizedBox(width: 15),
         // Expanded(flex: 2, child: CustomButton(title: "Ok", isLoading: isLoading, onPressed: () => AppNavigator.pop())),
          Expanded(
            flex: 2,
            child: CustomButton(
              title: "Ok",
              isLoading: isLoading,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Time Sheet Added successfully"),
                    duration: Duration(seconds: 2),
                  ),
                );

                AppNavigator.pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  void showEngineerBottomSheet(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            const CustomText("Select Engineer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (_, index) {
                  final user = users[index];
                  return ListTile(
                    title: CustomText(user.fullName),
                    onTap: () {
                      setState(() {
                        item["userId"] = user.id.toString();
                        item["name"] = user.fullName;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}