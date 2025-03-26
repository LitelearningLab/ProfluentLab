import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget {
  AppConfig({
    required this.appName,
    required this.flavorName,
    required this.fcmKey,
    required Widget child,
  }) : super(child: child);

  final String appName;
  final String flavorName;
  final String fcmKey;

  static AppConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
