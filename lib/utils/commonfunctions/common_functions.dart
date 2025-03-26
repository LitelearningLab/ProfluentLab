import 'dart:async';
import 'dart:developer';

import 'package:litelearninglab/API/api_functions.dart';

Timer? mainCatTimer;
Duration _timeSpent = Duration.zero;
String mianCategoryTitile = "";
bool _isTimerActive = false;
bool resume = true;
Timer? subCatTimer;
Duration _subTimeSpent = Duration.zero;
String subCategoryTitile = "";
bool _subIsTimerActive = false;
bool subResume = true;

Duration finalSubDuartion = Duration.zero;
Duration finalDuration = Duration.zero;

void startTimerMainCategory(String name) {
  mianCategoryTitile = name;
  if (!_isTimerActive) {
    _isTimerActive = true;
    mainCatTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resume) {
        _timeSpent += const Duration(seconds: 1);
        log("time spend inside the startermain category $_timeSpent");
      }
    });
  }
}

stopTimerMainCategory() async {
  if (_isTimerActive) {
    mainCatTimer?.cancel();
    _isTimerActive = false;
    finalDuration = _timeSpent;
    _timeSpent = Duration.zero;
    await startPracticeTime(finalDuration, mianCategoryTitile, "");
    log("printing the timing is working or not $finalDuration ${mianCategoryTitile}");
  }
}

void startTimerSubCategory(String name, String sub) {
  mianCategoryTitile = name;
  subCategoryTitile = sub;
  if (!_subIsTimerActive) {
    _subIsTimerActive = true;
    subCatTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (subResume) {
        _subTimeSpent += const Duration(seconds: 1);
        log("time spend inside the sub category $_subTimeSpent");
      }
    });
  }
}

stopTimerSubCategory() async {
  if (_subIsTimerActive) {
    subCatTimer?.cancel();
    _subIsTimerActive = false;
    finalSubDuartion = _subTimeSpent;
    _subTimeSpent = Duration.zero;
    await startPracticeTime(finalSubDuartion, mianCategoryTitile, subCategoryTitile);
    log("printing the timing is working or not $finalSubDuartion ${subCategoryTitile}");
  }
  ;
}
