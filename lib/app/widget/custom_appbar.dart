import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:powercare_flutter/app/theme/colors.dart';

import '../../core/navigation/app_navigator.dart';
import '../constants/icon_contants.dart';
import '../theme/text_styles.dart';
import 'custom_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? titleChild;
  final VoidCallback? onBack;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? backButtonColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.titleChild,
    this.actions,
    this.onBack,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.backButtonColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {

    return AppBar(
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      elevation: elevation ?? 0,
      backgroundColor: backgroundColor ?? AppColors.primary,
      centerTitle: title == null ? false : centerTitle,
      titleSpacing: 0,
      leading: null,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          showBack
              ? InkWell(
                  onTap: onBack ?? () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: backButtonColor ?? Colors.white,
                    ),
                  ),
                )
              : Container(width: 0),
          const SizedBox(width: 5),
          Expanded(
            child: titleChild ??
                ( CustomText(
                        title!,
                        style: AppTextStyles.headline4.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ),
          ),
        ],
      ),
      actions: actions ??null,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
    );
  }
}
