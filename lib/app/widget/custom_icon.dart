import 'package:flutter/cupertino.dart';

class CustomIcon extends StatelessWidget {
  final String path;
  final double size;
  final Color? color;

  const CustomIcon({
    super.key,
    required this.path,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: size,
      height: size,
      color: color,
    );
  }
}
