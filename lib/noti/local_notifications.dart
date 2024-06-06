import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final onClickNotification = BehaviorSubject<String>();

// on tap on any notification
  static void onNotificationTap(NotificationResponse notificationResponse) {
    print("00000000000000000${onNotificationTap}");
    onClickNotification.add(notificationResponse.payload!);
  }

  static void onNotificationClick(NotificationResponse notificationResponse) {
    print("777777777777777 onNotificationClick ${notificationResponse.id}");
    
    onClickNotification.add(notificationResponse.payload!);
  }

// initialize the local notifications
  static Future init() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) => null,
    );
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);

    // request notification permissions
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestPermission();

    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationClick);
  }

  // show a simple notification
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }

  // to schedule a local notification
  static Future showScheduleNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
  }) async {
    tz.initializeTimeZones();
    DateTime now = DateTime.now();

    // สร้าง DateTime สำหรับวันและเวลาที่กำหนด
    DateTime scheduledDateTime = DateTime(year, month, day, hour, minute);

    // คำนวณหาผลต่างเวลาที่ต้องการให้แจ้งเตือน
    Duration difference = scheduledDateTime.difference(now);
    print(difference);
    print("แก้ไข $id");
    try{

      await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.now(tz.local).add(difference),
          const NotificationDetails(
              android: AndroidNotificationDetails(
                  'channel 3', 'your channel name',
                  channelDescription: 'your channel description',
                  importance: Importance.max,
                  priority: Priority.high,
                  ticker: 'ticker',
                  // ongoing: true,
                  autoCancel: false,
              )),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload);
    }
    catch (e) {
      print("ไม่สามารถตั้งเวลาย้อนหลังได้ $day/$month/$year $hour:$minute");
    }
  }

  static Future<void> printPendingNotifications() async {
    List<PendingNotificationRequest> pendingNotificationRequests = 
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();

    for (var request in pendingNotificationRequests) {
      print('Notification ID: ${request.id}');
      print('Title: ${request.title}');
      print('Body: ${request.body}');
      print('Payload: ${request.payload}');
      }
    }

    static Future<void> cancelNotificationById(int id) async {
      List<PendingNotificationRequest> pendingNotificationRequests = 
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();

      for (var request in pendingNotificationRequests) {
        if (id == request.id){
            print(request.id);
            await _flutterLocalNotificationsPlugin.cancel(request.id);
            break;
        }
      }
    }

  

}
