import 'package:flutter/material.dart';

class IndiactorController extends ChangeNotifier {
  int selectedIndex = 0;
  changeIndex(int? newIndex) {
    selectedIndex = newIndex ?? 0;
    notifyListeners();
  }
}
