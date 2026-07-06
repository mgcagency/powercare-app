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

        const Text("Yes"),

        const SizedBox(width: 30),

        Radio<bool>(
          value: false,
          groupValue: groupValue,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),

        const Text("No"),
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

                  buildLabel("Selected Job"),

              CustomTextField(
                controller: TextEditingController(
                  text: widget.job.jobName ?? "",
                ),
                readOnly: true,
              ),

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
                          child:
                          CustomButton(
                            background: AppColors.primary,
                            title: "Back",
                            onPressed: () {
                              Navigator.pop(context);
                            },

                          ),
                     /*     OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Back"),
                          ),*/
                        ),

                        const SizedBox(width: 15),

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
          content: Text(
            "Please select Cherry Picker Used",
          ),
        ),
      );
      return;
    }

    if (offHired == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
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
            content: Text(
              response.message ?? "Plant ordered successfully",
            ),
          ),
        );

        Navigator.pop(context, true);

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message ?? "Something went wrong",
            ),
          ),
        );

      }

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
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