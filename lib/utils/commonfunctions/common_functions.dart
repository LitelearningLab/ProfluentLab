import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/API/api_functions.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:provider/provider.dart';

Timer? mainCatTimer;
Duration _timeSpent = Duration.zero;
String mianCategoryTitile = "";
String sessionName = "";
String type = "";
String activityName = "";
bool isTimerActive = false;
bool resume = true;
Timer? subCatTimer;
Duration _subTimeSpent = Duration.zero;
String subCategoryTitile = "";
bool _subIsTimerActive = false;
bool subResume = true;
DateTime startTime = DateTime.now();
List<Map<String, DateTime>> timings = [];
DateTime startTimings = DateTime.now();
DateTime endTimings = DateTime.now();
int count = 0;
String sessionName2 = "";

Duration finalSubDuartion = Duration.zero;
Duration finalDuration = Duration.zero;

void startTimerMainCategory(String name) {
  log("entering to the start timer main category");
  // mianCategoryTitile = name;
  if (!isTimerActive) {
    count = 1;
    startTimings = DateTime.now();
    timings = [];
    startTime = DateTime.now();
    isTimerActive = true;
    mainCatTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resume) {
        _timeSpent += const Duration(seconds: 1);
        log("time spend inside the startermain category $_timeSpent");
      }
    });
  }
}

stopTimerMainCategory() async {
  if (isTimerActive) {
    // if (count == 1) {
    // endTimings = DateTime.now();
    recordTiming("state");
    // }
    resume = true;

    // recordTiming("state");
    mainCatTimer?.cancel();
    isTimerActive = false;
    finalDuration = _timeSpent;
    _timeSpent = Duration.zero;
    await startPracticeTime(
      duration: finalDuration,
      mainCategory: mianCategoryTitile,
      subCategory: subCategoryTitile, type: sessionName,
      activityName: activityName,
      topicNames: [],
      // sessionName: sessionName
    );
    activityName = "";

    log("printing the timing is working or not $finalDuration ${mianCategoryTitile}");
  }
}

void recordTiming(String state) {
  if (resume) {
    endTimings = DateTime.now();
    resume = false;
    subResume = false;

    Map<String, DateTime> timingEntry = {
      "startTime${count}": startTimings,
      "endTime${count}": endTimings
    };

    timings.add(timingEntry);
    count++;
  }
}

void startTimerSubCategory(String name, String sub) {
  // if (mainCatTimer.) {
  //   stopTimerMainCategory();
  // }
  // mianCategoryTitile = name;
  subCategoryTitile = sub;
  if (!_subIsTimerActive) {
    _subIsTimerActive = true;
    subCatTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (subResume) {
        _subTimeSpent += const Duration(seconds: 1);
        // log("time spend inside the sub category $_subTimeSpent");
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
    // await startPracticeTime(
    //     finalSubDuartion, mianCategoryTitile, subCategoryTitile);
    log("printing the timing is working or not $finalSubDuartion ${subCategoryTitile}");
  }
  ;
}

// Future<void> checkUserAndCompanyStatus(BuildContext context) async {
//   String mobileNumber = await SharedPref.getSavedString("mobile");

//   if (mobileNumber.isNotEmpty || mobileNumber != '') {
//     log("printing mobile number is not empty");
//     try {
//       // Your existing verification code
//       final QuerySnapshot userResult = await FirebaseFirestore.instance
//           .collection('UserNode')
//           .where('mobile', isEqualTo: mobileNumber)
//           .limit(1)
//           .get();

//       if (userResult.docs.isNotEmpty) {
//         final userDoc = userResult.docs.first;
//         final userData = userDoc.data() as Map<String, dynamic>;
//         final String? companyId = userData['companyid'];
//         final String? userStatus = userData['status'];

//         // Check user status
//         if (userStatus != "1") {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text("User is inactive.",
//                 style: TextStyle(color: Colors.white)),
//             backgroundColor: Color(0XFF34425D),
//           ));
//           AuthState authState = Provider.of<AuthState>(context, listen: false);
//           authState.chnageAuthState();
//           return;
//         }

//         // Check if companyId exists
//         if (companyId == null || companyId.isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text("Company not associated with this user.",
//                 style: TextStyle(color: Colors.white)),
//             backgroundColor: Color(0XFF34425D),
//           ));
//           return;
//         }

//         // Get company document
//         final QuerySnapshot companyDoc = await FirebaseFirestore.instance
//             .collection('UserNode') // Note: Should this be 'CompanyNode'?
//             .where('_id', isEqualTo: companyId)
//             .limit(1)
//             .get();
//         log("printing checking what is coming");
//         if (companyDoc.docs.isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text("Associated company not found.",
//                 style: TextStyle(color: Colors.white)),
//             backgroundColor: Color(0XFF34425D),
//           ));
//           return;
//         } else {
//           final companydoc = companyDoc.docs.first;
//           final companydocData = companydoc.data() as Map<String, dynamic>;
//           final String? companyStatus = companydocData['status'];
//           log("printing the company status ${companyStatus}");

//           if (companyStatus != "1") {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//               content: Text("Company is inactive.",
//                   style: TextStyle(color: Colors.white)),
//               backgroundColor: Color(0XFF34425D),
//             ));
//             AuthState authState =
//                 Provider.of<AuthState>(context, listen: false);
//             authState.chnageAuthState();
//             return;
//           }
//         }
//       }

//       // If everything is valid, update last check timestamp
//       // await prefs.setInt(kLastStatusCheckKey, now);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text("Error verifying status: ${e.toString()}",
//             style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.red,
//       ));
//     }
//   }
// }
