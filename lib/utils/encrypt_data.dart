import 'dart:io';

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:provider/provider.dart';

class EncryptData {
  static String encryptFile(String path,AuthState state) {
    //AuthState state = Provider.of<AuthState>(context, listen: false);
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.on);
    print(state.eKey);
    crypt.setPassword(state.eKey!);

    String encFilepath;
    try {
      encFilepath = crypt.encryptFileSync(path);
      print('The encryption has been completed successfully.');
      print('Encrypted file: $encFilepath');
    } catch (e) {
      // if (e.type == AesCryptExceptionType.destFileExists) {
      //   print('The encryption has been completed unsuccessfully.');
      //   print(e);
      // } else {
      return 'ERROR';
      // }
    }
    return encFilepath;
  }

  static String decryptFile(String path, BuildContext context)  {
    AuthState state = Provider.of<AuthState>(context, listen: false);
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.on);
    crypt.setPassword(state.eKey!);
    String decFilepath;
    try {
      decFilepath = crypt.decryptFileSync(path);
      print('The decryption has been completed successfully.');
      print('Decrypted file 1: $decFilepath');
      print('File content: ' + File(decFilepath).path);
    } catch (e) {
      // if (e.type == AesCryptExceptionType.destFileExists) {
      //   print('The decryption has been completed unsuccessfully.');
      //   print(e.message);
      // } else {
      return 'ERROR';
      // }
    }
    return decFilepath;
  }
}
