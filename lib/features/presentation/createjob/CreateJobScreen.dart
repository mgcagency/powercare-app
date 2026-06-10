import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/widget/custom_button.dart';

import '../../../app/theme/text_styles.dart';
import '../../../app/widget/custom_appbar.dart';
import '../../../app/widget/custom_dropdown.dart';
import '../../../app/widget/custom_text.dart';
import '../../../app/widget/custom_textfield.dart';
import '../../alldata/api_repository/create_job_repository.dart';
import '../../alldata/models/JobStatusModel.dart';
import '../../alldata/models/UserModel.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  String _orderDate = "16/03/2026";
  List<UserModel> users = [];

  List<JobStatusModel> jobStatusList = [];

  UserModel? selectedLeadEngineer;

  JobStatusModel? selectedStatus;

  List<UserModel> selectedOtherEngineers = [];
  final CreateJobRepository repository = CreateJobRepository();

  final jobNumberController = TextEditingController();

  final jobNameController = TextEditingController();

  final emailController = TextEditingController();

  final customerPoController = TextEditingController();

  final mobileController = TextEditingController();

  final locationController = TextEditingController();

  final cityController = TextEditingController();

  final descriptionController = TextEditingController();

  final moreInfoController = TextEditingController();

  String selectedDate = "";
  String selectedTime = "";

  @override
  void initState() {
    super.initState();

    selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    selectedTime = DateFormat('HH:mm').format(DateTime.now());

    // TODO
    getJobNumber();
    getUsers();
    getJobStatus();
  }

  Future<void> showOtherEngineerDialog() async {
    List<UserModel> tempList = List.from(selectedOtherEngineers);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Engineers"),

              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];

                    return CheckboxListTile(
                      value: tempList.any((e) => e.id == user.id),

                      title: Text("${user.firstName} ${user.lastName}"),

                      onChanged: (value) {
                        setDialogState(() {
                          if (value == true) {
                            tempList.add(user);
                          } else {
                            tempList.removeWhere((e) => e.id == user.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedOtherEngineers = tempList;
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> getJobNumber() async {
    try {
      final response = await repository.getJobNumber();

      print("Job Number => ${response.data}");

      setState(() {
        jobNumberController.text = response.data["job_number"].toString();
      });
    } catch (e) {
      print("Job Number Error => $e");
    }
  }

  Future<void> getUsers() async {
    try {
      final response = await repository.getUsers();

      print("Users => ${response.data}");

      final list = response.data["user"];

      users = list.map<UserModel>((e) => UserModel.fromJson(e)).toList();

      setState(() {});
    } catch (e) {
      print("Users Error => $e");
    }
  }

  Future<void> getJobStatus() async {
    try {
      final response = await repository.getJobStatus();

      print("Status => ${response.data}");

      final list = response.data["jobTypeStatusLists"];
      jobStatusList = list
          .map<JobStatusModel>((e) => JobStatusModel.fromJson(e))
          .toList();

      setState(() {});
    } catch (e) {
      print("Status Error => $e");
    }
  }

  Future<void> createJob() async {
    Map<String, dynamic> body = {
      "job_number": jobNumberController.text,

      "job_name": jobNameController.text,

      "email": emailController.text,

      "lead_engineer_id": selectedLeadEngineer?.id,

      "job_status": selectedStatus?.id,

      "customer_po_number": customerPoController.text,

      "job_location": locationController.text,

      "mobile_no": mobileController.text,

      "city": cityController.text,

      "state": "",

      "job_date": selectedDate,

      "job_time": selectedTime,

      "job_description": descriptionController.text,

      "more_information": moreInfoController.text,
    };

    for (int i = 0; i < selectedOtherEngineers.length; i++) {
      body["other_engineers_id[$i]"] = selectedOtherEngineers[i].id.toString();
    }

    await repository.createJob(body);
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(date);
      });
    }
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime =
            "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: const CustomAppBar(title: "Create Job"),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            CustomTextField(
              controller: jobNumberController,
              hintText: "Job Number",
              label: "Job Number",

              // readOnly: true,
            ),

            const SizedBox(height: 12),

            CustomTextField(
              controller: jobNameController,
              hintText: "Job Name",
              label: "Job Name",
            ),

            const SizedBox(height: 12),

            CustomTextField(
              controller: emailController,
              hintText: "Email",
              label: "Email",
            ),

            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Lead Engineer",
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 8),

            CustomDropdown<UserModel>(
              value: selectedLeadEngineer,
              hint: "Select Lead Engineer",
              items: users.map((user) {
                return DropdownMenuItem<UserModel>(
                  value: user,
                  child: Text(
                    "${user.firstName ?? ""} ${user.lastName ?? ""}",
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLeadEngineer = value;
                });
              },
            ),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Job Status",
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),

            CustomDropdown<JobStatusModel>(
              value: selectedStatus,
              hint: "Select Job Status",
              items: jobStatusList.map((status) {
                return DropdownMenuItem<JobStatusModel>(
                  value: status,
                  child: Text(
                    status.status ?? "",
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value;
                });
              },
            ),
            const SizedBox(height: 12),

            CustomTextField(
              controller: customerPoController,
              hintText: "Customer PO Number",
              label: "Customer PO Number",
            ),

            const SizedBox(height: 12),

            CustomTextField(
              controller: mobileController,
              hintText: "Mobile Number",
              label: "Mobile Number",
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: showOtherEngineerDialog,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedOtherEngineers.isEmpty
                            ? "Select Other Engineers"
                            : "${selectedOtherEngineers.length} Engineers Selected",
                      ),
                    ),

                    Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedOtherEngineers.map((user) {
                return Chip(
                  backgroundColor: Colors.orange.shade50,

                  label: Text("${user.firstName} ${user.lastName}"),

                  deleteIcon: const Icon(Icons.close, size: 18),

                  onDeleted: () {
                    setState(() {
                      selectedOtherEngineers.remove(user);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            CustomTextField(
              controller: locationController,
              hintText: "Job Location",
              label: "Job Location",
            ),

            const SizedBox(height: 12),

            CustomTextField(
              controller: cityController,
              hintText: "City",
              label: "City",
            ),

            const SizedBox(height: 12),
            _buildLabel("job date"),
            _buildDatePickerField(selectedDate, (date) {
              setState(() {
                selectedDate = date;
              });
            }),

            /*         ListTile(
              title: Text(
                selectedDate,
              ),
              trailing:
              const Icon(
                Icons.calendar_today,
              ),
              onTap: pickDate,
            ),*/
            const SizedBox(height: 12),

            _buildLabel("job time"),
            _buildTimePickerField(selectedTime, (time) {
              setState(() {
                selectedTime = time;
              });
            }),

            /*         ListTile(
              title: Text(
                selectedTime,
              ),
              trailing:
              const Icon(
                Icons.access_time,
              ),
              onTap: pickTime,
            ),*/
            const SizedBox(height: 12),

            CustomTextField(
              controller: descriptionController,
              maxLines: 4,
              label: "Description",
            ),

            const SizedBox(height: 12),

            CustomTextField(
              controller: moreInfoController,
              maxLines: 4,
              label: "More Information",
            ),

            const SizedBox(height: 25),
            Row(
              children: [
                const SizedBox(width: 25),

                CustomButton(
                  title: "Cancel",
                  background: AppColors.darkGrey,
                  onPressed: () {
                    // Handle Save Logic
                  },
                ),

                const SizedBox(width: 25),

                CustomButton(
                  title: "Create Job",
                  onPressed: () {
                    // Handle Save Logic
                  },
                ),
                const SizedBox(width: 25),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Row(
        children: [
          CustomText(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isRequired)
            CustomText(
              " *",
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(String value, Function(String) onDateSelected) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: CustomText(value, style: AppTextStyles.bodySmall),
            ),
          ),
          GestureDetector(
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                onDateSelected("${picked.day}/${picked.month}/${picked.year}");
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
              ),
              child: const Icon(
                Icons.calendar_month,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerField(String value, Function(String) onTimeSelected) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: CustomText(value, style: AppTextStyles.bodySmall),
            ),
          ),

          GestureDetector(
            onTap: () async {
              TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );

              if (picked != null) {
                final formattedTime = picked.format(context);

                onTimeSelected(formattedTime);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
              ),
              child: const Icon(
                Icons.access_time,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
