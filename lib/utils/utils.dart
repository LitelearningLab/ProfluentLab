import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:provider/provider.dart';

class Utils {
  static const platform = const MethodChannel('lite');

  static String convertTime(String timeString, {isTimeOnly = false}) {
    DateFormat inputFormat = DateFormat('HH:mm:ss');
    DateFormat outputFormat = DateFormat('hh:mm a');

    // DateTime dateTime = inputFormat.parse(timeString);
    if (!isTimeOnly) {
      return outputFormat.format(DateTime.parse(timeString));
    } else {
      return outputFormat.format(inputFormat.parse(timeString));
    }
  }

  static Future<String> getUUID() async {
    try {
      return await platform.invokeMethod('getUID');
    } on PlatformException catch (e) {
      print(e);
    }
    print("_uid");
    return "";
  }

  static Future<String> downloadFile(
    final downloadController,
    // dynamic? context,
    String url,
    String fileName,
    String dir, {
    bool? isDownloadError,
  }) async {
    // if (context!) {
    // final downloadController = Provider.of<AuthState>(context!, listen: false);
    // }
    print("url");
    print(url);
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = '';
    String myUrl = '';

    try {
      myUrl = url;
      var request = await httpClient.getUrl(Uri.parse(myUrl));
      var response = await request.close();
      if (response.statusCode == 200) {
        print('/////////////////TRUE');
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '$dir/$fileName';
        print("///////////////Download File path : $filePath *****************");
        file = await File(filePath).create(recursive: true);
        await file.writeAsBytes(bytes);
        downloadController.isDownloaded = true;
      } else {
        print('/////////////////FALSE');
        filePath = 'Error code: ' + response.statusCode.toString();
        downloadController.isDownloaded = false;
      }
    } catch (ex) {
      print('/////////////Can not fetch url : $ex *********************');
      downloadController.isDownloaded = false;
      // filePath = null;
      // downloadController.isDownloaded = false;
      // filePath = '/////////////Can not fetch url : $ex *********************';
      ///g!ZS84%8t=QFR
    }
    print("File Path : : : ${filePath}");
    print("file>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> : isDownloaded : ${downloadController.isDownloaded}");

    return filePath;
  }
}
