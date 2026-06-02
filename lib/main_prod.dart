import 'package:flutter/material.dart';
import 'core/socket/socket_manager.dart';
import 'flavor_config.dart';
import 'main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // // Initialize Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  //
  FlavorConfig.setFlavor(
    Flavor.prod,
    'PowerCare',
    'https://hla-frontend.resolveddevelopment.co.uk//api', // Using existing dev/local URL from AppConstants
    'https://hla-frontend.resolveddevelopment.co.uk/',    // Replace with your production Socket URL
  );



  runApp(const PowerCareApp());
}
