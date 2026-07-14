import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_appbar.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
import 'package:powercare_flutter/app/widget/custom_button.dart';
import 'package:powercare_flutter/app/widget/custom_textfield.dart';
import 'package:intl/intl.dart';

import '../../../app/widget/helper.dart';
import '../../alldata/api_repository/job_repository.dart';
import '../../alldata/api_repository/material_repository.dart';
import '../../alldata/models/UserModel.dart';
import '../../alldata/models/job_list_response.dart';
import '../../alldata/models/material_response.dart';
import '../order/order_material_item.dart';
import '../order/order_material_row.dart'; // ✅ Added Import
import '../../alldata/api_repository/TimeSheetRepository.dart';
class JobSheetScreen extends StatefulWidget {
  final JobModel? job;
  final JobSheet? jobSheet;


  const JobSheetScreen({super.key, required this.job , this.jobSheet,
  });

  @override
  State<JobSheetScreen> createState() => _JobSheetScreenState();
}

class _JobSheetScreenState extends State<JobSheetScreen> {
  // Controllers for text fields
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
  final TimeSheetRepository repository = TimeSheetRepository();

  final TextEditingController leadEngineerController =
  TextEditingController();

  bool isLoading = false;

  String jobName = "";

  String formatApiDate(String? date) {
    if (date == null || date.isEmpty) return "";

    final parsed = DateFormat("yyyy-MM-dd").parse(date);

    return DateFormat("dd/MM/yyyy").format(parsed);
  }

  // Date variables
  String _scheduledDate = "03/06/2026";
  String _orderDate = "16/03/2026";
  String _requiredDate = "23/03/2026";
  String selectedStatus = "";

  // Dummy list for Materials
  List<OrderMaterialItem> materials = [];
  List<UserModel> users = [];
  List<Map<String, dynamic>> engineers = [];
  List<MaterialData> materialStockList = [];
  final MaterialRepository materialRepository = MaterialRepository();
  final JobRepository jobRepository = JobRepository();

  Future<void> loadUsers() async {
    try {
      users = await repository.getUsers();
      setState(() {});
    } catch (e) {
      debugPrint("User Error => $e");
    }
  }
// new code check //
  Future<void> callJobDetails() async {
    try {
      final response =
      await JobRepository().getJobDetails(widget.job!.id.toString());

      final detailJob = response.jobDetails;

      if (detailJob == null) return;

      if (widget.jobSheet != null) {
        final sheet = detailJob.jobSheets?.firstWhere(
              (e) => e.id == widget.jobSheet!.id,
          orElse: () => widget.jobSheet!,
        );

        if (sheet != null) {
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

          _orderDate = formatApiDate(sheet.dateOfOrder);
          _requiredDate = formatApiDate(sheet.dateRequired);

          setState(() {});
        }
      }

      setState(() {
        jobName = detailJob.jobName ?? "";

        engineers.clear();

        if (detailJob.leadEngineer != null) {
          leadEngineerController.text =
              detailJob.leadEngineer!.fullName;

          engineers.add({
            "name": detailJob.leadEngineer!.fullName,
            "userId": detailJob.leadEngineer!.id.toString(),
            "isLead": true,
            "timeSlots": [
              {
                "startTime": "",
                "endTime": "",
                "total": "00:00",
              }
            ]
          });
        }

        if (detailJob.otherEngineers != null) {
          for (final other in detailJob.otherEngineers!) {
            if (other.user != null) {
              engineers.add({
                "name": other.user!.fullName,
                "userId": other.user!.id.toString(),
                "isLead": false,
                "timeSlots": [
                  {
                    "startTime": "",
                    "endTime": "",
                    "total": "00:00",
                  }
                ]
              });
            }
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
/*
  Future<void> callJobDetails() async {
    print("API JOB DATE => ${job?.jobDate}");

    try {

      final response = await JobRepository().getJobDetails(widget.job!.id.toString());
      final job = response.jobDetails;
      print("JOB SHEETS => ${job?.jobSheets}");
      print("JOB SHEET COUNT => ${job?.jobSheets?.length}");
      print("JOB SHEET ID => ${job?.jobSheets?.first.id}");
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
*/

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
      Map<String, dynamic> payload = {"job_id": widget.job!.id.toString()};
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
      debugPrint(payload.toString());

   /*   final response = await repository.addTimeSheet(payload);
      if (response["success"] == true) {
        Navigator.pop(context);
      }*/
      final response = await repository.addTimeSheet(payload);

      if (!mounted) return;

      if (response["success"] == true) {
        Navigator.pop(context, true);
        return;
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

    print("RECEIVED JOB SHEET => ${widget.jobSheet}");
    print("RECEIVED JOB SHEET ID => ${widget.jobSheet?.id}");
    print("CLIENT => ${widget.jobSheet?.clientName}");
    print("COMPANY => ${widget.jobSheet?.companyName}");
    print("EMAIL => ${widget.jobSheet?.email}");

    final sheet = widget.jobSheet;

    if (sheet != null) {
      // =========================
      // EDIT MODE
      // =========================

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
      _scheduledDate =
          formatApiDate(sheet.dateOfScheduled);
      _scheduledDate = formatApiDate(sheet.dateOfOrder);
      _orderDate = formatApiDate(sheet.dateOfOrder);
      _requiredDate = formatApiDate(sheet.dateRequired);
    } else {
      // =========================
      // CREATE MODE
      // =========================

      _clientNameController.text = job?.siteContactName ?? "";
      _companyNameController.text = job?.jobName ?? "";
      _emailController.text = job?.email ?? "";
      _officeNumController.text = "";
      _mobileNumController.text = job?.mobileNo ?? "";
      _officeAddrController.text = "";
      _siteAddrController.text = job?.jobLocation ?? "";
      _specController.text = "";
      _noteController.text = "";
      _serviceReqController.text = job?.jobDescription ?? "";
      _scheduledDate =
          formatApiDate(sheet?.dateOfScheduled);
      _scheduledDate = formatApiDate(job?.jobDate);
      _orderDate = formatApiDate(job?.jobDate);
      _requiredDate = formatApiDate(job?.jobDate);
    }

    print("Scheduled => $_scheduledDate");
    print("Order => $_orderDate");
    print("Required => $_requiredDate");

    materials.add(OrderMaterialItem());

    loadMaterials();
    loadUsers();
    callJobDetails();
  }
/*
  void initState() {

    super.initState();
    print("RECEIVED JOB SHEET => ${widget.jobSheet}");
    print("RECEIVED JOB SHEET ID => ${widget.jobSheet?.id}");
    print("RECEIVED JOB SHEET => ${widget.jobSheet}");
    print("CLIENT => ${widget.jobSheet?.clientName}");
    print("COMPANY => ${widget.jobSheet?.companyName}");
    print("EMAIL => ${widget.jobSheet?.email}");
*/
/*    final sheet = widget.jobSheet;
    if (sheet != null) {

      // EDIT MODE
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

    } else {

      // CREATE MODE
      _clientNameController.text = job?.siteContactName ?? "";
      _companyNameController.text = job?.jobName ?? "";
      _emailController.text = job?.email ?? "";
      _officeNumController.text = "";
      _mobileNumController.text = job?.mobileNo ?? "";
      _officeAddrController.text = "";
      _siteAddrController.text = job?.jobLocation ?? "";
      _specController.text = "";
      _noteController.text = "";
      _serviceReqController.text = job?.jobDescription ?? "";

    }*//*

    final sheet = widget.jobSheet;
    print("_clientNameController-->" + (job).toString());

    /// Contact Person
    //_clientNameController.text = job?.siteContactName ?? "";

    /// Company / Job Name
    _companyNameController.text = job?.jobName ?? "";

    /// Email
    _emailController.text = job?.email ?? "";

    /// Office Number
    _officeNumController.text = "";

    /// Mobile Number
    _mobileNumController.text = job?.mobileNo ?? "";

    /// Office Address
    _officeAddrController.text = "";

    /// Site Address
    _siteAddrController.text = job?.jobLocation ?? "";

    /// Specification
    _specController.text = "";

    /// Service Requested
    _serviceReqController.text = job?.jobDescription ?? "";

    /// Dates
 */
/*   _scheduledDate = job?.jobDate ?? "";
    _orderDate = job?.jobDate ?? "";
    _requiredDate = job?.jobDate ?? "";*//*

    _scheduledDate = formatApiDate(job?.jobDate);
    _orderDate = formatApiDate(job?.jobDate);
    _requiredDate = formatApiDate(job?.jobDate);
    materials.add(OrderMaterialItem());
    print("Scheduled => $_scheduledDate");
    print("Order => $_orderDate");
    print("Required => $_requiredDate");

    loadMaterials();
    loadUsers();
    callJobDetails();
  }
*/

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
      body: SingleChildScrollView(
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

            const SizedBox(height: 20),

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

                Divider(
                  color: Colors.black,
                  thickness: 1,
                  height: 1,
                ),
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

            const SizedBox(height: 20),

            _buildAddEngineerButton(),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: CustomButton(
                title: "Save Job Sheet",
                onPressed: () async {
                  print("SAVE MODE");

                  print("SAVE JOB SHEET => ${widget.jobSheet}");
                  print("SAVE JOB SHEET ID => ${widget.jobSheet?.id}");
                  await saveJobSheet();
                  await saveTimeSheet();
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
    final sheet = widget.jobSheet;
    final Map<String, dynamic> body = {};

    body["client_name"] = _clientNameController.text.trim();
    body["company_name"] = _companyNameController.text.trim();
    body["email"] = _emailController.text.trim();
    body["office_number"] = _officeNumController.text.trim();
    body["mobile_number"] = _mobileNumController.text.trim();
    body["office_address"] = _officeAddrController.text.trim();
    body["site_address"] = _siteAddrController.text.trim();
    body["description"] = _specController.text.trim();
    body["notes"] = _noteController.text.trim();
    print("==============");
    print(body);
    print("Notes => ${body["notes"]}");
    print("==============");

    body["service_request"] =
        _serviceReqController.text.trim();
   /* body["date_of_scheduled"] = *//*_scheduledDate*//*"10/07/2026";
    body["date_of_order"] = *//*_orderDate*//*"10/07/2026";
    body["date_required"] = "10/07/2026";*/
    body["date_of_scheduled"] = _scheduledDate;
    body["date_of_order"] = _orderDate;
    body["date_required"] = _requiredDate;
    print("Selected Status => $selectedStatus");
   // body["job_status"] = selectedStatus;
    //body["job_status"] = "1";
    body["job_status"] = widget.jobSheet?.jobStatus ?? "1";
    body["job_id"] = widget.job?.id.toString();
    double subtotal = 0;

    for (int i = 0; i < materials.length; i++) {
      final item = materials[i];
      final qty =
          int.tryParse(item.qtyController.text) ?? 0;
      final used =
          int.tryParse(item.usedController.text) ?? 0;
      final unitPrice = item.unitPrice ?? 0;
      final totalPrice = qty * unitPrice;
      body["material_id[$i]"] =
          item.materialId;

      body["order_qty[$i]"] =
          qty.toString();

      body["purchase_qty_used[$i]"] =
          used.toString();

      body["unit_price[$i]"] =
          unitPrice.toString();

      body["total_price[$i]"] =
          totalPrice.toString();

      subtotal += totalPrice;
    }
    body["material_sub_total"] =
        subtotal.toString();

    body["purchase_sub_total"] = "0";

    body["wage_sub_total"] = "0";

    try {
      print("==============");
      print(body);
      print("Scheduled => ${body["date_of_scheduled"]}");
      print("Order => ${body["date_of_order"]}");
      print("Required => ${body["date_required"]}");
      print("==============");
     // final response = await jobRepository.saveJobSheet(body);
      Map<String, dynamic> response;

      /*if (widget.job?.jobSheets != null &&
          widget.job!.jobSheets!.isNotEmpty) {*/
      if (widget.jobSheet != null){
        //final jobSheetId = widget.job!.jobSheets!.first.id.toString();
        final jobSheetId = widget.jobSheet!.id.toString();
        print("EDIT JOB SHEET ID => $jobSheetId");

        response = await jobRepository.editJobSheet(
          jobSheetId,
          body,
        );

      } else {

        print("CREATE NEW JOB SHEET");

        response = await jobRepository.saveJobSheet(body);
      }
      if (!mounted) return;

      if (response["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            content: CustomText(
              response["message"] ??
                  "Job Sheet Saved Successfully",
            ),

          ),

        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            content: CustomText(
              response["message"] ??
                  "Something went wrong",
            ),

          ),

        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: CustomText(e.toString()),

        ),

      );
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
            controller: _specController,
            hintText: "Enter specification",
            maxLines: 4,
          ),

          const SizedBox(height: 16),

          _fieldLabel("Service Requested by the Client"),
          CustomTextField(
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
                _scheduledDate = v;
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
          onTap: () async {
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
                    "Tap to open",

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
    );
  }

  Widget _buildStatusCard() {
    return SectionHeaderCard(
      icon: Icons.flag_outlined,

      title: "Job Status",

      child: DropdownButtonFormField<String>(
        value: "Ongoing",

        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),

        items: const [
          DropdownMenuItem(value: "Ongoing", child: Text("Ongoing")),

          DropdownMenuItem(value: "Additional Work Required", child: Text("Additional Work Required")),

          DropdownMenuItem(value: "Completed by Engineer", child: Text("Completed by Engineer")),
          DropdownMenuItem(value: "New Quote Required", child: Text("New Quote Required")),
        ],

        onChanged: (v) {
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

          ListView.builder(
            shrinkWrap: true,

            physics: const NeverScrollableScrollPhysics(),

            itemCount: materials.length,

            itemBuilder: (_, index) {
              return _buildMaterialEntryCard(index);
            },
          ),

          const SizedBox(height: 10),

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
                  controller: _noteController,
                  hintText: "Enter here",
                  maxLines: 4,
                ),


              ],
            ),
          )
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

        label:  CustomText("\u002B Add Material",txtColor: Colors.white,style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),),

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
                        job?.jobTypeStatus?.colorCode?.replaceAll("#", "0xFF") ??
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
                          job?.jobTypeStatus?.colorCode?.replaceAll("#", "0xFF") ??
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
          _fieldLabel("Client Name", true),
          CustomTextField(
            controller: _clientNameController,
            hintText: "Enter client name",
          ),

          const SizedBox(height: 16),

          _fieldLabel("Company Name", true),
          CustomTextField(
            controller: _companyNameController,
            hintText: "Enter company name",
          ),

          const SizedBox(height: 16),

          _fieldLabel("Company Email", true),
          CustomTextField(
            controller: _emailController,
            hintText: "Enter company email",
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel("Office Number"),
                    CustomTextField(
                      controller: _officeNumController,
                      hintText: "Office number",
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel("Mobile Number"),
                    CustomTextField(
                      controller: _mobileNumController,
                      hintText: "Mobile number",
                    ),
                  ],
                ),
              ),
            ],
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
      title: "Address Details",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel("Office Address"),
          CustomTextField(
            controller: _officeAddrController,
            hintText: "Enter office address",
            maxLines: 2,
          ),

          const SizedBox(height: 16),

          _fieldLabel("Site Address", true),
          CustomTextField(
            controller: _siteAddrController,
            hintText: "Enter site address",
            maxLines: 2,
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
            child:
            CustomButton(
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
