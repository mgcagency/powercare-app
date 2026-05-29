import 'package:flutter/material.dart';

class CustomImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? placeholder;
  final bool isCircle;
  final double? borderRadius;

  const CustomImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.isCircle = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return placeholder != null
            ? Image.asset(
          placeholder!,
          width: width,
          height: height,
          fit: fit,
        )
            : Icon(Icons.broken_image, size: width ?? 50);
      },
    );

    // 🔵 Circle clip
    if (isCircle) {
      return ClipOval(child: image);
    }

    // 🔲 Rounded rectangle
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius!),
        child: image,
      );
    }

    return image;
  }
}
