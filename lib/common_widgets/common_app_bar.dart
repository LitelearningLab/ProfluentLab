import 'package:flutter/material.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/dashboard/widgets/search_field.dart';

class CommonAppBar extends StatefulWidget implements PreferredSizeWidget {
  CommonAppBar({
    Key? key,
    required this.title,
    this.fontFamily,
    this.onPressedEvent,
    this.onPressBool,
    this.bottom,
    this.appbarIcon,
    this.isSearch = false,
    this.labType = "",
  })  : preferredSize = Size.fromHeight(64),
        super(key: key);
  @override
  final PreferredSizeWidget? bottom;
  final Size preferredSize; // default is 56.0
  final String title;
  final String? fontFamily;
  final String? appbarIcon;
  final bool? isSearch;
  final String? labType;
  Function()? onPressedEvent;
  bool? onPressBool;
  @override
  State<CommonAppBar> createState() => _CommonAppBarState();
}

class _CommonAppBarState extends State<CommonAppBar> {
  bool isTyping = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: widget.appbarIcon != null
            ? EdgeInsets.only(
                bottom: isSplitScreen
                    ? getFullWidgetHeight(height: 12)
                    : getWidgetHeight(height: kWidth > 500 ? 8 : 12),
              )
            : EdgeInsets.only(
                bottom: isSplitScreen
                    ? getFullWidgetHeight(height: 8)
                    : getWidgetHeight(height: 8)),
        height: isSplitScreen
            ? getFullWidgetHeight(height: 64)
            : getWidgetHeight(height: 64),
        width: MediaQuery.of(context).size.width,
        color: Color(0xFF324265),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.appbarIcon != null
                    ? SizedBox(
                        width: getWidgetWidth(width: 20),
                      )
                    : SPW(displayWidth(context) / 40),
                widget.appbarIcon != null
                    ? Container(
                        padding: kWidth > 500
                            ? EdgeInsets.all(12)
                            : EdgeInsets.all(displayWidth(context) / 37.5),
                        height: isSplitScreen
                            ? getFullWidgetHeight(height: 40)
                            : getWidgetHeight(height: 40),
                        width: getWidgetWidth(width: 40),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [
                              Color(0xFF584EFF),
                              Color(0xFF6C63FE),
                            ])),
                        child: Image.asset(
                          widget.appbarIcon!,
                          height: isSplitScreen
                              ? getFullWidgetHeight(height: 30)
                              : getWidgetHeight(height: 30),
                          color: Colors.white,
                        ),
                      )
                    : IconButton(
                        onPressed: widget.onPressBool != null
                            ? widget.onPressedEvent
                            : () async {
                                Navigator.pop(context);
                                // stopTimerMainCategory();
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();

                                String? lastAcces =
                                    prefs.getString("lastAccess");
                                // if (lastAcces == "NewSoftSkillsScreen") {
                                stopTimerMainCategory();
                                // }
                              },
                        // onPressed: () {
                        //   print("button tapped");
                        //   widget.onPressBool != null ? widget.onPressedEvent : Navigator.pop(context);
                        //
                        //   /* print("backkkkk iconnnn buttoonnnn tapppeddddd");
                        //   // Navigator.of(context).pop();
                        //   Navigator.pop(context, true);*/
                        // },
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),
                widget.appbarIcon != null
                    ? SizedBox(
                        width: getWidgetWidth(width: 14),
                      )
                    : SizedBox(
                        width: getWidgetWidth(width: 5),
                      ),
                Expanded(
                  child: isTyping == false
                      ? Text(
                          widget.title,
                          style: TextStyle(
                              // fontFamily: fontFamily ?? Keys.fontFamily,
                              fontFamily: widget.fontFamily ?? 'Roboto',
                              fontSize: 17.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                              overflow: TextOverflow.ellipsis),
                        )
                      : SearchField(labType: widget.labType!),
                ),
                widget.isSearch! && isTyping == false
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            isTyping = true;
                          });
                        },
                        icon: Icon(Icons.search_rounded, color: Colors.white))
                    : const SizedBox()
              ],
            ),
          ],
        ),
      ),
    );
  }
}
