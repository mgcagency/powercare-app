import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'core/services/notification_service.dart';
import 'core/socket/socket_manager.dart';
import 'core/storage/app_preferences.dart';
import 'flavor_config.dart';
import 'main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // // Initialize Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  //
  // // Set background messaging handler early
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  //
  // // Initialize Notification Service
  // await NotificationService().init();
  
  FlavorConfig.setFlavor(
    Flavor.dev,
    'PowerCare Dev',
    'http://192.168.1.3:3000/api',
    'http://192.168.1.3:3000',
  );
  

  runApp(const PowerCareApp());
}
