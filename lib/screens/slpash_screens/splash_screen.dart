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

class _SplashScreenState extends State<SplashScreen>
    with AfterLayoutMixin<SplashScreen>, TickerProviderStateMixin {
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
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
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
    if (kIsWeb) {
      // Web Index Style UI
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1F2D3D),
                Color(0xFF293750),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ APP LOGO
              Image.asset(
                "assets/images/profluent_ar_icon.png", // make sure this exists
                width: 120,
                height: 120,
              ),

              const SizedBox(height: 24),

              // ✅ WHITE SPINNER (MATCH WEB)
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              // ✅ APP NAME (MATCH WEB STYLE)
              const Text(
                "Profluent AR",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Mobile-style animated Lottie splash
      return Scaffold(
          body: Container(
              color: Colors.white,
              padding: EdgeInsets.zero,
              height: kHeight,
              width: kWidth,
              child: Lottie.asset("assets/images/Anima-new-reso.json")));
    }
  }
}
