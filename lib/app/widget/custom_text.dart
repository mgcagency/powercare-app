import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/text_styles.dart';

class CustomText extends StatefulWidget {
  final String text;
  final Color? txtColor;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final int? lines;
  final TextOverflow? overflow;
  final bool enableReadMore;
  final String readMoreText;
  final String readLessText;
  final TextStyle? readMoreStyle;

  const CustomText(
      this.text, {
        super.key,
        this.style,
        this.textAlign,
        this.maxLines,
        this.lines,
        this.enableReadMore = false,
        this.readMoreText = " Read More",
        this.readLessText = " Read Less",
        this.overflow,
        this.txtColor,
        this.readMoreStyle,
      });

  @override
  State<CustomText> createState() => _CustomTextState();
}

class _CustomTextState extends State<CustomText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Determine the base style
    final TextStyle baseStyle = widget.style ?? AppTextStyles.bodyMedium;
    final TextStyle finalStyle = baseStyle.copyWith(color: widget.txtColor);

    // If Read More is disabled, return a standard Text widget
    if (!widget.enableReadMore) {
      return _buildStandardText(finalStyle);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Create a TextSpan to calculate if the text overflows
        final textSpan = TextSpan(text: widget.text, style: finalStyle);

        final textPainter = TextPainter(
          text: textSpan,
          textAlign: widget.textAlign ?? TextAlign.start,
          textDirection: Directionality.of(context),
          maxLines: widget.lines ?? widget.maxLines ?? 2,
        );

        textPainter.layout(maxWidth: constraints.maxWidth);

        // Check if the text exceeds the allowed lines
        if (textPainter.didExceedMaxLines) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.text,
                style: finalStyle,
                textAlign: widget.textAlign ?? TextAlign.start,
                maxLines: _isExpanded ? null : (widget.lines ?? widget.maxLines ?? 2),
                overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Text(
                  _isExpanded ? widget.readLessText : widget.readMoreText,
                  style: widget.readMoreStyle ??
                      finalStyle.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold
                      ),
                ),
              ),
            ],
          );
        } else {
          // Text is short enough, no need for Read More
          return _buildStandardText(finalStyle);
        }
      },
    );
  }

  Widget _buildStandardText(TextStyle finalStyle) {
    final double fontSize = finalStyle.fontSize ?? 14.0;
    final double heightFactor = finalStyle.height ?? 1.2;

    Widget textWidget = Text(
      widget.text,
      style: finalStyle,
      textAlign: widget.textAlign ?? TextAlign.start,
      maxLines: widget.lines ?? widget.maxLines,
      overflow: widget.overflow ?? ((widget.lines != null || widget.maxLines != null) ? TextOverflow.ellipsis : null),
    );

    if (widget.lines != null) {
      return SizedBox(
        height: fontSize * heightFactor * widget.lines!,
        child: textWidget,
      );
    }

    return textWidget;
  }
}