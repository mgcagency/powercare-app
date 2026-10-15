import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Theme & Widgets
import '../../app/theme/colors.dart';
import '../../app/widget/custom_response_dialogs.dart';
import '../../app/widget/custom_text.dart';
import 'route_animation.dart';


class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState get instance => navigatorKey.currentState!;
  static BuildContext get context => navigatorKey.currentContext!;

  /// Check if current screen matches a specific type
  static bool isCurrentScreen<T>() {
    bool isCurrent = false;
    navigatorKey.currentState?.popUntil((route) {
      if (route.settings.name == T.toString()) {
        isCurrent = true;
      }
      return true;
    });
    return isCurrent;
  }

  /// Push
  static Future push(Widget page, {RouteType type = RouteType.slide}) {
    return navigatorKey.currentState!.push(_getRoute(page, type));
  }

  /// Push and replace
  static Future pushReplace(Widget page, {RouteType type = RouteType.slide}) {
    return navigatorKey.currentState!.pushReplacement(_getRoute(page, type));
  }

  /// Push and clear stack
  static Future pushAndRemoveAll(Widget page, {RouteType type = RouteType.fade}) {
    return navigatorKey.currentState!.pushAndRemoveUntil(_getRoute(page, type), (_) => false);
  }

  static PageRoute _getRoute(Widget page, RouteType type) {
    switch (type) {
      case RouteType.fade:
        return RouteAnimation.fade(page);
      case RouteType.scale:
        return RouteAnimation.scale(page);
      default:
        return RouteAnimation.slide(page);
    }
  }

  static void pop([dynamic result]) {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop(result);
    }
  }

  /// ✅ Improved Exit App Confirmation
  static void showExitDialog() {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    showConfirmDialog(
      ctx,
      title: 'Exit App',
      message: 'Do you really want to exit the application?',
      confirmText: 'Exit',
      cancelText: 'Stay',
      icon: Icons.exit_to_app_rounded,
      iconColor: AppColors.primary,
      onConfirm: () {
        if (kIsWeb) {
          ScaffoldMessenger.of(ctx).showSnackBar(
             SnackBar(content: CustomText('Please close the tab manually.',style: TextStyle(color: Colors.white))),
          );
        } else if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          // exit(0) is the only way to hard-close on iOS, 
          // though discouraged for App Store production.
          exit(0);
        } else {
          SystemNavigator.pop();
        }
      },
    );
  }
}

enum RouteType { slide, fade, scale }
