/*
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:litelearninglab/API/api.dart';

Future startPracticeTime() async{
  String url = baseUrl + startPractice;
  print("startPracticeTime url: ${url}");
  try{
    var response = await http.post(Uri.parse(url),body: {});
    if(kDebugMode){
      print("response of startPractice Time: ${response.body}");
      print("response of startPractice Time statuscode: ${response.statusCode}");
    }
    if(response.statusCode == 200){
      print("statuscode 200");
    }
  }catch(e){
    if(kDebugMode){
      print("Error:$e");
    }
  }
}

Future endPracticeTime() async{
  String url = baseUrl + endPractice;
  print("endPracticeTime url: ${url}");
  try{
    var response = await http.post(Uri.parse(url),body: {});
    if(kDebugMode){
      print("response of endPractice Time: ${response.body}");
      print("response of endPractice Time statuscode: ${response.statusCode}");
    }
    if(response.statusCode == 200){
      print("statuscode 200");
    }
  }catch(e){
    if(kDebugMode){
      print("Error:$e");
    }
  }
}*/
import 'dart:async';
import 'dart:developer';

// Future startPracticeTime(Duration practiceTime, String mainTitle, String subTitle) async {
//   String userId = await SharedPref.getSavedString('userId');
//   String url = baseUrl + learningHoursRecordApi;
//   var body = {
//     "userid": userId,
//     "totalPracticeTime": practiceTime.toString(),
//     "date": DateTime.now().toString(),
//     "leveloneCategory": mainTitle,
//     "leveltwoCategory": subTitle
//   };

//   log("startPracticeTime url: ${url}${body}");

//   try {
//     var response = await http.post(Uri.parse(url), body: body);

//     if (kDebugMode) {
//       log("response of startPractice Time: ${response.body}");
//       log("response of startPractice Time statuscode: ${response.statusCode}");
//     }
//     if (response.statusCode == 200) {
//       log("statuscode 200");
//     }
//   } catch (e) {
//     if (kDebugMode) {
//       log("Error:$e");
//     }
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:litelearninglab/utils/shared_pref.dart';

Future<void> startPracticeTime({
  required Duration duration,
  required String mainCategory,
  required String subCategory,
  required String sessionName,
}) async {
  try {
    // 1. Check network connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('No internet connection. Please check your network.');
    }

    // 2. Validate all inputs
    if (duration.inSeconds <= 0)
      throw ArgumentError('Duration must be positive');
    if (mainCategory.isEmpty) throw ArgumentError('Main category is required');
    if (subCategory.isEmpty) throw ArgumentError('Sub category is required');
    if (sessionName.isEmpty) throw ArgumentError('Session name is required');

    // 3. Get authenticated user ID
    final userId = await SharedPref.getSavedString('userId');
    if (userId.isEmpty) throw Exception('User not authenticated');

    // 4. Configure Firestore
    final firestore = FirebaseFirestore.instance;
    firestore.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // 5. Prepare document reference
    final docRef = firestore
        .collection('processLearningTimeStamp')
        .doc(userId)
        .collection(subCategory)
        .doc(sessionName);

    // 6. Prepare session data
    final sessionData = {
      'duration': duration.inSeconds,
      'time': DateTime.now(),
      // 'timestamp': FieldValue.serverTimestamp(),
      'mainCategory': "Process Learning",
      'subCategory': subCategory,
    };

    // 7. Execute with retry logic
    await _executeWithRetry(() async {
      await firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        final existingData = doc.data() ?? {};

        // Handle sessions array
        final existingSessions =
            (existingData['sessions'] as List?)?.cast<Map<String, dynamic>>() ??
                [];
        final newSessions = [...existingSessions, sessionData];

        // Calculate total time safely
        final totalTime = newSessions.fold<int>(
          0,
          (sum, session) => sum + ((session['duration'] as int?) ?? 0),
        );

        transaction.set(
          docRef,
          {
            'sessions': newSessions,
            'totalPracticeTime': totalTime,
            'lastUpdated': FieldValue.serverTimestamp(),
            'userId': userId,
          },
          SetOptions(merge: true),
        );
      });
    });

    if (kDebugMode) {
      log('✅ Session recorded successfully in $sessionName');
    }
  } on FirebaseException catch (e) {
    log('🔥 Firestore Error: ${e.code} - ${e.message}');
    if (e.code == 'permission-denied') {
      throw Exception('You don\'t have permission to record sessions');
    } else if (e.code == 'unavailable') {
      throw Exception('Firestore service unavailable. Please try again later.');
    }
    throw Exception('Failed to save session data. Error: ${e.message}');
  } on PlatformException catch (e) {
    log('📱 Platform Error: ${e.code} - ${e.message}');
    throw Exception('Device storage issue. Please restart the app.');
  } catch (e, stack) {
    log('❌ Unexpected Error: $e\nStack Trace: $stack');
    throw Exception('An unexpected error occurred. Please try again.');
  }
}

Future<void> _executeWithRetry(Future<void> Function() operation,
    {int maxRetries = 3, Duration delay = const Duration(seconds: 1)}) async {
  for (var i = 0; i < maxRetries; i++) {
    try {
      await operation();
      return;
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(delay);
      log('🔄 Retrying operation (attempt ${i + 2}/$maxRetries)');
    }
  }
}
