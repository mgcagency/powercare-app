import 'package:flutter/material.dart';

import '../api/api_client.dart';

class GlobalErrorHandler {
  static void handleError(BuildContext context, Object error) {
    String message = 'Something went wrong';
    if (error is ApiException) {
      message = error.message;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: CustomText(message)),
    );
  }
}
