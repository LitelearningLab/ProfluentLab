import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:litelearninglab/common_widgets/background_widget.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/screens/dashboard/new_dashboard.dart';
import 'package:litelearninglab/screens/dashboard/show_case_keys.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _processLearningKey = GlobalKey();
  final GlobalKey _arCallKey = GlobalKey();
  final GlobalKey _proFluentEnglishKey = GlobalKey();
  final GlobalKey _performanceTrackingKey = GlobalKey();

  bool OneTimeShowCase = false;
  bool isFirstTimeUser = true;
  bool isLoading = false;

  @override
  void initState() {
    print("didjgi");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDashboardScreen =
        Provider.of<AuthState>(context, listen: false).currentIndex == 0;
    print("isDashboardScreen:${isDashboardScreen}");
    final getKeys = KeysToBeInherited.of(context);
    final size = MediaQuery.of(context).size;
    return BackgroundWidget(
      body: Consumer<AuthState>(
        builder: (context, controller, _) {
          print("checkeddd1");
          return Scaffold(
            body: controller.pages[controller.currentIndex],
            bottomNavigationBar: Container(
              child: BottomNavigationBar(
                enableFeedback: false,
                selectedFontSize: 0,
                unselectedFontSize: 0,
                iconSize: 24,
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                      icon: ImageIcon(AssetImage(AllAssets.bottomHome)),
                      label: 'Home'),
                  BottomNavigationBarItem(
                      icon: ImageIcon(AssetImage(AllAssets.bottomPL)),
                      label: ''),
                  BottomNavigationBarItem(
                      icon: ImageIcon(AssetImage(AllAssets.bottomIS)),
                      label: ''),
                  BottomNavigationBarItem(
                      icon: ImageIcon(AssetImage(AllAssets.bottomPE)),
                      label: ''),
                  BottomNavigationBarItem(
                      icon: ImageIcon(AssetImage(AllAssets.bottomPT)),
                      label: ''),
                ],
                backgroundColor: Color(0xFF34445F),
                currentIndex: controller.currentIndex,
                onTap: (index) {
                  controller.changeIndex(index);
                  print("selected Index:${index}");
                },
                selectedItemColor: Color(0xFFAAAAAA),
                unselectedItemColor: Color.fromARGB(132, 170, 170, 170),
              ),
            ),
          );
        },
      ),
    );
  }
}
