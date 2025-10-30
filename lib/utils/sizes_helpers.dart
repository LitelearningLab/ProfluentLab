import 'dart:async';

import 'package:flutter/material.dart';
import 'package:litelearninglab/utils/split_screen.dart';

Size displaySize(BuildContext context) {
  //debugPrint('Size = ' + MediaQuery.of(context).size.toString());
  return MediaQuery.of(context).size;
}

double displayHeight(BuildContext context) {
  //debugPrint('Height = ' + displaySize(context).height.toString());
  return displaySize(context).height;
}

double displayWidth(BuildContext context) {
  // debugPrint('Width = ' + displaySize(context).width.toString());
  return displaySize(context).width;
}

double globalFontSize(double fontSize, BuildContext context) {
  TextScaler text = MediaQuery.of(context).textScaler;
  return text.scale(fontSize);
}

Size size = Size(0, 0);

double getWidgetHeight({required double height}) {
  double variableHeightValue = 812 / height;
  return kHeight / variableHeightValue;
}

double getWidgetWidth({required double width}) {
  double variableWidthValue = 375 / width;
  return kWidth / variableWidthValue;
}

double getFullWidgetHeight({required double height}) {
  double variableHeightValue = 812 / height;
  return fullScreenHeight / variableHeightValue;
}

double kHeight = 0.0;
double kWidth = 0.0;
double fullScreenHeight = 805.33;
late TextScaler kText;
bool isSplitScreen = false;

getIsSplit(BuildContext context) async {
  isSplitScreen = MediaQuery.of(context).size.height < 500;
  print('is split screen $isSplitScreen');
  return isSplitScreen;
}
