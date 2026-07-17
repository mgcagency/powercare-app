import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'core/services/notification_service.dart';
import 'core/socket/socket_manager.dart';
import 'core/storage/app_preferences.dart';
import 'flavor_config.dart';
import 'main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options_dev_old.dart';

import 'package:package_info_plus/package_info_plus.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setFlavor(
    Flavor.dev,
    'PowerCare Dev',
    'https://powercare.resolveddevelopment.co.uk/api',
    'https://powercare.resolveddevelopment.co.uk',
  );
  print('STARTING DEV APP');

  // Initialize Firebase
  await Firebase.initializeApp(
   options: DefaultFirebaseOptions.currentPlatform,
  );
/*  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }*/
  // Set background messaging handler early
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Notification Service
  await NotificationService().init();


  final info = await PackageInfo.fromPlatform();

  print("✅ Package Name: ${info.packageName}");
  print("✅ App Name: ${info.appName}");
  print("✅ Version: ${info.version}");


  runApp(const PowerCareApp());
}
