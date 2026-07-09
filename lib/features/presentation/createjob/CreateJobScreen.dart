import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/widget/custom_button.dart';
import 'package:powercare_flutter/app/widget/custom_outline_button.dart';

import '../../../app/theme/text_styles.dart';
import '../../../app/widget/custom_appbar.dart';
import '../../../app/widget/custom_dropdown.dart';
import '../../../app/widget/custom_text.dart';
import '../../../app/widget/custom_textfield.dart';
import '../../alldata/api_repository/create_job_repository.dart';
import '../../alldata/models/JobStatusModel.dart';
import '../../alldata/models/UserModel.dart';
import '../jobs/job_list_screen.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  bool isValidEmail(String email) {
    return RegExp(
      r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);
  }
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
  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomText(message),
      ),
    );
  }
  Future<void> showOtherEngineerDialog() async {
    List<UserModel> tempList = List.from(selectedOtherEngineers);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const CustomText("Select Engineers"),

              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];

                    return CheckboxListTile(
                      value: tempList.any((e) => e.id == user.id),

                      title: CustomText("${user.firstName} ${user.lastName}"),

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
                  child: const CustomText("Cancel"),
                ),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedOtherEngineers = tempList;
                    });

                    Navigator.pop(context);
                  },
                  child: const CustomText("OK"),
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

/*
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
*/
/*
  Future<void> createJob() async {
    try {

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
        body["other_engineers_id[$i]"] =
            selectedOtherEngineers[i].id.toString();
      }

      final response =
      await repository.createJob(body);

      print("STATUS => ${response.statusCode}");
      print("DATA => ${response.data}");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        showToast("Job Created Successfully");

        Navigator.pop(context);

      } else {

        showToast("Failed to create job");
      }

    } catch (e, s) {

      print("CREATE JOB ERROR => $e");
      print("STACK => $s");

      showToast(e.toString());
    }
  }
*/
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
      body["other_engineers_id[$i]"] =
          selectedOtherEngineers[i].id.toString();
    }

    try {

      final response =
      await repository.createJob(body);

      print("STATUS => ${response.statusCode}");

      print("DATA => ${response.data}");

      print("TYPE => ${response.data.runtimeType}");

    } catch (e, s) {

      print("ERROR => $e");

      print("STACK => $s");
    }
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
backgroundColor: AppColors.pureWhite,
      appBar: const CustomAppBar(title: "Create Job"),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            _buildLabel("Job Number", isRequired: true),

            CustomTextField(
              controller: jobNumberController,
              hintText: "Job Number",

              // readOnly: true,
            ),

            const SizedBox(height: 12),
            _buildLabel("Job Name", isRequired: true),

            CustomTextField(
              controller: jobNameController,
              hintText: "Job Name",
            ),

            const SizedBox(height: 12),
            _buildLabel("Email", isRequired: true),

            CustomTextField(
              controller: emailController,
              hintText: "Email",
            ),

            const SizedBox(height: 12),
            _buildLabel("Lead Engineer", isRequired: true),

      /*      Align(
              alignment: Alignment.centerLeft,
              child: CustomText(
                "Lead Engineer",
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),*/

            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                showLeadEngineerBottomSheet();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [

                    Expanded(
                      child: CustomText(
                        selectedLeadEngineer == null
                            ? "Select Lead Engineer"
                            : "${selectedLeadEngineer!.firstName ?? ""} ${selectedLeadEngineer!.lastName ?? ""}",
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),

                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
 /*           CustomDropdown<UserModel>(
              value: selectedLeadEngineer,
              hint: "Select Lead Engineer",
              items: users.map((user) {
                return DropdownMenuItem<UserModel>(
                  value: user,
                  child: CustomText(
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
            ),*/
            const SizedBox(height: 12),
            _buildLabel("Job Status", isRequired: true),

       /*     Align(
              alignment: Alignment.centerLeft,
              child: CustomText(
                "Job Status",
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),*/
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                showStatusBottomSheet();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [

                    Expanded(
                      child: CustomText(
                        selectedStatus?.status ??
                            "Select Job Status",
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),

                    const Icon(
                      Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ),
            ),
/*            CustomDropdown<JobStatusModel>(
              value: selectedStatus,
              hint: "Select Job Status",
              items: jobStatusList.map((status) {
                return DropdownMenuItem<JobStatusModel>(
                  value: status,
                  child: CustomText(
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
            ),*/
            const SizedBox(height: 12),
            _buildLabel("Customer PO Number", isRequired: true),

            CustomTextField(
              controller: customerPoController,
              hintText: "Customer PO Number",
            ),

            const SizedBox(height: 12),
            _buildLabel("Mobile Number", isRequired: true),

            CustomTextField(
              controller: mobileController,
              hintText: "Mobile Number",
            ),

            const SizedBox(height: 12),
            _buildLabel("Select Other Engineers", isRequired: true),

            GestureDetector(
              onTap: showOtherEngineerBottomSheet,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Row(
                  children: [

                    Expanded(
                      child: CustomText(
                        selectedOtherEngineers.isEmpty
                            ? "Select Other Engineers"
                            : "${selectedOtherEngineers.length} Engineers Selected",
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),

                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        /*    GestureDetector(
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
                      child: CustomText(
                        selectedOtherEngineers.isEmpty
                            ? "Select Other Engineers"
                            : "${selectedOtherEngineers.length} Engineers Selected",
                      ),
                    ),

                    Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                  ],
                ),
              ),
            ),*/

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedOtherEngineers.map((user) {
                return Chip(
                  backgroundColor: Colors.orange.shade50,

                  label: CustomText("${user.firstName} ${user.lastName}"),

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
            _buildLabel("Job Location", isRequired: true),

            CustomTextField(
              controller: locationController,
              hintText: "Job Location",
            ),

            const SizedBox(height: 12),
            _buildLabel("City", isRequired: true),

            CustomTextField(
              controller: cityController,
              hintText: "City",
            ),

            const SizedBox(height: 12),
            _buildLabel("job date"),
            _buildDatePickerField(selectedDate, (date) {
              setState(() {
                selectedDate = date;
              });
            }),

            /*         ListTile(
              title: CustomText(
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
              title: CustomText(
                selectedTime,
              ),
              trailing:
              const Icon(
                Icons.access_time,
              ),
              onTap: pickTime,
            ),*/
            const SizedBox(height: 12),
            _buildLabel("Description", isRequired: true),

            CustomTextField(
              controller: descriptionController,
              maxLines: 4,hintText:"Description" ,
            ),

            const SizedBox(height: 12),
            _buildLabel("More Information", isRequired: true),

            CustomTextField(
              controller: moreInfoController,
              maxLines: 4,hintText: "More Information",
            ),

            const SizedBox(height: 25),
            Row(
              children: [
                const SizedBox(width: 25),
                Expanded(
                  child: CustomOutlineButton(
                    title: "Cancel",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                const SizedBox(width: 25),

                CustomButton(
                  title: "Create Job",
                  onPressed: () async {

                    bool callApi = true;

                    if (jobNameController.text.trim().isEmpty) {
                      showToast("Please enter Job Name");
                      callApi = false;
                    }

                    if (emailController.text.trim().isEmpty ||
                        !isValidEmail(emailController.text.trim())) {
                      showToast("Please enter valid Email");
                      callApi = false;
                    }

                    if (mobileController.text.trim().isEmpty) {
                      showToast("Please enter Mobile Number");
                      callApi = false;
                    }

                    if (customerPoController.text.trim().isEmpty) {
                      showToast("Please enter Customer PO Number");
                      callApi = false;
                    }

                    if (locationController.text.trim().isEmpty) {
                      showToast("Please enter Job Location");
                      callApi = false;
                    }

                    if (cityController.text.trim().isEmpty) {
                      showToast("Please enter City");
                      callApi = false;
                    }

                    if (selectedLeadEngineer == null) {
                      showToast("Please select Lead Engineer");
                      callApi = false;
                    }

                    if (selectedStatus == null) {
                      showToast("Please select Job Status");
                      callApi = false;
                    }

                    if (selectedOtherEngineers.isEmpty) {
                      showToast("Please select Other Engineer");
                      callApi = false;
                    }

                    if (callApi) {
                      await createJob();

                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const JobListScreen(),
                      ),
                    );
                  },
                ),                const SizedBox(width: 25),
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
    void showOtherEngineerBottomSheet() {

      showModalBottomSheet(

        context: context,

        isScrollControlled: true,

        backgroundColor: Colors.white,

        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),

        builder: (context) {

          return StatefulBuilder(

            builder: (context, setModalState) {

              return SizedBox(

                height: MediaQuery.of(context).size.height * 0.65,

                child: Column(

                  children: [

                    const SizedBox(height: 15),

                    const CustomText(
                      "Select Other Engineers",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Divider(),

                    Expanded(

                      child: ListView.builder(

                        itemCount: users.length,

                        itemBuilder: (_, index) {

                          final user = users[index];

                          final isSelected =
                          selectedOtherEngineers.any(
                                (e) => e.id == user.id,
                          );

                          return CheckboxListTile(

                            value: isSelected,

                            title: CustomText(
                              "${user.firstName ?? ""} ${user.lastName ?? ""}",
                            ),

                            activeColor: AppColors.primary,

                            onChanged: (value) {

                              setModalState(() {

                                if (isSelected) {

                                  selectedOtherEngineers.removeWhere(
                                        (e) => e.id == user.id,
                                  );

                                } else {

                                  selectedOtherEngineers.add(user);
                                }
                              });

                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),

                    Padding(

                      padding: const EdgeInsets.all(16),

                      child: SizedBox(

                        width: double.infinity,
                       child: CustomButton(
                          title: "Done",
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  void showLeadEngineerBottomSheet() {

    showModalBottomSheet(

      context: context,

      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),

      builder: (context) {

        return Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            const SizedBox(height: 15),

            const CustomText(
              "Select Lead Engineer",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(),

            Flexible(
              child: ListView.builder(

                shrinkWrap: true,

                itemCount: users.length,

                itemBuilder: (_, index) {

                  final user = users[index];

                  return ListTile(

                    title: CustomText(
                      "${user.firstName ?? ""} ${user.lastName ?? ""}",
                      style: AppTextStyles.bodyMedium,
                    ),

                    onTap: () {

                      setState(() {
                        selectedLeadEngineer = user;
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
  void showStatusBottomSheet() {

    showModalBottomSheet(

      context: context,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),

      builder: (_) {

        return ListView.builder(

          shrinkWrap: true,

          itemCount: jobStatusList.length,

          itemBuilder: (context, index) {

            final status =
            jobStatusList[index];

            return ListTile(

              title: CustomText(
                status.status ?? "",
                style: AppTextStyles.bodyMedium,
              ),

              onTap: () {

                setState(() {
                  selectedStatus = status;
                });

                Navigator.pop(context);
              },
            );
          },
        );
      },
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
