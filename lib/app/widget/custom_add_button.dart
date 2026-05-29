import 'package:flutter/material.dart';

import '../theme/colors.dart';
import 'custom_text.dart';

class CustomAddButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;

  const CustomAddButton({
    super.key,
    required this.onTap,
    this.title = "Add",
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(99),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
