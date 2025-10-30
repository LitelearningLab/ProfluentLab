import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceScreenInfo {
  static String getDevicePlatform() {
    if (Platform.isAndroid) {
      return Keys.android;
    } else if (Platform.isIOS) {
      return Keys.iOS;
    }
    return "Not Sure";
  }

  static Future<String> osVersion() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;
      return "Android $release (SDK $sdkInt)";
    } else if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var systemName = iosInfo.systemName;
      var version = iosInfo.systemVersion;
      return "$systemName $version";
    }
    return "Not Sure";
  }

  static Future<String> getModelName() async {
    if (Platform.isAndroid) {
      try {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        var manufacturer = androidInfo.manufacturer;
        var model = androidInfo.model;
        return "$manufacturer $model";
      } on Exception catch (e) {
        print(e.toString());
        return "";
      }
    } else if (Platform.isIOS) {
      try {
        var iosInfo = await DeviceInfoPlugin().iosInfo;
        var name = iosInfo.name;
        var model = iosInfo.utsname.machine;
        return "$name $model";
      } on Exception catch (e) {
        print(e.toString());
        return "";
      }
    }
    return "Not Sure";
  }

  static Future<String> getAppVersion() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      return info.version;
    } on Exception catch (e) {
      print(e.toString());
      return "";
    }
  }
}
