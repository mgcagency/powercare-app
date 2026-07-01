import 'package:flutter/material.dart';

class AppFrame extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const AppFrame({
    super.key,
    required this.child,
    this.maxWidth = 430, // iPhone Pro Max width
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Phone
        if (constraints.maxWidth <= maxWidth) {
          return child;
        }

        // Tablet/Desktop
        return ColoredBox(
          color: Colors.black12, // Background outside your app
          child: Center(
            child: SizedBox(
              width: maxWidth+200,
              height: constraints.maxHeight,
              child: Material(
                elevation: 8,
                clipBehavior: Clip.hardEdge,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}