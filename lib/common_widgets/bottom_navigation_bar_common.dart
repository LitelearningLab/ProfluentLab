import 'package:flutter/material.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:provider/provider.dart';

class BottomNavigationBarCommon extends StatelessWidget {
  const BottomNavigationBarCommon({key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthState>(builder: (context, controller, _) {
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
              BottomNavigationBarItem(icon: ImageIcon(AssetImage(AllAssets.bottomHome)), label: ''),
              BottomNavigationBarItem(icon: ImageIcon(AssetImage(AllAssets.bottomPL)), label: ''),
              BottomNavigationBarItem(icon: ImageIcon(AssetImage(AllAssets.bottomIS)), label: ''),
              BottomNavigationBarItem(icon: ImageIcon(AssetImage(AllAssets.bottomPE)), label: ''),
              BottomNavigationBarItem(icon: ImageIcon(AssetImage(AllAssets.bottomPT)), label: ''),
            ],
            backgroundColor: Color(0xFF34445F),
            currentIndex: controller.currentIndex,
            onTap: (index) {
              controller.changeIndex(index);
              controller.changeSubIndex(0);

              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigation()));
            },
            selectedItemColor: Color(0xFFAAAAAA),
            unselectedItemColor: Color.fromARGB(132, 170, 170, 170),
          ),
        ),
      );
    });
  }
}
