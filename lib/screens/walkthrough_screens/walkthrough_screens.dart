import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/screens/login/login_screen.dart';
import 'package:litelearninglab/screens/login/new_login_screen.dart';
import 'package:litelearninglab/screens/walkthrough_screens/walkthrough_model.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalkThroughView extends StatefulWidget {
  const WalkThroughView({key});

  @override
  State<WalkThroughView> createState() => _WalkThroughViewState();
}

class _WalkThroughViewState extends State<WalkThroughView> {
  double kHeight = 0.0;
  double kWidth = 0.0;
  late TextScaler kText;
  int currentIndex = 0;
  PageController pageController = PageController();
  late AuthState authSatate;
  List pageContent = [
    WalkThrougModel(
        imageUrl: AllAssets.processLearning,
        title: 'Enjoy',
        subTitle: 'RCM & AR Process Learning',
        content:
            "Rich multimedia learning content that's crisp, focused & interesting."),
    WalkThrougModel(
        imageUrl: AllAssets.arCallSimulation,
        title: 'Easy',
        subTitle: 'AR Call Simulations',
        content:
            'Interactive lifelike simulations, to apply learning without real-world consequences.'),
    WalkThrougModel(
        imageUrl: AllAssets.profluentEnglish,
        title: '& Effective',
        subTitle: 'Profluent English',
        content:
            'Fast-track AR call focused upskilling! \nListen to US professionals. Practice \nindependently with AI powered tools.'),
    WalkThrougModel(
        imageUrl: AllAssets.softSkill,
        title: 'Learning',
        subTitle: 'Soft Skills',
        content:
            'Acquire essential skills easily with byte-sized, business-specific modules.'),
  ];

  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);
    setState(() {});
  }

  void changingPage(int page) {
    setState(() {
      currentIndex = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    kHeight = MediaQuery.of(context).size.height;
    kWidth = MediaQuery.of(context).size.width;
    kText = MediaQuery.of(context).textScaler;
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: pageController,
        itemCount: pageContent.length,
        onPageChanged: changingPage,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.only(
                top: isSplitScreen
                    ? getFullWidgetHeight(height: 30)
                    : getWidgetHeight(height: 30)),
            child: Container(
              height: kHeight,
              width: kWidth,
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  SizedBox(
                      height: isSplitScreen
                          ? getFullWidgetHeight(height: 30)
                          : getWidgetHeight(height: 30)),
                  Text(
                    pageContent[index].title,
                    style: TextStyle(fontSize: 40, fontFamily: "Kaushan"),
                  ),
                  SizedBox(
                      height: isSplitScreen
                          ? getFullWidgetHeight(height: 55)
                          : getWidgetHeight(height: 55)),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                        height: isSplitScreen
                            ? getFullWidgetHeight(height: 280)
                            : getWidgetHeight(height: 280),
                        child: Image.asset(pageContent[index].imageUrl)),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: FittedBox(
                      child: Text(
                        pageContent[index].subTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0XFF6B61FE),
                            fontSize: kText.scale(25)),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.only(
                        left: getWidgetWidth(width: 35),
                        right: isSplitScreen
                            ? getFullWidgetHeight(height: 30)
                            : getWidgetHeight(height: 30)),
                    child: Text(
                      pageContent[index].content,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0XFFA8A8A8), fontSize: 16),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: isSplitScreen
                            ? getFullWidgetHeight(height: 50)
                            : getWidgetHeight(height: 50)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (index != pageContent.length - 1)
                          SizedBox(
                            height: isSplitScreen
                                ? getFullWidgetHeight(height: 33)
                                : getWidgetHeight(height: 33),
                            width: getWidgetWidth(width: 90),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0XFFCACACA),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(25),
                                          bottomLeft: Radius.circular(25))),
                                ),
                                onPressed: () async {
                                  print("sdhiajei");
                                  print("cureentIndex:$currentIndex");
                                  if (currentIndex == 0) {
                                    pageController.jumpToPage(1);
                                  } else if (currentIndex == 1) {
                                    pageController.jumpToPage(2);
                                  } else if (currentIndex == 2) {
                                    pageController.jumpToPage(3);
                                  } else {
                                    pageController.jumpToPage(4);
                                  }
                                },
                                child: FittedBox(
                                  child: Text(
                                    "Next >",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                )),
                          )
                        else
                          SizedBox(
                            height: isSplitScreen
                                ? getFullWidgetHeight(height: 33)
                                : getWidgetHeight(height: 33),
                            width: getWidgetWidth(width: 160),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0XFFCACACA),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(25),
                                          bottomLeft: Radius.circular(25))),
                                ),
                                onPressed: () async {
                                  authSatate = Provider.of<AuthState>(context,
                                      listen: false);
                                  print("sdhiajei");
                                  print("cureentIndex:$currentIndex");
                                  // await SharedPref.saveBool("walkthrough", true);
                                  // bool checking = await SharedPref.getSavedBool("walkthrough");
                                  // print("checkinh che e : $checking");
                                  await authSatate.changingWalk();
                                  setState(() {});
                                  // Navigator.push(
                                  //     context, MaterialPageRoute(builder: (context) => NewLoginScreen()));
                                },
                                child: Text(
                                  "Start Learning >",
                                  style: TextStyle(color: Colors.black),
                                )),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
