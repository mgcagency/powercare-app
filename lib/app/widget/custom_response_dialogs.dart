import 'package:flutter/material.dart';
import '../theme/colors.dart';

import '../theme/text_styles.dart';
import 'custom_button.dart';
import 'custom_text.dart';

void showSuccessDialog(BuildContext context, String message,
    {VoidCallback? onOk}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 60),
          const SizedBox(height: 12),
          CustomText(message, style: AppTextStyles.bodyLarge),
          const SizedBox(height: 16),
          CustomButton(
            title: "OK",
            onPressed: () {
              Navigator.of(context).pop();
              if (onOk != null) onOk();
            },
            textClr: AppColors.textColor,
          )
        ],
      ),
    ),
  );
}

void showErrorDialog(BuildContext context, String message,
    {VoidCallback? onOk}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 60),
          const SizedBox(height: 12),
          CustomText(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          CustomButton(
            title: "OK",
            onPressed: () {
              Navigator.of(context).pop();
              if (onOk != null) onOk();
            },
            textClr: AppColors.textColor,
          )
        ],
      ),
    ),
  );
}

void showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  IconData icon = Icons.warning_amber_rounded,
  Color iconColor = AppColors.primary,
  Color confirmBtnColor = AppColors.primary,
  Color cancelBtnColor = AppColors.grey,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 40,
            ),
          ),

          const SizedBox(height: 20),

          /// Title
          CustomText(
            title,
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          /// Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CustomText(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          /// Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  title: cancelText,
                  background: cancelBtnColor,
                  textClr: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onCancel != null) onCancel();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  title: confirmText,
                  background: confirmBtnColor,
                  textClr: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onConfirm != null) onConfirm();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
