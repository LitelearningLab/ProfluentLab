import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/ReminderNotification.dart';

final BehaviorSubject<ReminderNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReminderNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

Future<void> initNotifications(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('notification');
  var initializationSettingsIOS = const DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    selectNotificationSubject.add(payload?.payload ?? "");
  });
}

/*Future<void> showNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, String title, String body) async {
  var androidPlatformChannelSpecifics =
      const AndroidNotificationDetails('0', 'Natalia',
          channelDescription: 'your channel description',
          icon: 'notification',
          // sound: RawResourceAndroidNotificationSound('alert_call_tune'),
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  var iOSPlatformChannelSpecifics =
      // const IOSNotificationDetails(sound: 'alert_call_tune.aiff');
      const DarwinNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(0, title, body, platformChannelSpecifics, payload: 'item x');
}*/

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

Future<void> showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String title,
    String body,
    {String? imageUrl}) async {
  // Initialize Android notification details
  AndroidNotificationDetails androidPlatformChannelSpecifics;

  if (imageUrl != null && imageUrl.isNotEmpty) {
    // Download the image
    final String largeIconPath =
        await _downloadAndSaveFile(imageUrl, 'largeIcon');

    // Use BigPictureStyleInformation for displaying the image
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(largeIconPath),
    );

    androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '0',
      'Natalia',
      channelDescription: 'your channel description',
      icon: 'notification',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: bigPictureStyleInformation,
    );
  } else {
    // If there's no image, use regular notification details
    androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      '0',
      'Natalia',
      channelDescription: 'your channel description',
      icon: 'notification',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
  }

  // iOS notification details
  var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

  // Platform-specific notification details
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  // Show the notification
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

Future<void> turnOffNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

Future<void> turnOffNotificationById(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    num id) async {
  await flutterLocalNotificationsPlugin.cancel(id.toInt());
}

Future<void> scheduleNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String id,
    String body,
    DateTime scheduledNotificationDateTime) async {
  // Initialize time zones if not already done
  tz.initializeTimeZones();
  final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    id,
    'Reminder notifications',
    channelDescription: 'Remember about it',
    icon: 'notification',
    // sound: const RawResourceAndroidNotificationSound('alert_call_tune'),
  );
  var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);

  // await flutterLocalNotificationsPlugin.zonedSchedule(
  //   0,
  //   'Reminder',
  //   body,
  //   tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
  //   platformChannelSpecifics,
  //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //   // uiLocalNotificationDateInterpretation:
  //   //     UILocalNotificationDateInterpretation.absoluteTime,
  // );
}

Future<void> scheduleNotificationPeriodically(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String id,
    String body,
    RepeatInterval interval) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    id,
    'Reminder notifications',
    channelDescription: 'Remember about it',
    icon: 'notification',
  );
  var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.periodicallyShow(
      0, 'Reminder', body, interval, platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
}

void requestIOSPermissions(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}
