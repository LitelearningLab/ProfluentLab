import 'package:flutter/material.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
class ScreenUtil {
  static Future<bool> isSplitScreenMode(BuildContext context) async {
    final screenSize = MediaQuery.of(context).size;
    double height = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height;
    bool isFirst = await SharedPref.getSavedBool('isFirst') ?? true;
    print('is First :$isFirst');
    double? displayHeight;
    if (isFirst) {
      await SharedPref.saveDouble('ScreenSize', height * 0.4);
      await SharedPref.saveBool('isFirst', false);
    }
    displayHeight = await SharedPref.getSavedDouble('ScreenSize');
    print('Width is ${screenSize.width}');
    print('Height is ${screenSize.height}');
    print('Display height is ${displayHeight}');
    return screenSize.height < displayHeight;
  }
}