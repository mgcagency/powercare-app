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

  final EdgeInsets? padding;
  final Widget? icon;

  const CustomButton({
    super.key,
    this.title,
    this.fontSize,
    this.size,
    this.onPressed,
    this.background,
    this.isLoading = false,
    this.height,
    this.textClr,
    this.fontFamily,
    this.padding,
    this.icon,
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
          color: background ?? AppColors.primary,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25), // shadow color
              blurRadius: 8, // softness
              spreadRadius: 1, // size
              offset: const Offset(0, 4), // position (x, y)
            ),
          ],
        ),
        padding:
            padding ??
            EdgeInsets.only(
              top: 15,
              bottom: 15,
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
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                      :  CustomText(
                    "$title",
                    style: AppTextStyles.button,
                    txtColor: textClr ?? AppColors.textOnPrimary,
                  ),
                ],
              ),
      )]),
    );
  }
}
