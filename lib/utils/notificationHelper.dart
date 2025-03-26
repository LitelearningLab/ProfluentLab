import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';

import '../models/ReminderNotification.dart';

final BehaviorSubject<ReminderNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReminderNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

Future<void> initNotifications(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('notification');
  var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int? id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationSubject.add(ReminderNotification(
            id: id, title: title, body: body, payload: payload));
      });
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
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, String title, String body,
    {String? imageUrl}) async {
  // Initialize Android notification details
  AndroidNotificationDetails androidPlatformChannelSpecifics;

  if (imageUrl != null && imageUrl.isNotEmpty) {
    // Download the image
    final String largeIconPath = await _downloadAndSaveFile(imageUrl, 'largeIcon');

    // Use BigPictureStyleInformation for displaying the image
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
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
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    id,
    'Reminder notifications',
    channelDescription: 'Remember about it',
    icon: 'notification',
    // sound: const RawResourceAndroidNotificationSound('alert_call_tune'),
  );
  var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
  // const IOSNotificationDetails(sound: 'alert_call_tune.aiff');
  const DarwinNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.schedule(0, 'Reminder', body,
      scheduledNotificationDateTime, platformChannelSpecifics);
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
      0, 'Reminder', body, interval, platformChannelSpecifics);
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
