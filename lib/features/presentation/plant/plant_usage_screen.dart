import 'package:flutter/material.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_appbar.dart';
import 'package:powercare_flutter/app/widget/custom_button.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
import 'package:powercare_flutter/app/widget/custom_textfield.dart';

import '../../alldata/api_repository/plant_usage_repository.dart';
import '../../alldata/api_repository/plant_usage_request.dart';
import '../../alldata/models/job_list_response.dart';

class PlantUsageScreen extends StatefulWidget {
  final JobModel job;

  const PlantUsageScreen({
    super.key,
    required this.job,
  });

  @override
  State<PlantUsageScreen> createState() => _PlantUsageScreenState();
}

class _PlantUsageScreenState extends State<PlantUsageScreen> {

  final _repository = PlantUsageRepository();

  final TextEditingController supplierController =
  TextEditingController();

  final TextEditingController purchasedController =
  TextEditingController();

  final TextEditingController usedController =
  TextEditingController();

  bool? cherryPickerUsed;
  bool? offHired;

  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    supplierController.dispose();
    purchasedController.dispose();
    usedController.dispose();
    super.dispose();
  }

  Widget buildLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 18),
      child: CustomText(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildRadio({
    required bool? groupValue,
    required Function(bool?) onChanged,
  }) {
    return Row(
      children: [

        Radio<bool>(
          value: true,
          groupValue: groupValue,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),

        const CustomText("Yes"),

        const SizedBox(width: 30),

        Radio<bool>(
          value: false,
          groupValue: groupValue,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),

        const CustomText("No"),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(
          title: "Plant Usage",
        ),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroCard(job: widget.job),

                    // const SizedBox(height: 16),


              buildLabel(
                "Has the PowerCare Cherrypicker been used?",
              ),

              buildRadio(
                groupValue: cherryPickerUsed,
                onChanged: (value) {
                  setState(() {
                    cherryPickerUsed = value;
                  });
                },
              ),

              buildLabel(
                "List any hired plant & supplier name",
              ),

              CustomTextField(
                controller: supplierController,
                hintText: "Explain here...",
                maxLines: 4,
                validator: (value) {

                  if (value == null || value.trim().isEmpty) {
                    return "Supplier name is required";
                  }

                  return null;
                },
              ),

              buildLabel(
                "Has any hired plant been off-hired?",
              ),

              buildRadio(
                groupValue: offHired,
                onChanged: (value) {

                  setState(() {
                    offHired = value;
                  });

                },
              ),

              buildLabel("Quantity Purchased"),

              CustomTextField(
                controller: purchasedController,
                hintText: "Number of quantity",
                keyboardType: TextInputType.number,
                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Enter quantity";
                  }

                  return null;
                },
              ),

              buildLabel("Quantity Used"),

              CustomTextField(
                controller: usedController,
                hintText: "Number of quantity",
                keyboardType: TextInputType.number,
                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Enter quantity";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 40),
                    Row(
                      children: [



                        Expanded(
                          child: CustomButton(
                            title: isLoading ? "Please Wait..." : "Order",
                            onPressed: isLoading ? null : submitPlantUsage,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                  ],
              ),
            ),
        ),
    );
  }

  Future<void> submitPlantUsage() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (cherryPickerUsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText(
            "Please select Cherry Picker Used",
          ),
        ),
      );
      return;
    }

    if (offHired == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText(
            "Please select Off Hired",
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final request = PlantUsageRequest(
        jobId: widget.job.id.toString(),
        cherrypickerUsed: cherryPickerUsed! ? "1" : "0",
        hiredPlantSupplierName: supplierController.text.trim(),
        hirePlantQtyPurchased: purchasedController.text.trim(),
        hirePlantQtyUsed: usedController.text.trim(),
        offHired: offHired! ? "1" : "0",
      );

      final response =
      await _repository.createPlantUsage(request);

      if (!mounted) return;

      if (response.success == true) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              response.message ?? "Plant ordered successfully",
            ),
          ),
        );

        Navigator.pop(context, true);

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              response.message ?? "Something went wrong",
            ),
          ),
        );

      }

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            e.toString(),
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

    }

  }
}
class _HeroCard extends StatelessWidget {
  final JobModel job;

  const _HeroCard({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(
      int.parse(
        job.jobTypeStatus?.colorCode?.replaceAll("#", "0xFF") ??
            "0xFF000000",
      ),
    );

    return Container(
      padding: const EdgeInsets.only(
        top: 4,
        left: 1,
        right: 1,
        bottom: 1,
      ),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          "Plant Usage",
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        CustomText(
                          job.jobName ?? "",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CustomText(
                      job.jobTypeStatus?.status ?? "",
                      style: AppTextStyles.bodyExtraSmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MiniChip(
                    icon: Icons.badge_outlined,
                    label: "Job #${job.jobNumber ?? "-"}",
                  ),
                  _MiniChip(
                    icon: Icons.calendar_today_outlined,
                    label: job.jobDate ?? "-",
                  ),
                  _MiniChip(
                    icon: Icons.access_time_outlined,
                    label: job.jobTime ?? "-",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _MiniChip extends StatelessWidget {


  final IconData icon;
  final String label;

  const _MiniChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF6F6F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            icon,
            size: 14,
            color: AppColors.primary,
          ),

          const SizedBox(width: 5),

          CustomText(
            label,
            style: AppTextStyles.caption,
          ),

        ],
      ),
    );
  }
}