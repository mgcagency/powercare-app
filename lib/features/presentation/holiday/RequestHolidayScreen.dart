import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:powercare_flutter/app/theme/colors.dart';
import 'package:powercare_flutter/app/theme/text_styles.dart';
import 'package:powercare_flutter/app/widget/custom_appbar.dart';
import 'package:powercare_flutter/app/widget/custom_button.dart';
import 'package:powercare_flutter/app/widget/custom_text.dart';
import 'package:powercare_flutter/app/widget/custom_textfield.dart';
import 'package:powercare_flutter/core/storage/app_preferences.dart';
import '../../alldata/api_repository/leave_repository.dart';

class RequestHolidayScreen extends StatefulWidget {
  const RequestHolidayScreen({super.key});

  @override
  State<RequestHolidayScreen> createState() => _RequestHolidayScreenState();
}

class _RequestHolidayScreenState extends State<RequestHolidayScreen> {
  bool isLoading = false;
  DateTime? startDate;
  DateTime? endDate;
  final LeaveRepository repository = LeaveRepository();
  final notesController = TextEditingController();
  String? selectedType;

  final List<String> holidayTypes = ["ANNUAL", "SICK", "PERSONAL"];

  int get _calculateDuration {
    if (startDate == null || endDate == null) return 0;
    final diff = endDate!.difference(startDate!).inDays + 1;
    return diff > 0 ? diff : 0;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: isStart ? DateTime.now() : (startDate ?? DateTime.now()),
      lastDate: DateTime(2100),
      initialDate: isStart ? (startDate ?? DateTime.now()) : (endDate ?? startDate ?? DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.navyBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (endDate != null && endDate!.isBefore(startDate!)) {
            endDate = null;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  void validateAndSave() {
    if (startDate == null || endDate == null || selectedType == null || notesController.text.isEmpty) {
      _showError("Please complete all required fields");
      return;
    }
    callLeaveCreateApi();
  }

  Future<void> callLeaveCreateApi() async {
    setState(() => isLoading = true);
    try {
      final userId = await AppPreferences.getUserID();
      final payload = {
        "engineer_id": userId,
        "start_date": DateFormat("dd/MM/yyyy").format(startDate!),
        "end_date": DateFormat("dd/MM/yyyy").format(endDate!),
        "duration": _calculateDuration.toString(),
        "status": "PENDING",
        "holiday_type": selectedType,
        "additional_notes": notesController.text.trim(),
      };

      final response = await repository.createLeave(payload);

      if (response["statusCode"] == 200 || response["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: CustomText("Holiday request submitted successfully"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        _showError(response["message"] ?? "Something went wrong");
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: CustomText(message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: "New Request"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- HEADER INFO ---
            _buildSectionHeader("Holiday Duration"),
            const SizedBox(height: 12),

            // --- DATE PICKER CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  _buildDateTile(
                    title: "Start Date",
                    date: startDate,
                    icon: Icons.calendar_today_rounded,
                    onTap: () => _pickDate(isStart: true),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        Container(width: 2, height: 20, color: Colors.grey.shade100),
                      ],
                    ),
                  ),
                  _buildDateTile(
                    title: "End Date",
                    date: endDate,
                    icon: Icons.event_available_rounded,
                    onTap: () => _pickDate(isStart: false),
                  ),

                  if (_calculateDuration > 0) ...[
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText("Total Duration", style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CustomText(
                            "$_calculateDuration Days",
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader("Request Details"),
            const SizedBox(height: 12),

            // --- TYPE SELECTION ---
            GestureDetector(
              onTap: showHolidayTypeBottomSheet,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.category_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomText(
                        selectedType ?? "Select Leave Type",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: selectedType == null ? Colors.grey : AppColors.navyBlue,
                          fontWeight: selectedType == null ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.expand_more_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- NOTES ---
            CustomTextField(
              controller: notesController,
              hintText: "Add specific details or reasons for your request...",
              maxLines: 4,
            ),

            const SizedBox(height: 40),

            // --- ACTIONS ---
            Row(
              children: [
                // Expanded(
                //   child: CustomButton(
                //     title: "CANCEL",
                //     background: Colors.white,
                //     // textColor: AppColors.navyBlue,
                //     onPressed: () => Navigator.pop(context),
                //   ),
                // ),
                // const SizedBox(width: 15),
                Expanded(
                  child: CustomButton(
                    title: "Submit",
                    isLoading: isLoading,
                    onPressed: isLoading ? null : validateAndSave,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 2, height: 20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        CustomText(
          title,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.navyBlue, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildDateTile({required String title, DateTime? date, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(title, style: AppTextStyles.bodyExtraSmall.copyWith(color: Colors.grey)),
                CustomText(
                  date == null ? "Pick Date" : DateFormat("EEEE, dd MMM yyyy").format(date),
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: date == null ? Colors.black : AppColors.navyBlue),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  void showHolidayTypeBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              CustomText("Select Leave Type", style: AppTextStyles.headline4.copyWith(fontSize: 18)),
              const SizedBox(height: 10),
              const Divider(),
              ...holidayTypes.map((type) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: CustomText(type, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                trailing: selectedType == type ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => selectedType = type);
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}