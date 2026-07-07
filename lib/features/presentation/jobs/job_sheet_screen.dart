import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_appbar.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
import 'package:powercare_flutter/app/widget/custom_button.dart';
import 'package:powercare_flutter/app/widget/custom_textfield.dart';

import '../../../app/widget/helper.dart';
import '../../alldata/api_repository/material_repository.dart';
import '../../alldata/models/job_list_response.dart';
import '../../alldata/models/material_response.dart';
import '../order/order_material_item.dart';
import '../order/order_material_row.dart'; // ✅ Added Import

class JobSheetScreen extends StatefulWidget {
  final JobModel? job;
  const JobSheetScreen({super.key, required this.job});

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
  List<OrderMaterialItem> materials = [];

  List<MaterialData> materialStockList = [];
  final MaterialRepository materialRepository = MaterialRepository();

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
  void initState() {
    super.initState();
    print("_clientNameController-->" + (job).toString());

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
    materials.add(OrderMaterialItem());

    loadMaterials();
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

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: CustomButton(
                title: "Save Job Sheet",
                onPressed: () {
                  // TODO: Save Job Sheet
                },
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
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

            if (picked != null) {
              onChanged("${picked.day}/${picked.month}/${picked.year}");
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
        value: "Pending",

        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),

        items: const [
          DropdownMenuItem(value: "Pending", child: Text("Pending")),

          DropdownMenuItem(value: "In Progress", child: Text("In Progress")),

          DropdownMenuItem(value: "Completed", child: Text("Completed")),
        ],

        onChanged: (v) {},
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

        icon: const Icon(Icons.add, color: Colors.white),

        label: const Text("Add Material"),

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
}
