import 'package:flutter/material.dart';
import 'package:powercare_flutter/features/alldata/models/UserModel.dart';

import '../../../app/widget/custom_appbar.dart';
import '../../../app/widget/custom_button.dart';
import '../../../app/widget/custom_dropdown.dart';
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

  bool isLoading = false;
  String jobName = "";
  String jobStatus = "";
  Color statusColor = Colors.orange;
  List<UserModel> users = [];

  List<Map<String, dynamic>> engineers = [
    {"name": "Lead Engineer", "userId": "", "startTime": "", "endTime": ""},
  ];

  @override
  void initState() {
    super.initState();

    loadUsers();
    callJobDetails();
  }
  Future<void> loadUsers() async {
    try {
      final List<UserModel> response =
      await repository.getUsers();

      setState(() {
        users = response;
      });
    } catch (e) {
      print("User Error => $e");
    }
  }
  Future<void> callJobDetails() async {
    try {
      final response = await JobRepository().getJobDetails(widget.jobId);

      final job = response.jobDetails;

      if (job != null) {
        setState(() {
          jobName = job.jobName ?? "";

          jobStatus = job.jobTypeStatus?.status ?? "";

          engineers.clear();

          // Lead Engineer
          engineers.add({
            "name": job.leadEngineer?.fullName ?? "",

            "userId": job.leadEngineer?.id?.toString() ?? "",

            "isLead": true,

            "startTime": "",

            "endTime": "",
          });
        });
      }
    } catch (e) {
      print("Job Details Error => $e");
    }
  }



  Future<void> saveTimeSheet() async {
    bool callApi = false;

    for(var engineer in engineers){

      if(
      engineer["startTime"]
          .toString()
          .isNotEmpty &&
          engineer["endTime"]
              .toString()
              .isNotEmpty){

        callApi = true;
      }
    }

    if(!callApi){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Please add new timelog",
          ),
        ),
      );

      return;
    }
    for (var engineer in engineers) {
      final start = engineer["startTime"];
      final end = engineer["endTime"];

      if (start.compareTo(end) >= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("End time must be greater than start time"),
          ),
        );

        return;
      }
    }
    for (var engineer in engineers) {
      if ((engineer["startTime"] ?? "").isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select start time")),
        );

        return;
      }

      if ((engineer["endTime"] ?? "").isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please select end time")));

        return;
      }
      final start = engineer["startTime"];
      final end = engineer["endTime"];

      if (start.compareTo(end) >= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("End time must be greater than start time"),
          ),
        );

        return;
      }
    }

    try {
      setState(() {
        isLoading = true;
      });

      Map<String, dynamic> payload = {};

      payload["job_id"] = widget.jobId;

      int index = 0;

      for (var engineer in engineers) {
        if (engineer["startTime"].toString().isNotEmpty &&
            engineer["endTime"].toString().isNotEmpty) {
          payload["engineer_id[$index]"] = engineer["userId"];

          payload["start_time[$index]"] = engineer["startTime"];

          payload["end_time[$index]"] = engineer["endTime"];

          index++;
        }
      }

      print(payload);
      final response = await repository.addTimeSheet(payload);

      print(response);

      if (response["success"] == true || response["statusCode"] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response["message"] ?? "Timesheet saved successfully",
            ),
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Failed to save timesheet"),
          ),
        );
      }
      /*      final response =
      await repository
          .addTimeSheet(
        payload,
      );

      print(response);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(
          content: Text(
            "Timesheet saved successfully",
          ),
        ),
      );

      Navigator.pop(context);*/
    } catch (e) {
      print("Save Error => $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickTime(int index, String key) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        engineers[index][key] =
            "${picked.hour.toString().padLeft(2, "0")}:${picked.minute.toString().padLeft(2, "0")}";
      });
    }
  }

  String calculateTotal(String start, String end) {
    if (start.isEmpty || end.isEmpty) {
      return "00:00";
    }

    try {
      final startParts = start.split(":");

      final endParts = end.split(":");

      final startMinutes =
          int.parse(startParts[0]) * 60 + int.parse(startParts[1]);

      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      final diff = endMinutes - startMinutes;

      final hrs = diff ~/ 60;

      final mins = diff % 60;

      return "${hrs.toString().padLeft(2, "0")}:${mins.toString().padLeft(2, "0")}";
    } catch (e) {
      return "00:00";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Time Sheet"),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),

        child: Column(
          children:[Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: engineers.length,
                    itemBuilder: (_, index) {

                      final item = engineers[index];

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 15,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [

                              if(item["isLead"] != true)
                                Align(
                                  alignment:
                                  Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {

                                      setState(() {

                                        engineers.removeAt(
                                          index,
                                        );
                                      });
                                    },
                                  ),
                                ),

                              item["isLead"] == true

                                  ? TextFormField(

                                initialValue:
                                item["name"],

                                readOnly: true,

                                decoration:
                                const InputDecoration(
                                  labelText:
                                  "Lead Engineer",
                                  border:
                                  OutlineInputBorder(),
                                ),
                              )

                                  :
                              CustomDropdown<UserModel>(
                                value: users.any(
                                      (e) => e.id.toString() == item["userId"],
                                )
                                    ? users.firstWhere(
                                      (e) => e.id.toString() == item["userId"],
                                )
                                    : null,

                                hint: "Select Engineer",

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
                                  if (value == null) return;

                                  setState(() {
                                    item["userId"] =
                                        value.id.toString();

                                    item["name"] =
                                    "${value.firstName ?? ""} ${value.lastName ?? ""}";
                                  });
                                },
                              ),
                              /* DropdownButtonFormField<String>(

                                value:
                                item["userId"] == ""
                                    ? null
                                    : item["userId"],

                                decoration:
                                const InputDecoration(
                                  labelText:
                                  "Engineer",
                                  border:
                                  OutlineInputBorder(),
                                ),

                                items:
                                users.map((user) {

                                  return DropdownMenuItem<String>(

                                    value:
                                    user.id.toString(),

                                    child: Text(
                                      "${user.firstName ?? ""} ${user.lastName ?? ""}",
                                    ),
                                  );

                                }).toList(),

                                onChanged: (value) {

                                  final selectedUser =
                                  users.firstWhere(
                                        (e) =>
                                    e.id.toString()
                                        == value,
                                  );

                                  setState(() {

                                    item["userId"] =
                                        value;

                                    item["name"] =
                                    "${selectedUser.firstName ?? ""} ${selectedUser.lastName ?? ""}";
                                  });
                                },
                              ),*/

                              const SizedBox(
                                height: 15,
                              ),

                              Row(
                                children: [

                                  Expanded(
                                    child:

                                    TextFormField(
                                      readOnly: true,
                                      controller:
                                      TextEditingController(
                                        text:
                                        item["startTime"],
                                      ),
                                      decoration:
                                      const InputDecoration(
                                        labelText:
                                        "Start Time",
                                        border:
                                        OutlineInputBorder(),
                                      ),
                                      onTap: () {

                                        pickTime(
                                          index,
                                          "startTime",
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 10,
                                  ),

                                  Expanded(
                                    child:
                                    TextFormField(
                                      readOnly: true,
                                      controller:
                                      TextEditingController(
                                        text:
                                        item["endTime"],
                                      ),
                                      decoration:
                                      const InputDecoration(
                                        labelText:
                                        "End Time",
                                        border:
                                        OutlineInputBorder(),
                                      ),
                                      onTap: () {

                                        pickTime(
                                          index,
                                          "endTime",
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 15,
                              ),

                              Container(
                                width:
                                double.infinity,
                                padding:
                                const EdgeInsets.all(
                                  12,
                                ),
                                decoration:
                                BoxDecoration(
                                  color:
                                  Colors.grey.shade100,
                                  borderRadius:
                                  BorderRadius.circular(
                                    10,
                                  ),
                                ),
                                child: Text(
                                  "Total Time : ${calculateTotal(item["startTime"], item["endTime"])}",
                                  textAlign:
                                  TextAlign.center,
                                  style:
                                  const TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  CustomButton(
                    title: "Add More",
                    onPressed: () {

                      setState(() {

                        engineers.add({

                          "name": "",
                          "userId": "",
                          "isLead": false,
                          "startTime": "",
                          "endTime": "",
                        });
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Row(
                children: [


                    CustomButton(
                      title: "Cancel",
                      background: Colors.grey,
                      onPressed: () {
                        Navigator.pop(context);
                      },

                  ),

                  const SizedBox(width: 15),

               CustomButton(
                      title: "Add Timesheet",
                      isLoading: isLoading,
                      onPressed: () {

                        saveTimeSheet();

                      },
                    ),

                ],
              ),
            ),
          ]
        ),
      ),
    );
  }
}
