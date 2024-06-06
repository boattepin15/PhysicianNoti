import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/noti/local_notifications.dart';
import 'package:flutter_application_1/ui/Home.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_noti/firebase_api.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid? await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCgI9yGbpdcU0IZaTZI2Mbqc6x3m_5PBEU',
       appId: '1:56220203122:android:f08592288dd8f8f887aaeb', 
       messagingSenderId: '56220203122', 
       projectId: 'flutter-project-b8a70')
  )
  : await Firebase.initializeApp();
  await FirebaseApi().initNotifications();
  
  // ทำให้เมื่อกดเข้ามาจะเข้าหน้าหลัก
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotifications.init();

  // handle in terminated state
  var initialNotification =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (initialNotification?.didNotificationLaunchApp == true) {
    // LocalNotifications.onClickNotification.stream.listen((event) {
    Future.delayed(Duration(seconds: 1), () {
      // print(event);
      runApp(const MyApp()); // You might need to handle routing differently here depending on your app structure
    });
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // 22/8/2567 กำหนดเพื่อให้สามารถเลือก startDate endDate ภาษาไทย
      localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
      ],
      // 22/8/2567 
      supportedLocales: [
          const Locale('en', 'US'), // English
          const Locale('th', 'TH'), // Thai
      ],
      home: Home(),
    );
  }
}