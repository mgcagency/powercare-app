import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/text_styles.dart';
import '../../../app/widget/custom_appbar.dart';
import '../../../app/widget/custom_button.dart';
import '../../../app/widget/custom_dropdown.dart';
import '../../../app/widget/custom_text.dart';
import '../../../app/widget/custom_textfield.dart';
import '../../../core/storage/app_preferences.dart';
import '../../alldata/api_repository/leave_repository.dart';

class RequestHolidayScreen extends StatefulWidget {
  const RequestHolidayScreen({super.key});

  @override
  State<RequestHolidayScreen> createState() =>
      _RequestHolidayScreenState();
}

class _RequestHolidayScreenState
    extends State<RequestHolidayScreen> {
  bool isLoading = false;
  DateTime? startDate;
  DateTime? endDate;
  final LeaveRepository repository =
  LeaveRepository();

  final notesController =
  TextEditingController();

  String? selectedType;

  final List<String> holidayTypes = [
    "ANNUAL",
    "SICK",
    "PERSONAL",
  ];

  Future<void> pickStartDate() async {

    final picked =
    await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate:
      startDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }


  Future<void> pickEndDate() async {

    if (startDate == null) {

      _showError(
        "Please select start date first",
      );

      return;
    }

    final picked =
    await showDatePicker(
      context: context,
      firstDate: startDate!,
      lastDate: DateTime(2100),
      initialDate:
      endDate ?? startDate!,
    );

    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }
  void validateAndSave() {

    if(startDate == null){
      _showError(
        "Please select start date",
      );
      return;
    }

    if(endDate == null){
      _showError(
        "Please select end date",
      );
      return;
    }

    if(selectedType == null){
      _showError(
        "Please select holiday type",
      );
      return;
    }

    if(notesController.text.isEmpty){
      _showError(
        "Please enter notes",
      );
      return;
    }

    final duration =
        endDate!
            .difference(startDate!)
            .inDays + 1;

    if(duration <= 0){
      _showError(
        "End date must be after start date",
      );
      return;
    }

    print(
      "Start = $startDate",
    );
    print(
      "End = $endDate",
    );
    print(
      "Type = $selectedType",
    );
    print(
      "Duration = $duration",
    );
    callLeaveCreateApi();
    // Call API here
  }
  Future<void> callLeaveCreateApi() async {
    setState(() {
      isLoading = true;
    });
    try {

      final duration =
          endDate!
              .difference(startDate!)
              .inDays + 1;

      final userId =
      await AppPreferences.getUserID();

      final payload = {

        "engineer_id": userId,

        "start_date":
        formatDate(startDate),

        "end_date":
        formatDate(endDate),

        "duration":
        duration.toString(),

        "status":
        "PENDING",

        "holiday_type":
        selectedType,

        "additional_notes":
        notesController.text.trim(),
      };

      print(payload);

      final response =
      await repository.createLeave(
        payload,
      );

      print(response);

  /*    if(response["statusCode"] == 200 ||
          response["success"] == true){
*/
      if(response["statusCode"] == 200 ||
          response["status_code"] == 200 ||
          response["success"] == true){
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Holiday request submitted successfully",
            ),
          ),
        );

        Navigator.pop(context);

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              response["message"] ??
                  "Something went wrong",
            ),
          ),
        );
      }

    } catch(e){

      print(
        "Leave Error => $e",
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
    finally {

      setState(() {
        isLoading = false;
      });

    }
  }

  void _showError(
      String message) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String formatDate(
      DateTime? date) {

    if(date == null) return "";

    return DateFormat(
      "dd/MM/yyyy",
    ).format(date);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: const CustomAppBar(title: "New Holiday Request"),


      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          children: [

            _buildLabel("Holiday Start Date"),

            _buildDatePickerField(
              startDate == null
                  ? "Select Start Date"
                  : formatDate(startDate),
                  (val) {
                setState(() {
                  startDate = DateFormat(
                    "dd/MM/yyyy",
                  ).parse(val);
                });
              },
            ),

            const SizedBox(height: 20),

            _buildLabel("Holiday End Date"),

            _buildDatePickerField(
              endDate == null
                  ? "Select End Date"
                  : formatDate(endDate),
                  (val) {
                setState(() {
                  endDate = DateFormat(
                    "dd/MM/yyyy",
                  ).parse(val);
                });
              },
            ),

            const SizedBox(
              height: 20,
            ),
            _buildLabel("Holiday Type"),
            GestureDetector(
              onTap: showHolidayTypeBottomSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [

                    Expanded(
                      child: CustomText(
                        selectedType ??
                            "Select Type",
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
       /*     CustomDropdown(
              value: selectedType,
              hint: "Select Type",
              items: holidayTypes
                  .map(
                    (e) =>
                    DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
              )
                  .toList(),
              onChanged: (value) {

                setState(() {
                  selectedType =
                      value;
                });
              },
            ),*/
            const SizedBox(
              height: 20,
            ),

            CustomTextField(
              controller: notesController,
              hintText: "Additional Notes",
              maxLines: 4,
            ),

            const SizedBox(
              height: 30,
            ),

            Row(
              children: [

                Expanded(
                  child: CustomButton(
                    title: "Cancel",
                    background: Colors.grey.shade500,
               /*     icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),*/
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),


                Expanded(
                  child: CustomButton(
                    title: "Save",
                    isLoading: isLoading,
                  /*  icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                    ),*/
                    onPressed: isLoading
                        ? null
                        : validateAndSave,
                  ),
                ),
              ],
            )          ],
        ),
      ),
    );
  }
  void showHolidayTypeBottomSheet() {

    showModalBottomSheet(

      context: context,

      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),

      builder: (_) {

        return Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            const SizedBox(height: 15),

            const Text(
              "Select Holiday Type",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(),

            ...holidayTypes.map((type) {

              return ListTile(

                title: CustomText(
                  type,
                  style: AppTextStyles.bodyMedium,
                ),

                onTap: () {

                  setState(() {
                    selectedType = type;
                  });

                  Navigator.pop(context);
                },
              );
            }).toList(),

            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
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
  Widget _buildDatePickerField(
      String value,
      Function(String) onDateSelected,
      ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius:
        BorderRadius.circular(8),
      ),
      child: Row(
        children: [

          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.only(
                left: 12,
              ),
              child: CustomText(
                value,
                style:
                AppTextStyles.bodySmall,
              ),
            ),
          ),

          GestureDetector(
            onTap: () async {

              DateTime? picked =
              await showDatePicker(
                context: context,
                initialDate:
                DateTime.now(),
                firstDate:
                DateTime.now(),
                lastDate:
                DateTime(2100),
              );

              if (picked != null) {

                onDateSelected(
                  DateFormat(
                    "dd/MM/yyyy",
                  ).format(
                    picked,
                  ),
                );
              }
            },
            child: Container(
              padding:
              const EdgeInsets.all(
                12,
              ),
              decoration:
              const BoxDecoration(
                color:
                AppColors.primary,
                borderRadius:
                BorderRadius.only(
                  topRight:
                  Radius.circular(
                      8),
                  bottomRight:
                  Radius.circular(
                      8),
                ),
              ),
              child: const Icon(
                Icons.calendar_month,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}