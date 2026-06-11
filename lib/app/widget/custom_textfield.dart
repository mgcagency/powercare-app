import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'custom_text.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;
  final String? label;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.readOnly = false,
    this.label,
    this.onTap,

    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          CustomText(
            widget.label!,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          style: AppTextStyles.bodyMedium,
          controller: widget.controller,
          readOnly: widget.readOnly,
          onTap: widget.onTap,

          obscureText: _obscureText,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            hintText: widget.hintText,
            fillColor: Colors.white,
            filled: true,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
            labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
            contentPadding: widget.maxLines > 1
                ? const EdgeInsets.all(15) 
                : const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.maxLines > 1 ? 16 : 30),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.maxLines > 1 ? 16 : 30),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.maxLines > 1 ? 16 : 30),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            suffixIcon: widget.obscureText
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
