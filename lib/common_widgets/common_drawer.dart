import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/screens/login/new_login_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:provider/provider.dart';

import '../constants/keys.dart';
import '../screens/profile/profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/webview/webview_screen.dart';

class CommonDrawer extends StatefulWidget {
  CommonDrawer({Key? key}) : super(key: key);

  @override
  State<CommonDrawer> createState() => _CommonDrawerState();
}

class _CommonDrawerState extends State<CommonDrawer> {
  double kHeight = 0.0;
  double kWidth = 0.0;
  String aboutLiteLearningLink = "";
  String copyRightLink = "";
  String helpLink = "";
  String overViewLink = "";
  late TextScaler kText;

  @override
  void initState() {
    getMenuLinks();
    super.initState();
  }

  getMenuLinks() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('menuLinks')
        .doc('GKgZsIkbxXP5QIYbmchd')
        .get();

    aboutLiteLearningLink = documentSnapshot.get('aboutLiteLearningLab');
    copyRightLink = documentSnapshot.get('copyright');
    helpLink = documentSnapshot.get('help');
    overViewLink = documentSnapshot.get('overview');
  }

  void exitPopup(BuildContext context) {
    kHeight = MediaQuery.of(context).size.height;
    kWidth = MediaQuery.of(context).size.width;
    kText = MediaQuery.of(context).textScaler;

    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding:
              EdgeInsets.only(left: kWidth / 32.35, right: kWidth / 32.75),
          actionsPadding: EdgeInsets.only(
              right: kWidth / 26.2,
              left: kWidth / 26.2,
              bottom: kHeight / 28.4),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: Text(
            'Log out',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          content: Text(
            'Are you sure want to log out?',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          actions: [
            SizedBox(
              width: kWidth / 2.5,
              child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: kText.scale(15)),
                  )),
            ),
            SizedBox(
              width: kWidth / 2.5,
              child: TextButton(
                  onPressed: () async {
                    AuthState controller =
                        Provider.of<AuthState>(context, listen: false);
                    await controller.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              NewLoginScreen()), // Your home page
                      (Route<dynamic> route) =>
                          false, // Remove all previous routes
                    );
                  },
                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                      backgroundColor:
                          const MaterialStatePropertyAll(Colors.white),
                      side: MaterialStatePropertyAll(
                          BorderSide(width: 1, color: Colors.green))),
                  child: Text('Log out',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: kText.scale(15)))),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Color(0XFF293750),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _tile(
        {required Widget icon, required String menu, Function()? onTap}) {
      return ListTile(
        onTap: onTap,
        leading: icon,
        //  ImageIcon(
        //   icon,
        // color: Colors.grey.shade400,
        // size: 20,
        // ),
        title: Text(menu,
            style: TextStyle(
              fontFamily: Keys.fontFamily,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
              fontSize: 15,
            )),
        // onTap: _logout,
      );
    }

    return Consumer<AuthState>(builder: (context, AuthState user, _) {
      return Drawer(
        child: Container(
          // color: Color(0xff202328),
          color: Color(0xff34425D),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SPH(10),
                ListTile(
                  title: Text("Welcome",
                      style: TextStyle(
                        fontFamily: Keys.fontFamily,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        fontSize: 12,
                      )),
                  subtitle: Text(user.appUser?.UserMname ?? "",
                      style: TextStyle(
                        fontFamily: Keys.fontFamily,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 30,
                      )),
                ),
                SPH(30),
                _tile(
                    icon: Icon(
                      Icons.person,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    menu: "Profile",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen()));
                    }),
                _tile(
                    icon: Image.asset(
                      "assets/images/presentation_icon.png",
                      color: Colors.grey.shade400,
                      height: 18,
                      width: 20,
                    ) /* Icon(
                      Icons.account_box_outlined,
                      color: Colors.grey.shade400,
                      size: 20,
                    )*/
                    ,
                    menu: "About Profluent AR",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InAppWebViewPage(
                                    url: aboutLiteLearningLink,
                                  )));
                    }),
                _tile(
                    icon: Image.asset(
                      "assets/images/feedback.png",
                      color: Colors.grey.shade400,
                      height: 18,
                      width: 20,
                    ),
                    /* icon: Icon(
                      Icons.home,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),*/
                    menu: "Share your feedback with us",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InAppWebViewPage(
                                    url: helpLink,
                                  )));
                    }),
                _tile(
                    icon: Icon(
                      Icons.star,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    menu: "Rate this app",
                    onTap: () {
                      if (Platform.isAndroid || Platform.isIOS) {
                        final appId = Platform.isAndroid
                            ? 'org.mahajob.litelearninglab'
                            : 'org.mahajob.litelearninglab';
                        final url = Uri.parse(
                          Platform.isAndroid
                              ? "market://details?id=$appId"
                              : "https://apps.apple.com/app/id$appId",
                        );
                        launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    }),
                /*_tile(
                    icon: SvgPicture.asset(
                      'assets/images/about.svg',
                      colorFilter: ColorFilter.mode(
                        Colors.grey.shade400,
                        BlendMode.srcIn,
                      ),
                      height: 20,
                    ),
                    menu: "Help",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InAppWebViewPage(
                                    url: helpLink,
                                  )));
                    }),*/
                _tile(
                    icon: Image.asset(
                      "assets/images/user_guide_icon.png",
                      color: Colors.grey.shade400,
                      height: 18,
                      width: 20,
                    ),
                    /*SvgPicture.asset(
                      'assets/images/dashboard.svg',
                      colorFilter: ColorFilter.mode(
                        Colors.grey.shade400,
                        BlendMode.srcIn,
                      ),
                      height: 20,
                    ),*/
                    menu: "User Guide",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InAppWebViewPage(
                                    url: overViewLink,
                                  )));
                    }),
                _tile(
                    icon: Icon(
                      Icons.copyright_rounded,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    menu: "Copyright",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InAppWebViewPage(
                                    url: copyRightLink,
                                  )));
                    }),
                // Spacer(),
                _tile(
                    icon: Icon(
                      Icons.power_settings_new,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    menu: "Logout",
                    onTap: () {
                      exitPopup(context);
                    }
                    /* onTap: () async {
                      await user.signOut();
                    }*/
                    ),
                // SPH(50),
              ],
            ),
          ),
        ),
      );
    });
  }
}
