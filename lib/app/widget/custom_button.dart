import 'package:flutter/material.dart';


import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'custom_text.dart';

class CustomButton extends StatelessWidget {
  final String? title;
  final double? fontSize;
  final Size? size;
  final VoidCallback? onPressed;
  final Color? background;
  final Color? textClr;
  final String? fontFamily;
  final double? height;
  final bool? isLoading;
  final bool showShadow;

  final EdgeInsets? padding;
  final Widget? icon;
  final bool isOutlined;
  final Color? borderColor;


  const CustomButton({
    super.key,
    this.title,
    this.fontSize,
    this.size,
    this.onPressed,
    this.background,
    this.isLoading = false,
    this.height,
    this.textClr = Colors.white,
    this.fontFamily,
    this.padding,
    this.icon,
    this.showShadow = true,
    this.isOutlined = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,

      /*style: ElevatedButton.styleFrom(
        minimumSize: size,
        shape: const StadiumBorder(),
        backgroundColor: primary ?? ColorConstant.appOrange,
        foregroundColor: onPrimary ?? ColorConstant.appOrange,
      ),*/
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [Container(
        // height: (fontSize ?? 16.sp) + 25.h,
          decoration: BoxDecoration(
            color: isOutlined
                ? Colors.transparent
                : (background ?? AppColors.primary),

            borderRadius: BorderRadius.circular(999),

            border: isOutlined
                ? Border.all(
              color: borderColor ?? AppColors.primary,
              width: 1.5,
            )
                : null,

            boxShadow: showShadow
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ]
                : [],
          ),
        padding:
            padding ??
            EdgeInsets.only(
              top: 12,
              bottom: 12,
              left: icon != null ? 10 : 30,
              right: 30,
            ),
        child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon ?? Container(),
                    SizedBox(width: 10),
                  ],

                  (isLoading ?? false)
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: isOutlined
                            ? (borderColor ?? AppColors.primary)
                            : Colors.white,
                      ),
                    ),
                  )
                      :  CustomText(
                    "$title",
                    style: AppTextStyles.button,
                    txtColor: textClr ??
                        (isOutlined
                            ? (borderColor ?? AppColors.primary)
                            : AppColors.textOnPrimary),
                  ),
                ],
              ),
      )]),
    );
  }
}
