import 'package:flutter/material.dart';
import '../theme/colors.dart';

class CustomLoader extends StatelessWidget {
  final String? message;

  const CustomLoader({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            SizedBox(height: 12),
            Text(message!)
          ]
        ],
      ),
    );
  }
}
