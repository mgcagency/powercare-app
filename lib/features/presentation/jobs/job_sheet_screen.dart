import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_appbar.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
import 'package:powercare_flutter/app/widget/custom_button.dart';
import 'package:powercare_flutter/app/widget/custom_textfield.dart';

import '../../alldata/models/job_list_response.dart'; // ✅ Added Import

class JobSheetScreen extends StatefulWidget {
  final JobModel? job;
  const JobSheetScreen({super.key, required this.job,});

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
  final _serviceReqController = TextEditingController();
  late final JobModel? job = widget.job;
  // Date variables
  String _scheduledDate = "03/06/2026";
  String _orderDate = "16/03/2026";
  String _requiredDate = "23/03/2026";

  // Dummy list for Materials
  List<Map<String, dynamic>> workRequired = [
    {"material": "Wood", "qty": "1"},
    {"material": "Metal", "qty": "1"},
  ];
  @override
  void initState() {
    super.initState();
print("_clientNameController-->"+(job).toString());
    /// Contact Person
    _clientNameController.text = job?.siteContactName ?? "";

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
    _scheduledDate = job?.jobDate ?? "";
    _orderDate = job?.jobDate ?? "";
    _requiredDate = job?.jobDate ?? "";
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Job Sheet"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Client’s name", isRequired: true),
            CustomTextField(
              controller: _clientNameController,
              hintText: "Roger Smith",
            ),

            _buildLabel("Company name", isRequired: true),
            CustomTextField(
              controller: _companyNameController,
              hintText: "Company",
            ),

            _buildLabel("Company email", isRequired: true),
            CustomTextField(
              controller: _emailController,
              hintText: "company@gmail.com",
            ),

            _buildLabel("Office number"),
            CustomTextField(
              controller: _officeNumController,
              hintText: "Office number",
            ),

            _buildLabel("Mobile number"),
            CustomTextField(
              controller: _mobileNumController,
              hintText: "Mobile number",
            ),

            _buildLabel("Office Address"),
            CustomTextField(
              controller: _officeAddrController,
              hintText: "Office Address",
            ),

            _buildLabel("Site address"),
            CustomTextField(
              controller: _siteAddrController,
              hintText: "Site address",
            ),

            _buildLabel("Scheduled date"),
            _buildDatePickerField(_scheduledDate, (val) => setState(() => _scheduledDate = val)),

            const SizedBox(height: 20),
            const Divider(thickness: 1),
            CustomText(
              "Work Required",
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // --- MATERIAL TABLE ---
            _buildMaterialTable(),

            const SizedBox(height: 20),
            _buildLabel("Specification"),
            CustomTextField(
              controller: _specController,
              hintText: "Description..",
              maxLines: 4, // ✅ Handled multi-line
            ),

            _buildLabel("Service Requested by the client"),
            CustomTextField(
              controller: _serviceReqController,
              hintText: "service,,....",
            ),

            _buildLabel("Date of Order"),
            _buildDatePickerField(_orderDate, (val) => setState(() => _orderDate = val)),

            _buildLabel("Date Required"),
            _buildDatePickerField(_requiredDate, (val) => setState(() => _requiredDate = val)),

            const SizedBox(height: 20),
            _buildLabel("Job Documents"),
            CustomText(
              "https://powercare.resolveddevelopment.co.uk/storage/upload/job/documents/APeNSo5grQy1lECK0wdacRkdDnI9I0cThcCCGoh8.png",
              style: AppTextStyles.bodyExtraSmall.copyWith(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),

            const SizedBox(height: 20),
            _buildLabel("Select status of a job"),
            CustomTextField(
              controller: TextEditingController(),
              hintText: "Select Status",
            ),

            const SizedBox(height: 40),

            // ✅ Using CustomButton
            CustomButton(
              title: "Save Job Sheet",
              onPressed: () {
                // Handle Save Logic
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Helper to build required labels
  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Row(
        children: [
          CustomText(
            text,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
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

  // Helper for Date Pickers with orange icon
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
                borderRadius: BorderRadius.only(topRight: Radius.circular(3), bottomRight: Radius.circular(3)),
              ),
              child: const Icon(Icons.calendar_month, color: Colors.white, size: 20),
            ),
          )
        ],
      ),
    );
  }

  // Material Table Widget
  Widget _buildMaterialTable() {
    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: const BoxDecoration(
            color: Color(0xFF1E5398),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: CustomText(
                  "Material Name",
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              CustomText(
                "Qty",
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
        // Table Rows
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: workRequired.map((item) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: item['material'],
                            items: ["Wood", "Metal", "Plastic"].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: CustomText(value, style: AppTextStyles.bodySmall),
                              );
                            }).toList(),
                            onChanged: (val) {},
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: CustomText(item['qty'], style: AppTextStyles.bodySmall),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}