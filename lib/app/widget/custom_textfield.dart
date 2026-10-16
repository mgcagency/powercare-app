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
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.readOnly = false,
    this.label,
    this.onTap,
    this.prefixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
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
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: CustomText(
              widget.label!,
              style: AppTextStyles.bodyExtraSmall.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
        TextFormField(
          onTap: widget.onTap,
          controller: widget.controller,
          obscureText: _obscureText,
          readOnly: widget.readOnly,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: AppTextStyles.bodyMedium.copyWith(
            color: widget.readOnly ? AppColors.darkGrey : AppColors.textColor,
          ),
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            filled: widget.readOnly,
            fillColor: widget.readOnly ? AppColors.readOnlyBg : Colors.transparent,
            hintText: widget.hintText,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
            contentPadding: widget.maxLines > 1
                ? const EdgeInsets.all(15)
                : const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: widget.readOnly ? AppColors.grey : AppColors.darkGrey,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.readOnly ? AppColors.border : AppColors.primary,
                width: widget.readOnly ? 1 : 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
