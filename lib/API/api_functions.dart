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
import 'dart:developer';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:litelearninglab/API/api.dart';
import 'package:http/http.dart' as http;
import 'package:litelearninglab/utils/shared_pref.dart';

Future startPracticeTime(Duration practiceTime, String mainTitle, String subTitle) async {
  String userId = await SharedPref.getSavedString('userId');
  String url = baseUrl + learningHoursRecordApi;
  var body = {
    "userid": userId,
    "totalPracticeTime": practiceTime.toString(),
    "date": DateTime.now().toString(),
    "leveloneCategory": mainTitle,
    "leveltwoCategory": subTitle
  };

  log("startPracticeTime url: ${url}${body}");

  try {
    var response = await http.post(Uri.parse(url), body: body);

    if (kDebugMode) {
      log("response of startPractice Time: ${response.body}");
      log("response of startPractice Time statuscode: ${response.statusCode}");
    }
    if (response.statusCode == 200) {
      log("statuscode 200");
    }
  } catch (e) {
    if (kDebugMode) {
      log("Error:$e");
    }
  }
}
