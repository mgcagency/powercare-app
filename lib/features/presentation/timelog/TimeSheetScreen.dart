import 'package:flutter/material.dart';
import 'package:powercare_flutter/features/alldata/models/UserModel.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/widget/custom_appbar.dart';
import '../../../app/widget/custom_button.dart';
import '../../../app/widget/custom_text.dart';
import '../../../app/widget/custom_textfield.dart';
import '../../alldata/api_repository/TimeSheetRepository.dart';
import '../../alldata/api_repository/job_repository.dart';

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
  List<UserModel> users = [];

  // Important: Changed to List<Map> to hold UI state (time slots)
  List<Map<String, dynamic>> engineers = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
    callJobDetails();
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
      final response = await JobRepository().getJobDetails(widget.jobId);
      final job = response.jobDetails;

      if (job != null) {
        setState(() {
          jobName = job.jobName ?? "";
          engineers.clear();

          // 1. Map Lead Engineer from API
          if (job.leadEngineer != null) {
            leadEngineerController.text = job.leadEngineer!.fullName;
            engineers.add({
              "name": job.leadEngineer!.fullName,
              "userId": job.leadEngineer!.id.toString(),
              "isLead": true,
              "timeSlots": [
                {"startTime": "", "endTime": "", "total": "00:00"}
              ],
            });
          }

          // 2. Map Other Engineers from API
          if (job.otherEngineers != null) {
            for (var other in job.otherEngineers!) {
              if (other.user != null) {
                engineers.add({
                  "name": other.user!.fullName,
                  "userId": other.user!.id.toString(),
                  "isLead": false,
                  "timeSlots": [
                    {"startTime": "", "endTime": "", "total": "00:00"}
                  ],
                });
              }
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Job Details Error => $e");
    }
  }

  void addEngineerBlock() {
    setState(() {
      engineers.add({
        "name": "",
        "userId": "",
        "isLead": false,
        "timeSlots": [
          {"startTime": "", "endTime": "", "total": "00:00"}
        ],
      });
    });
  }

  void addTimeSlot(int engineerIndex) {
    setState(() {
      engineers[engineerIndex]["timeSlots"].add({
        "startTime": "",
        "endTime": "",
        "total": "00:00"
      });
    });
  }

  Future<void> _pickTime(int engIdx, int slotIdx, String key) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        final timeStr = "${picked.hour.toString().padLeft(2, "0")}:${picked.minute.toString().padLeft(2, "0")}";
        engineers[engIdx]["timeSlots"][slotIdx][key] = timeStr;
      });
    }
  }

  String calculateTotal(String start, String end) {
    if (start.isEmpty || end.isEmpty) return "00:00";
    int minutes = _getMinutes(start, end);
    final hrs = minutes ~/ 60;
    final mins = minutes % 60;
    return "${hrs.toString().padLeft(2, "0")}:${mins.toString().padLeft(2, "0")}";
  }

  int _getMinutes(String start, String end) {
    if (start.isEmpty || end.isEmpty) return 0;
    try {
      final s = start.split(":");
      final e = end.split(":");
      int diff = (int.parse(e[0]) * 60 + int.parse(e[1])) - (int.parse(s[0]) * 60 + int.parse(s[1]));
      return diff > 0 ? diff : 0;
    } catch (e) {
      return 0;
    }
  }

  String calculateGrandTotal() {
    int totalMinutes = 0;
    for (var eng in engineers) {
      for (var slot in eng["timeSlots"]) {
        totalMinutes += _getMinutes(slot["startTime"], slot["endTime"]);
      }
    }
    final hrs = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    return "${hrs.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')} hrs";
  }

  Future<void> saveTimeSheet() async {
    try {
      setState(() => isLoading = true);
      Map<String, dynamic> payload = {"job_id": widget.jobId};
      int apiIndex = 0;

      for (var engineer in engineers) {
        for (var slot in engineer["timeSlots"]) {
          if (slot["startTime"].isNotEmpty && slot["endTime"].isNotEmpty) {
            payload["engineer_id[$apiIndex]"] = engineer["userId"];
            payload["start_time[$apiIndex]"] = slot["startTime"];
            payload["end_time[$apiIndex]"] = slot["endTime"];
            apiIndex++;
          }
        }
      }

      if (apiIndex == 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add at least one time log")));
        setState(() => isLoading = false);
        return;
      }

      final response = await repository.addTimeSheet(payload);
      if (response["success"] == true) {
        Navigator.pop(context);
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
      body: Column(
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
                  const SizedBox(height: 20),
                  _buildAddEngineerButton(),
                  const SizedBox(height: 100),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          // --- SECTION HEADER ---
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
                // Only show delete button for non-lead engineers
                if (!isLead)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => setState(() => engineers.removeAt(engIdx)),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // --- SELECTION LOGIC ---
                if (isLead)
                // Lead is READ ONLY
                  CustomTextField(
                    controller: TextEditingController(text: engineer["name"]),
                    label: "Engineer Name",
                    readOnly: true,
                    // fillColor: Colors.grey.shade100,
                  )
                else
                // Added engineers get the BottomSheet Dropdown
                  _buildEngineerPicker(engIdx),

                const SizedBox(height: 16),

                // --- TIME SLOTS ---
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: engineer["timeSlots"].length,
                  itemBuilder: (context, slotIdx) => _buildTimeSlotRow(engIdx, slotIdx),
                ),

                const Divider(),
                TextButton.icon(
                  onPressed: () => addTimeSlot(engIdx),
                  icon: const Icon(Icons.add_alarm, size: 18),
                  label: const Text("Add Shift/Slot"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotRow(int engIdx, int slotIdx) {
    final slot = engineers[engIdx]["timeSlots"][slotIdx];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: _timeField("In", slot["startTime"], () => _pickTime(engIdx, slotIdx, "startTime"))),
          const SizedBox(width: 8),
          Expanded(child: _timeField("Out", slot["endTime"], () => _pickTime(engIdx, slotIdx, "endTime"))),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            child: CustomText(calculateTotal(slot["startTime"], slot["endTime"]), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          if (engineers[engIdx]["timeSlots"].length > 1)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
              onPressed: () => setState(() => engineers[engIdx]["timeSlots"].removeAt(slotIdx)),
            )
        ],
      ),
    );
  }

  Widget _timeField(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            CustomText(value.isEmpty ? "--:--" : value, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                engineer["name"].isEmpty ? "Select Engineer from List" : engineer["name"],
                style: AppTextStyles.bodyMedium.copyWith(
                  color: engineer["name"].isEmpty ? Colors.grey : Colors.black87,
                ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child:
      Row(
        children: [
          Flexible(
            flex: 1,
            child: CustomButton(
              title: "Cancel",textClr: Colors.black,
              background: Colors.grey.shade200,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 2,
            child: CustomButton(
              title: "Submit Timesheet",
              isLoading: isLoading,
              onPressed: () => saveTimeSheet(),
            ),
          ),
        ],
      ),
      /*Row(
        children: [
          Expanded(child: CustomButton(title: "Cancel", background: Colors.grey.shade200, onPressed: () => Navigator.pop(context))),
          const SizedBox(width: 15),
          Expanded(flex: 2, child: CustomButton(title: "Submit Timesheet", isLoading: isLoading, onPressed: () => saveTimeSheet())),
        ],
      ),*/
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
            const Text("Select Engineer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (_, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text(user.fullName),
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