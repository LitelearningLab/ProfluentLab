import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  BackgroundWidget(
      {Key? key,
      required this.body,
      this.appBar,
      this.drawer,
      this.bottomNav,
      this.floatingActionButton,
      this.scaffoldKey,
      this.getPopScope})
      : super(key: key);
  final Widget body;
  final Widget? bottomNav;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Widget? getPopScope;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        // backgroundColor: Color(0xff202328),
        backgroundColor: Color(0xff293750),
        body: body,
        appBar: appBar,
        endDrawer: drawer,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNav,
      ),
    );
  }
}
