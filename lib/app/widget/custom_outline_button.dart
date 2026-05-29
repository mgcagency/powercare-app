import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'custom_text.dart';


class CustomOutlineButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final double? fontSize;
  final EdgeInsets? padding;

  const CustomOutlineButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        padding: padding ?? const EdgeInsets.symmetric(vertical: 15),
        child: Center(
          child: CustomText(
            title,
            style: AppTextStyles.button.copyWith(
              fontSize: fontSize,
              color: AppColors.primary, // Force the color here
            ),
          ),
        ),
      ),
    );
  }
}
