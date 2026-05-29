import 'package:flutter/material.dart';

import 'app/theme/colors.dart';
import 'app/theme/text_styles.dart';
import 'core/navigation/app_navigator.dart';
import 'features/presentation/landing/splash_screen.dart';
import 'flavor_config.dart';


var userRole = [ "admin", "teacher", "student", "parent" ];
var userId = "";
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();



ThemeData appTheme = ThemeData(
  fontFamily: 'Helvetica',
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  textTheme: TextTheme(
    headlineLarge: AppTextStyles.headline1,
    headlineMedium: AppTextStyles.headline2,
    headlineSmall: AppTextStyles.headline3,
    bodySmall: AppTextStyles.bodySmall,
    bodyMedium: AppTextStyles.bodyMedium,
    bodyLarge: AppTextStyles.bodyLarge,
  ),
);

class PowerCareApp extends StatelessWidget {
   const PowerCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FlavorConfig.instance.name,
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      navigatorObservers: [routeObserver],
      navigatorKey: AppNavigator.navigatorKey,
      home: SplashScreen(),
    );
  }
}
// await Firebase.initializeApp(
// options: DefaultFirebaseOptions.currentPlatform,
// );
