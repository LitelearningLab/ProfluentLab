import 'dart:io';
// import 'dart:js';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/database/SentDatabaseProvider.dart';
import 'package:litelearninglab/database/SentencesDatabaseRepository.dart';
import 'package:litelearninglab/models/Sentence.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/encrypt_data.dart';
import 'package:litelearninglab/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toast/toast.dart';

import '../../main.dart';

Future<void> downloadAll(AuthState downloadController, String load) async {
  loadsFrom.add(load);

  // final downloadController = Provider.of<AuthState>(context, listen: false);

  if (downloadController.isConnected && !downloadController.isAllDownloaded) {
    // downloadController.setIsDownloading(isdownloading: true);
    // setState(() {
    //   isDownloading = true;
    // });
    for (Sentence sentence in downloadController.followUps) {
      SentDatabaseProvider dbb = SentDatabaseProvider.get;
      SentencesDatabaseRepository dbRef = SentencesDatabaseRepository(dbb);

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      // final downloadController = Provider.of<AuthState>(context,listen: false);
      String localPath = await Utils.downloadFile(downloadController,
          sentence.file!, '${sentence.id}.mp3', '$appDocPath/${load}',
          isDownloadError: downloadController.isDownloadError);

      String eLocalPath =
          EncryptData.encryptFile(localPath, downloadController);

      try {
        await File(localPath).delete();
      } catch (e) {}
      await dbRef.setDownloadPath(sentence.id!, eLocalPath);
    }
    SentDatabaseProvider dbb = SentDatabaseProvider.get;
    SentencesDatabaseRepository dbRef = SentencesDatabaseRepository(dbb);
    for (var i = 0; i < downloadController.followUps.length; i++) {
      Sentence sentence = downloadController.followUps[i];
      String? savedPath =
          await dbRef.getDownloadPath(sentence.id!); // Retrieve saved path
      sentence.localPath = savedPath; // Assign localPath
      print(
          "Assigned local path for sentence ${sentence.id}: ${sentence.localPath}");
    }
    // downloadController.setIsDownloading(isdownloading: false);
    downloadController.setIsAllDownloaded(
        isallDownloaded: downloadController.isDownloaded!);

    // setState(() {
    //   isDownloading = false;
    //   isAllDownloaded = downloadController.isDownloaded!;
    // });
  } else {
    Toast.show("No network connection",
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
        backgroundColor: AppColors.white,
        textStyle: TextStyle(color: AppColors.black),
        backgroundRadius: 10);
  }
}
