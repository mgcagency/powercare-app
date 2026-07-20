import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_appbar.dart';
import 'package:powercare_flutter/app/widget/custom_response_dialogs.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
import 'package:powercare_flutter/app/widget/custom_button.dart';
import 'package:powercare_flutter/app/widget/custom_textfield.dart';
import 'package:intl/intl.dart';

import '../../../app/widget/helper.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../core/storage/app_preferences.dart';
import '../../alldata/api_repository/contact_repository.dart';
import '../../alldata/api_repository/job_repository.dart';
import '../../alldata/api_repository/material_repository.dart';
import '../../alldata/models/UserModel.dart';
import '../../alldata/models/contact_book_model.dart';
import '../../alldata/models/job_list_response.dart';
import '../../alldata/models/material_response.dart';
import '../order/order_material_item.dart';
import '../order/order_material_row.dart'; // ✅ Added Import
import '../../alldata/api_repository/TimeSheetRepository.dart';
import '../webview_screen/web_view_screen.dart';

class JobSheetScreen extends StatefulWidget {
  final JobModel? job;
  final String? jobSheetId;
  final bool? isView;

  const JobSheetScreen({
    super.key,
    required this.job,
    this.jobSheetId,
    required this.isView,
  });

  @override
  State<JobSheetScreen> createState() => _JobSheetScreenState();
}

class _JobSheetScreenState extends State<JobSheetScreen> {
  // Controllers for text fields
  String? _currentUserId; // Add this

  final _clientNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _officeNumController = TextEditingController();
  final _mobileNumController = TextEditingController();
  final _officeAddrController = TextEditingController();
  final _siteAddrController = TextEditingController();
  final _specController = TextEditingController();
  final _noteController = TextEditingController();
  final _serviceReqController = TextEditingController();
  late final JobModel? job = widget.job;
  late JobSheet? jobSheet = null;
  final TimeSheetRepository repository = TimeSheetRepository();

  final TextEditingController leadEngineerController = TextEditingController();

  bool isLoading = false;

  String jobName = "";

  String formatApiDate(String? date) {
    if (date == null || date.isEmpty) return "";

    final parsed = DateFormat("yyyy-MM-dd").parse(date);

    return DateFormat("dd/MM/yyyy").format(parsed);
  }

  // Date variables
  String _scheduledDate = "";
  String _orderDate = "";
  String _requiredDate = "";
  String selectedStatus = "";

  // Dummy list for Materials
  List<OrderMaterialItem> materials = [];
  List<UserModel> users = [];
  List<Map<String, dynamic>> engineers = [];
  List<MaterialData> materialStockList = [];
  final MaterialRepository materialRepository = MaterialRepository();
  final JobRepository jobRepository = JobRepository();
  final ContactRepository contactRepository = ContactRepository();
  List<ContactBookData> contactList = [];
  ContactBookData? selectedCon;

  Future<void> loadContacts() async {
    try {
      // We fetch a large first page or implement a search
      final response = await contactRepository.getContactList(
        page: 1,
        search: "",
      );

      final data = response["contactLists"]["data"];
      setState(() {
        contactList = data
            .map<ContactBookData>((e) => ContactBookData.fromJson(e))
            .toList();
      });
    } catch (e) {
      debugPrint("Error loading contacts: $e");
    }
  }

  Future<void> loadUsers() async {
    try {
      users = await repository.getUsers();
      users = users.where((u) => u.role?.toLowerCase() != 'admin').toList();
      setState(() {});
    } catch (e) {
      debugPrint("User Error => $e");
    }
  }

  Future<void> _loadCurrentUserId() async {
    final id = await AppPreferences.getUserID();
    setState(() {
      _currentUserId = id;
    });
  }

  // new code check //
  Future<void> callJobDetails() async {
    try {
      final response = await JobRepository().getJobDetails(
        widget.job!.id.toString(),
      );

      final detailJob = response.jobDetails;
      if (detailJob == null) return;

      if (widget.jobSheetId != null) {

        final sheet = detailJob.jobSheets?.firstWhere(
          (e) => e.id.toString() == widget.jobSheetId,
        );

        jobSheet =sheet;



        if (sheet != null) {

          selectedCon = (contactList ?? []).cast<ContactBookData?>().firstWhere(
                (e) => e?.id.toString() == sheet.companyId.toString(),
            orElse: () => null,
          );
          print("detailJob---->"+(widget.jobSheetId.toString()));

          _clientNameController.text = sheet.clientName ?? "";
          _companyNameController.text = sheet.companyName ?? "";
          _emailController.text = sheet.email ?? "";
          _officeNumController.text = sheet.officeNumber ?? "";
          _mobileNumController.text = sheet.mobileNumber ?? "";
          _officeAddrController.text = sheet.officeAddress ?? "";
          _siteAddrController.text = sheet.siteAddress ?? "";
          _specController.text = sheet.description ?? "";
          _noteController.text = sheet.notes ?? "";

          _serviceReqController.text = sheet.serviceRequest ?? "";
          selectedStatus = sheet.jobStatus ?? "";
          _scheduledDate = formatApiDate(job?.jobDate.toString());
          _orderDate = formatApiDate(sheet.dateOfOrder);
          _requiredDate = formatApiDate(sheet.dateRequired);
          materials.clear();
          for (var element in (sheet.jobSheetRelation ?? [])) {
            //1. Filter the list to find matching materials
            final foundMaterials = materialStockList.where(
                  (e) => e.id.toString() == element.materialId.toString(),
            );

            // 2. Check if any match was found
            if (foundMaterials.isNotEmpty) {
              final mat = foundMaterials.first; // Safe to call .first now

              // Check if we actually found a valid material before adding to the list
            if (mat != null && mat.id != null) {
              materials.add(OrderMaterialItem(
                materialId: element.materialId.toString(),
                materialName: element.materialName,
                markup: "",
                isUsedEditable: element.usedQty.toString() == "0",
                isEditable: false,
                availableQty: mat.totalQty ?? 0,
                qtyController: TextEditingController(text: element.orderQty.toString()),
                usedController: TextEditingController(text: element.usedQty.toString()),
                unitPrice: double.tryParse(mat.unitPrice?.toString() ?? '0.0') ?? 0.0,
              ));
            } } else {
              // Optional: Log if a material ID from the jobsheet is missing in the stock list
              debugPrint("Material ID ${element.materialId} not found in stock list");
            }
          }
          setState(() {});
        }
      }


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
                "id":ts.id.toString(),
                "isDeletable": false,
                "startTime": ts.startTime ?? "",
                "endTime": ts.endTime ?? "",
                "total": calculateTotal(ts.startTime ?? "", ts.endTime ?? ""),
              });
            }
            leadTimeSlots.add({

              "isDeletable": true,
              "startTime": "",
              "endTime": "",
              "total": "00:00",
            });
          } else {
            // Fallback to one empty slot if no data exists
            leadTimeSlots.add({

              "isDeletable": true,
              "startTime": "",
              "endTime": "",
              "total": "00:00",
            });
          }

          engineers.add({

            "isDeletable": false,
            "name": detailJob.leadEngineer!.fullName,
            "userId": detailJob.leadEngineer!.id.toString(),
            "isLead": true,
            "timeSlots": leadTimeSlots,
          });
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
                    "id":ts.id.toString(),
                    "isDeletable": false,
                    "startTime": ts.startTime ?? "",
                    "endTime": ts.endTime ?? "",
                    "total": calculateTotal(
                      ts.startTime ?? "",
                      ts.endTime ?? "",
                    ),
                  });
                }
                otherTimeSlots.add({
                  "isDeletable": true,
                  "startTime": "",
                  "endTime": "",
                  "total": "00:00",
                });
              } else {
                otherTimeSlots.add({

                  "isDeletable": true,
                  "startTime": "",
                  "endTime": "",
                  "total": "00:00",
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
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void addEngineerBlock() {
    setState(() {
      engineers.add({
        "isDeletable": true,
        "name": "",
        "userId": "",
        "isLead": false,
        "timeSlots": [
          {
            "id":"",
            "isDeletable": true,
            "startTime": "",
            "endTime": "",
            "total": "00:00",
          },
        ],
      });
    });
  }

  void addTimeSlot(int engineerIndex) {
    setState(() {
      engineers[engineerIndex]["timeSlots"].add({
        "isDeletable": true,
        "id":"",
        "startTime": "",
        "endTime": "",
        "total": "00:00",
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
        final timeStr =
            "${picked.hour.toString().padLeft(2, "0")}:${picked.minute.toString().padLeft(2, "0")}";
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
      int diff =
          (int.parse(e[0]) * 60 + int.parse(e[1])) -
          (int.parse(s[0]) * 60 + int.parse(s[1]));
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
      Map<String, dynamic> payload = {};
      int apiIndex = 0;

      for (var engineer in engineers) {
        for (var slot in engineer["timeSlots"]) {
          if (slot["startTime"].isNotEmpty && slot["endTime"].isNotEmpty ) {
            payload["engineer_id[$apiIndex]"] = engineer["userId"];
           payload["time_sheet_id[$apiIndex]"] = slot["id"];
            payload["start_time[$apiIndex]"] = slot["startTime"];
            payload["end_time[$apiIndex]"] = slot["endTime"];

            apiIndex++;
          }
        }
      }
      if (apiIndex != 0) {
        payload["job_id"] = widget.job!.id.toString();
      }

      // if (apiIndex == 0) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text("Please add at least one time log")),
      //   );
      //
      //   return;
      // }
      print("12121212" + (payload.containsKey("job_id")).toString());
      print("12121212----->" + (payload).toString());

      /*   final response = await repository.addTimeSheet(payload);
      if (response["success"] == true) {
        Navigator.pop(context);
      }*/
      if (payload.containsKey("job_id")) {
        final response = await repository.addTimeSheet(payload);
        if (!mounted) return;

        if (response["success"] == true) {
          showSuccessDialog(context, "Job Sheet and Time Sheet Saved Successfully", onOk: () {Navigator.pop(context, true);
          });

          return;
        }else{
          showSuccessDialog(context, response["message"], onOk: () {Navigator.pop(context, true);
          });
        }
      } else {
        showSuccessDialog(context,  "Job Sheet is Saved Successfully", onOk: () {Navigator.pop(context, true);
        });
      }
    } catch (e) {
      debugPrint("Save Error => $e");
    }
    /*    finally {
      setState(() => isLoading = false);
    }*/
    finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void showEngineerBottomSheet(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            const Text(
              "Select Engineer",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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

  Future<void> loadMaterials() async {
    try {
      final response = await materialRepository.getStockList();

      materialStockList.clear();

      final data = response["material_lists"]?["data"] as List? ?? [];

      for (final item in data) {
        materialStockList.add(MaterialData.fromJson(item));
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setState(() {
      isLoading = true;
    });
    await loadMaterials();
    await loadUsers();
    await loadContacts();
    await callJobDetails();
    await _loadCurrentUserId();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    for (final item in materials) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: "Job Sheet"),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(),

                  const SizedBox(height: 24),

                  _buildClientInformationCard(),

                  const SizedBox(height: 20),

                  _buildAddressCard(),

                  const SizedBox(height: 20),

                  // Part 2 starts here...
                  _buildWorkRequiredCard(),

                  const SizedBox(height: 20),

                  _buildJobDetailsCard(),

                  const SizedBox(height: 20),
                  _buildScheduleCard(),
                  if ((jobSheet?.documentFullLink??"").isNotEmpty && (jobSheet?.documentFullLink??"") != "https://powercare.resolveddevelopment.co.uk/storage")
                    const SizedBox(height: 20),

                  if (jobSheet?.documentFullLink != null && jobSheet?.documentFullLink !="")
                    _buildDocumentsCard(),

                  const SizedBox(height: 20),

                  _buildStatusCard(),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        "Add Time Sheet",
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Divider(color: Colors.black, thickness: 1, height: 1),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildGrandTotalHeader(),

                  const SizedBox(height: 20),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: engineers.length,
                    itemBuilder: (context, index) {
                      return _buildEngineerSection(index);
                    },
                  ),

                  if (!(widget.isView ?? true)) _buildAddEngineerButton(),
                  const SizedBox(height: 30),
                  if (!(widget.isView ?? true))
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        title: "Save Job Sheet",
                        onPressed: () async {
                          // Show the confirmation popup
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const CustomText("Confirm Save", style: TextStyle(fontWeight: FontWeight.bold)),
                              content: const CustomText("Are you sure you want to save this Job Sheet and its Timesheet?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context), // Close the popup
                                  child: const CustomText("Cancel", txtColor: Colors.grey),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context); // Close the popup
                                    // Call the save functions
                                    await saveJobSheet();
                                    await saveTimeSheet();
                                  },
                                  child: const CustomText(
                                      "Yes, Save",
                                      txtColor: AppColors.primary,
                                      style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Future<void> saveJobSheet() async {
    final sheet = jobSheet;
    final Map<String, dynamic> body = {};

    body["client_name"] = _clientNameController.text.trim();
    body["company_name"] = _companyNameController.text.trim();
    body["company_id"] = selectedCon?.id.toString();
    body["email"] = _emailController.text.trim();
    body["office_number"] = _officeNumController.text.trim();
    body["mobile_number"] = _mobileNumController.text.trim();
    body["office_address"] = _officeAddrController.text.trim();
    body["site_address"] = _siteAddrController.text.trim();
    body["description"] = _specController.text.trim();
    body["notes"] = _noteController.text.trim();

    body["service_request"] = _serviceReqController.text.trim();

    /* body["date_of_scheduled"] = */ /*_scheduledDate*/ /*"10/07/2026";
    body["date_of_order"] = */ /*_orderDate*/ /*"10/07/2026";
    body["date_required"] = "10/07/2026";*/
    body["date_of_scheduled"] = _scheduledDate;
    body["date_of_order"] = _orderDate;
    body["date_required"] = _requiredDate;
    // body["job_status"] = selectedStatus;
    //body["job_status"] = "1";
    body["job_status"] = selectedStatus ?? jobSheet?.jobStatus ?? "";
    body["job_id"] = widget.job?.id.toString();
    double subtotal = 0;

    for (int i = 0; i < materials.length; i++) {
      final item = materials[i];
      final qty = int.tryParse(item.qtyController.text) ?? 0;
      final used = int.tryParse(item.usedController.text) ?? 0;
      final unitPrice = item.unitPrice ?? 0;
      final totalPrice = qty * unitPrice;

      body["material_id[$i]"] = item.materialId;

      body["order_qty[$i]"] = qty.toString();

      body["purchase_qty_used[$i]"] = used.toString();

      body["unit_price[$i]"] = unitPrice.toString();

      body["total_price[$i]"] = totalPrice.toString();

      subtotal += totalPrice;
    }

    body["material_sub_total"] = subtotal.toString();

    body["purchase_sub_total"] = "0";

    body["wage_sub_total"] = "0";

    try {
      // final response = await jobRepository.saveJobSheet(body);
      Map<String, dynamic> response;

      /*if (widget.job?.jobSheets != null &&
          widget.job!.jobSheets!.isNotEmpty) {*/

      if (widget.jobSheetId != null) {
        //final jobSheetId = widget.job!.jobSheets!.first.id.toString();
        final jobSheetId = widget.jobSheetId.toString();
        print("EDIT JOB SHEET ID => $jobSheetId");

        response = await jobRepository.editJobSheet(jobSheetId, body);
      } else {
        print("CREATE NEW JOB SHEET");

        response = await jobRepository.saveJobSheet(body);
      }
      if (!mounted) return;

      if (response["success"] == true) {
        print("kskdlsdksldksd11------>" );

        // showSuccessDialog(context,  response["message"] ?? "Job Sheet Saved Successfully", onOk: () {
        // });

      } else {
        print("kskdlsdksldksd222------>" );

        // showErrorDialog(context,  response["message"] ?? "Something went wrong");

      }
    } catch (e) {
      print("kskdlsdksldksd------>" + e.toString());
      // showErrorDialog(context,  e.toString() ?? "Something went wrong");

    }
  }

  Widget _buildJobDetailsCard() {
    return SectionHeaderCard(
      icon: Icons.description_outlined,
      title: "Job Details",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel("Specification"),
          CustomTextField(
            readOnly: widget.isView ?? true,
            controller: _specController,
            hintText: "Enter specification",
            maxLines: 4,
          ),

          const SizedBox(height: 16),

          _fieldLabel("Service Requested by the Client"),
          CustomTextField(
            readOnly: widget.isView ?? true,
            controller: _serviceReqController,
            hintText: "Enter service requested",
            maxLines: 4,
          ),
        ],
      ),
    );
  }
  /*  Widget _buildjobNotes() {
    return SectionHeaderCard(
      icon: Icons.description_outlined,
      title: "Notes",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _fieldLabel("Notes"),
          CustomTextField(
            controller: _specController,
            hintText: "Enter here",
            maxLines: 4,
          ),


        ],
      ),
    );
  }*/

  Widget _buildScheduleCard() {
    return SectionHeaderCard(
      icon: Icons.calendar_month_outlined,

      title: "Schedule",

      child: Column(
        children: [
          _modernDateField(
            title: "Scheduled Date",

            value: _scheduledDate,

            onChanged: (v) {
              setState(() {
                if (!(widget.isView ?? true)) {
                  _scheduledDate = v;
                }
              });
            },
          ),

          const SizedBox(height: 15),

          _modernDateField(
            title: "Date of Order",

            value: _orderDate,

            onChanged: (v) {
              setState(() {
                _orderDate = v;
              });
            },
          ),

          const SizedBox(height: 15),

          _modernDateField(
            title: "Date Required",

            value: _requiredDate,

            onChanged: (v) {
              setState(() {
                _requiredDate = v;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _modernDateField({
    required String title,

    required String value,

    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        CustomText(
          title,

          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 8),

        InkWell(
          onTap: (widget.isView ?? true)
              ? () {}
              : () async {
                  DateTime? picked = await showDatePicker(
                    context: context,

                    initialDate: DateTime.now(),

                    firstDate: DateTime(2020),

                    lastDate: DateTime(2100),
                  );

                  /*  if (picked != null) {
              onChanged(
                  //"${picked.day}/${picked.month}/${picked.year}");
                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}",);

                  }*/
                  if (picked != null) {
                    onChanged(
                      "${picked.day.toString().padLeft(2, '0')}/"
                      "${picked.month.toString().padLeft(2, '0')}/"
                      "${picked.year}",
                    );
                  }
                },

          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(12),

              border: Border.all(color: AppColors.border),
            ),

            child: Row(
              children: [
                Expanded(child: CustomText(value)),

                const Icon(Icons.calendar_month, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsCard() {
    return SectionHeaderCard(
      icon: Icons.attach_file,

      title: "Job Documents",

      child: InkWell(
        onTap: () {
          AppNavigator.push(
            WebViewScreen(
              url: jobSheet?.documentFullLink ?? "",
              title: "Jobsheet Document", // This passes the document title
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            color: Colors.grey.shade50,

            borderRadius: BorderRadius.circular(12),

            border: Border.all(color: AppColors.border),
          ),

          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.08),

                  borderRadius: BorderRadius.circular(10),
                ),

                child: const Icon(
                  Icons.insert_drive_file,

                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    CustomText(
                      "Job Attachment",

                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 2),

                    CustomText(
                      jobSheet?.documentFullLink ?? "",

                      style: AppTextStyles.bodyExtraSmall.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.open_in_new, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return SectionHeaderCard(
      icon: Icons.flag_outlined,

      title: "Job Status",

      child: DropdownButtonFormField<String>(
        value: (selectedStatus != "") ? selectedStatus : "CALL_BACK_REQUIRED",

        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),

        items: const [
          DropdownMenuItem(
            value: "GO_AHEAD_WITH_WORK",
            child: CustomText("GO AHEAD WITH WORK"),
          ),

          DropdownMenuItem(
            value: "QUOTE_REQUIRED",
            child: CustomText("QUOTE REQUIRED"),
          ),

          DropdownMenuItem(
            value: "CALL_BACK_REQUIRED",
            child: CustomText("CALL BACK REQUIRED"),
          ),
        ],

        onChanged: (widget.isView ?? true)
            ? null
            : (v) {
                selectedStatus = v ?? "";
              },
      ),
    );
  }

  Widget _buildWorkRequiredCard() {
    return SectionHeaderCard(
      icon: Icons.inventory_2_outlined,

      title: "Work Required",

      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  "Select materials required for this job.",

                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: CustomText(
                  "${materials.length} Items",

                  style: AppTextStyles.bodyExtraSmall.copyWith(
                    color: AppColors.primary,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          if (materials.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: materials.length,
              itemBuilder: (_, index) {
                return _buildMaterialEntryCard(index);
              },
            ),
          if (!(widget.isView ?? true)) const SizedBox(height: 10),
          if (!(widget.isView ?? true))
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),

              child: _buildAddMaterialButton(),
            ),
          const SizedBox(height: 10),

          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel("Notes"),
                CustomTextField(
                  readOnly: widget.isView ?? true,
                  controller: _noteController,
                  hintText: "Enter here",
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialEntryCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.black12),
      ),

      child: OrderMaterialRow(
        item: materials[index],

        materials: materialStockList,

        showDivider: false,

        selectedMaterialIds: materials
            .where((e) => e.materialId != null && e.materialId!.isNotEmpty)
            .map((e) => e.materialId!)
            .toList(),

        onDelete: materials.length > 1
            ? () {
                setState(() {
                  materials[index].dispose();

                  materials.removeAt(index);
                });
              }
            : null,

        onMaterialChanged: (value) {
          setState(() {
            materials[index].materialId = value?.id.toString();

            materials[index].materialName = value?.materialName;

            materials[index].availableQty = value?.totalQty ?? 0;
          });
        },

        onQtyChanged: (_) {},
      ),
    );
  }

  Widget _buildAddMaterialButton() {
    return SizedBox(
      width: double.infinity,

      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            materials.add(OrderMaterialItem());
          });
        },

        // icon: const Icon(Icons.add_outlined, color: Colors.white,size: 20,),
        label: CustomText(
          "\u002B Add Material",
          txtColor: Colors.white,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,

          foregroundColor: Colors.white,

          elevation: 0,

          padding: const EdgeInsets.symmetric(vertical: 15),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.only(top: 4, left: 1, right: 1, bottom: 1),
      decoration: BoxDecoration(
        color: Color(
          int.parse(
            job?.jobTypeStatus?.colorCode?.replaceAll("#", "0xFF") ??
                "0xFF1565C0",
          ),
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        job?.jobName ?? "",
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      CustomText(
                        "Job #${job?.jobNumber ?? "-"}",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(
                        job?.jobTypeStatus?.colorCode?.replaceAll(
                              "#",
                              "0xFF",
                            ) ??
                            "0xFF1565C0",
                      ),
                    ).withOpacity(.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomText(
                    job?.jobTypeStatus?.status ?? "Active",
                    style: AppTextStyles.bodyExtraSmall.copyWith(
                      color: Color(
                        int.parse(
                          job?.jobTypeStatus?.colorCode?.replaceAll(
                                "#",
                                "0xFF",
                              ) ??
                              "0xFF1565C0",
                        ),
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _miniInfo(
                    Icons.calendar_month_outlined,
                    "Scheduled",
                    _scheduledDate.isEmpty ? "-" : _scheduledDate,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _miniInfo(
                    Icons.location_on_outlined,
                    "Site",
                    job?.jobLocation ?? "-",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _miniInfo(
              Icons.email_outlined,
              "Email",
              _emailController.text.isEmpty ? "-" : _emailController.text,
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniInfo(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                title,
                style: AppTextStyles.bodyExtraSmall.copyWith(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 2),

              CustomText(
                value,
                maxLines: 2,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientInformationCard() {
    return SectionHeaderCard(
      icon: Icons.person_outline,
      title: "Client Information",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel("Select a contact", true),
          DropdownButtonFormField<ContactBookData>(
            isExpanded: true,
            hint: const CustomText("Select a contact"),
            // Find current selection in the list or set null
            value: selectedCon,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              fillColor: (widget.isView ?? true)
                  ? Colors.grey.shade50
                  : Colors.white,
              filled: true,
            ),
            // Disable if in view mode
            onChanged: (widget.isView ?? true)
                ? null
                : (ContactBookData? selectedContact) {
                    if (selectedContact != null) {
                      selectedCon = selectedContact;
                      setState(() {
                        _clientNameController.text = selectedContact.name ?? "";
                        _companyNameController.text =
                            selectedContact.companyName ?? "";
                        _emailController.text = selectedContact.email ?? "";
                        _mobileNumController.text =
                            selectedContact.contactNo ?? "";
                        _siteAddrController.text =
                            selectedContact.address ?? "";
                      });
                    }
                  },
            items: contactList.map((contact) {
              return DropdownMenuItem<ContactBookData>(
                value: contact,
                child: CustomText(contact.companyName ?? ""),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _fieldLabel("Client Name", true),
          CustomTextField(
            readOnly: true,
            controller: _clientNameController,
            hintText: "Enter client name",
          ),

          const SizedBox(height: 16),

          _fieldLabel("Company Name", true),
          CustomTextField(
            readOnly: true,
            controller: _companyNameController,
            hintText: "Enter company name",
          ),

          const SizedBox(height: 16),

          _fieldLabel("Company Email", true),
          CustomTextField(
            readOnly: true,
            controller: _emailController,
            hintText: "Enter company email",
          ),

          const SizedBox(height: 16),

          _fieldLabel("Mobile Number"),
          CustomTextField(
            readOnly: true,
            controller: _mobileNumController,
            hintText: "Mobile number",
          ),

          const SizedBox(height: 16),

          _fieldLabel("Site Address", true),
          CustomTextField(
            readOnly: true,
            controller: _siteAddrController,
            hintText: "Enter site address",
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String title, [bool required = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: title,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (required)
              TextSpan(
                text: " *",
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return SectionHeaderCard(
      icon: Icons.location_on_outlined,
      title: "Office Details",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel("Office Address"),
          CustomTextField(
            readOnly: widget.isView ?? true,
            controller: _officeAddrController,
            hintText: "Enter office address",
            maxLines: 2,
          ),

          const SizedBox(height: 16),
          _fieldLabel("Office Number"),
          CustomTextField(
            readOnly: widget.isView ?? true,
            controller: _officeNumController,
            hintText: "Office number",
          ),
        ],
      ),
    );
  }

  Widget _buildGrandTotalHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CustomText(
            "Total Project Hours",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          CustomText(
            calculateGrandTotal(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngineerSection(int engIdx) {
    final engineer = engineers[engIdx];
    final bool isLead = engineer["isLead"] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          // --- SECTION HEADER ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isLead ? Colors.blue.shade50 : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isLead ? Icons.stars : Icons.person,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomText(
                    isLead ? "Lead Engineer" : !engineer["isDeletable"] ?"Other Engineer":"Additional Engineer",
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Only show delete button for non-lead engineers
                if (engineer["isDeletable"])
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
                    readOnly:
                        (widget.isView) ??
                        true &&
                            _currentUserId !=
                                widget.job?.leadEngineer?.id.toString(),
                    controller: TextEditingController(text: engineer["name"]),
                    label: "Engineer Name",

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
                  itemBuilder: (context, slotIdx) =>
                      _buildTimeSlotRow(engIdx, slotIdx),
                ),
                if (!(widget.isView ?? true)) const Divider(),
                if (!(widget.isView ?? true))
                  TextButton.icon(
                    onPressed: () => addTimeSlot(engIdx),
                    icon: const Icon(Icons.add_alarm, size: 18),
                    label: const Text("Add Shift/Slot"),
                  ),
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
          Expanded(
            child: _timeField(
              "In",
              slot["startTime"],
              !slot["isDeletable"]
                  ? null
                  : () => _pickTime(engIdx, slotIdx, "startTime"),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _timeField(
              "Out",
              slot["endTime"],
              !slot["isDeletable"]
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
          if (slot["isDeletable"])
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
              onPressed: () => setState(
                () => engineers[engIdx]["timeSlots"].removeAt(slotIdx),
              ),
            ),
        ],
      ),
    );
  }

  Widget _timeField(String label, String value, VoidCallback? onTap) {
    return InkWell(
      onTap:
          !(widget.isView ?? false) &&
              _currentUserId != widget.job?.leadEngineer?.id.toString()
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
        margin: EdgeInsetsDirectional.symmetric(horizontal: 30),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
            CustomText(
              "Add Additional Engineer",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineerPicker(int engIdx) {
    final engineer = engineers[engIdx];

    print(
      "object1---->${engineer["name"]}--->" +
          (widget.isView ?? false).toString(),
    );
    print(
      "object2---->${_currentUserId != widget.job?.leadEngineer?.id.toString()}",
    );
    print("object2---->" + (!engineer["isDeletable"]).toString());
    return GestureDetector(
      onTap:
          (widget.isView ?? false) ||!engineer["isDeletable"]||
              (!engineer["isDeletable"] &&
                  _currentUserId != widget.job?.leadEngineer?.id.toString())
          ? null
          : () => showEngineerBottomSheet(engineer),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomText(
                engineer["name"].isEmpty
                    ? "Select Engineer from List"
                    : engineer["name"],
                style: AppTextStyles.bodyMedium.copyWith(
                  color: engineer["name"].isEmpty
                      ? Colors.grey
                      : Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_drop_down_circle_outlined,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: CustomButton(
              background: AppColors.primary,
              title: "Cancel",
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            /*    CustomButton(
              title: "Cancel",textClr: Colors.black,
              background: Colors.grey.shade200,
              onPressed: () => Navigator.pop(context),
            ),*/
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
}
