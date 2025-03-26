import 'package:flutter/cupertino.dart';

class KeysToBeInherited extends InheritedWidget {
  final GlobalKey profileKey;
  final GlobalKey menuBarKey;
  final GlobalKey homeKey;
  final GlobalKey processLearningKey;
  final GlobalKey arCallKey;
  final GlobalKey proFluentEnglishKey;
  final GlobalKey performanceTracking;

  KeysToBeInherited({
    required this.profileKey,
    required this.menuBarKey,
    required this.homeKey,
    required this.processLearningKey,
    required this.arCallKey,
    required this.proFluentEnglishKey,
    required this.performanceTracking,
    required Widget child,
  }) : super(child: child);

  static KeysToBeInherited? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType(aspect: KeysToBeInherited);
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    return true;
  }
}
