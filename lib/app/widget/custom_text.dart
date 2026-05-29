import 'package:flutter/material.dart';
import '../theme/text_styles.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color? txtColor;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final int? lines;
  final TextOverflow? overflow;

  const CustomText(
      this.text, {
        super.key,
        this.style,
        this.textAlign,
        this.maxLines,
        this.lines,
        this.overflow,
        this.txtColor,
      });

  @override
  Widget build(BuildContext context) {
    // Determine the base style
    final TextStyle baseStyle = style ?? AppTextStyles.bodyMedium;
    final TextStyle finalStyle = baseStyle.copyWith(color: txtColor);

    // Get font size and height factor for height calculation
    // Default height factor in Flutter is usually around 1.2 if not specified
    final double fontSize = finalStyle.fontSize ?? 14.0;
    final double heightFactor = finalStyle.height ?? 1.2;

    Widget textWidget = Text(
      text,
      style: finalStyle,
      textAlign: textAlign ?? TextAlign.start,
      // If 'lines' is provided, it acts as the maxLines constraint as well
      maxLines: maxLines ?? lines ?? 1,
      overflow: overflow ?? ((lines !=null || maxLines != null) ? TextOverflow.ellipsis : null),
    );

    // If 'lines' is specified, wrap in a SizedBox to reserve that space
    if (lines != null) {
      return SizedBox(
        height: fontSize * heightFactor * lines!,
        child: textWidget,
      );
    }

    return textWidget;
  }
}
