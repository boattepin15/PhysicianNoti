import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/test.dart';
import 'package:flutter_application_1/listmedicine.dart';
import 'package:flutter_application_1/screen/homescreen.dart';
import 'package:flutter_application_1/ui/Addtime.dart';
import 'package:flutter_application_1/ui/Home.dart';

import 'firebase_noti/firebase_api.dart';


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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}