import 'dart:developer';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/constants/strings.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/background_widget.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with AfterLayoutMixin<SplashScreen>, TickerProviderStateMixin {
  Animation<double>? animation;
  AnimationController? animationController;
  @override
  void initState() {
    if (kDebugMode) {
      printCheckingTheBool();
    }
    super.initState();
  }

  printCheckingTheBool() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstTimeUser = await prefs.getBool('firstTimeUser');
    log("firstTimeUser ${firstTimeUser}");
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);
    setState(() {});
  }

  @override
  void afterFirstLayout(BuildContext context) {
    animationController = AnimationController(vsync: this, duration: Duration(seconds: 3));
    animation = Tween<double>(begin: 1000, end: 0).animate(animationController!)
      ..addListener(() {
        setState(() {});
      });
    animationController?.forward();
  }

  @override
  void dispose() {
    if (animationController != null) animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    kHeight = MediaQuery.of(context).size.height;
    kWidth = MediaQuery.of(context).size.width;
    kText = MediaQuery.of(context).textScaler;
    print("kHeight : $kHeight");
    print("kwidth : $kWidth");
    return Scaffold(
        body:
            Container(color: Colors.white, padding: EdgeInsets.zero, height: kHeight, width: kWidth, child: Lottie.asset("assets/images/Anima-new-reso.json")));
  }
}
