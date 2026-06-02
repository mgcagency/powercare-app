import 'package:flutter/material.dart';
import 'core/socket/socket_manager.dart';
import 'core/storage/app_preferences.dart';
import 'flavor_config.dart';
import 'main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.init();
  // // Initialize Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  //
  FlavorConfig.setFlavor(
    Flavor.prod,
    'PowerCare',
    'https://powercarecrm.co.uk/api/', // Using existing dev/local URL from AppConstants
    'https://powercarecrm.co.uk/',    // Replace with your production Socket URL
  );



  runApp(const PowerCareApp());
}
