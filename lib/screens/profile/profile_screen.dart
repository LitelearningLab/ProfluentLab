import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:litelearninglab/common_widgets/common_app_bar.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/background_widget.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String city = "";
  String country = "";
  String companyName = "";
  String joinDate = "";
  String endDate = "";
  bool isLoading = false;

  getUserDetails() async {
    isLoading = true;

    city = await SharedPref.getSavedString('newCity');
    country = await SharedPref.getSavedString('newCountry');
    companyName = await SharedPref.getSavedString('companyName') ?? "";
    joinDate = await SharedPref.getSavedString('joinDate') ?? "";
    endDate = await SharedPref.getSavedString("endDate") ?? "";
    print("sdndoo:${city}");
    print("gndg:${country}");
    print("sjgijdigj:${companyName ?? ""}");
    print("sjgijdigknknkj:${joinDate ?? ""}");
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    AuthState userDatas = Provider.of<AuthState>(context, listen: false);
    return BackgroundWidget(
      appBar: CommonAppBar(
        title: "Profile",
        // height: displayHeight(context) / 12.6875,
      ),
      body: isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : ListView(
              children: [
                Container(
                  height: isSplitScreen
                      ? getFullWidgetHeight(height: 100)
                      : getWidgetHeight(height: 100),
                  padding: EdgeInsets.symmetric(
                      horizontal: getWidgetWidth(width: 20),
                      vertical: isSplitScreen
                          ? getFullWidgetHeight(height: 20)
                          : getWidgetHeight(height: 20)),
                  color: Color(0xFF293750),
                  child: Center(
                    child: Text(
                      userDatas.appUser?.UserMname ?? "",
                      style: TextStyle(
                          fontFamily: Keys.fontFamily,
                          color: Colors.white,
                          fontSize: 25),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: getWidgetWidth(width: 10)),
                  child: Container(
                      height: isSplitScreen
                          ? getFullWidgetHeight(height: 50)
                          : getWidgetHeight(height: 50),
                      decoration: BoxDecoration(
                          color: Color(0XFF314162),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(7),
                              topRight: Radius.circular(7))),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0XFF5248fe),
                              child: Image.asset(
                                "assets/images/mobile_profile.png",
                                height: isSplitScreen
                                    ? getFullWidgetHeight(height: 20)
                                    : getWidgetHeight(height: 20),
                                width: getWidgetWidth(width: 20),
                              ),
                            ),
                            SizedBox(width: getWidgetWidth(width: 10)),
                            Text(
                              " +91 ${userDatas.appUser?.mobile ?? ""}",
                              style: TextStyle(
                                  fontFamily: Keys.fontFamily,
                                  color: Colors.white,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ) /* ListTile(
                title: Text(
                  "Company: " + (userDatas.appUser?.company ?? ""),
                  style: TextStyle(fontFamily: Keys.fontFamily, color: Colors.white, fontSize: 15),
                ),
              ),*/
                      ),
                ),
                SizedBox(
                    height: isSplitScreen
                        ? getFullWidgetHeight(height: 3)
                        : getWidgetHeight(height: 3)),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: getWidgetWidth(width: 10)),
                  child: Container(
                      height: isSplitScreen
                          ? getFullWidgetHeight(height: 50)
                          : getWidgetHeight(height: 50),
                      decoration: BoxDecoration(
                        color: Color(0XFF314162),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0XFF47bad0),
                              child: Image.asset(
                                "assets/images/arroba_profile.png",
                                height: isSplitScreen
                                    ? getFullWidgetHeight(height: 15)
                                    : getWidgetHeight(height: 15),
                                width: getWidgetWidth(width: 15),
                              ),
                            ),
                            SizedBox(width: getWidgetWidth(width: 10)),
                            Text(
                              userDatas.appUser?.email ?? "",
                              style: TextStyle(
                                  fontFamily: Keys.fontFamily,
                                  color: Colors.white,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ) /* ListTile(
                title: Text(
                  "Company: " + (userDatas.appUser?.company ?? ""),
                  style: TextStyle(fontFamily: Keys.fontFamily, color: Colors.white, fontSize: 15),
                ),
              ),*/
                      ),
                ),
                SizedBox(
                    height: isSplitScreen
                        ? getFullWidgetHeight(height: 3)
                        : getWidgetHeight(height: 3)),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: getWidgetWidth(width: 10)),
                  child: Container(
                      height: isSplitScreen
                          ? getFullWidgetHeight(height: 50)
                          : getWidgetHeight(height: 50),
                      decoration: BoxDecoration(
                        color: Color(0XFF314162),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0XFF47da6d),
                              child: Image.asset(
                                "assets/images/hierarchical_profile.png",
                                height: isSplitScreen
                                    ? getFullWidgetHeight(height: 15)
                                    : getWidgetHeight(height: 15),
                                width: getWidgetWidth(width: 15),
                              ),
                            ),
                            SizedBox(width: getWidgetWidth(width: 10)),
                            Text(
                              toBeginningOfSentenceCase(
                                      userDatas.appUser?.company ??
                                          companyName) ??
                                  '',
                              style: TextStyle(
                                fontFamily: Keys.fontFamily,
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ) /* ListTile(
                title: Text(
                  "Company: " + (userDatas.appUser?.company ?? ""),
                  style: TextStyle(fontFamily: Keys.fontFamily, color: Colors.white, fontSize: 15),
                ),
              ),*/
                      ),
                ),
                SizedBox(
                    height: isSplitScreen
                        ? getFullWidgetHeight(height: 3)
                        : getWidgetHeight(height: 3)),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: getWidgetWidth(width: 10)),
                  child: Container(
                      height: isSplitScreen
                          ? getFullWidgetHeight(height: 50)
                          : getWidgetHeight(height: 50),
                      decoration: BoxDecoration(
                        color: Color(0XFF314162),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0XFFf5a716),
                              child: Image.asset(
                                "assets/images/maps_flags_profile.png",
                                height: isSplitScreen
                                    ? getFullWidgetHeight(height: 15)
                                    : getWidgetHeight(height: 15),
                                width: getWidgetWidth(width: 15),
                              ),
                            ),
                            SizedBox(width: getWidgetWidth(width: 10)),
                            Text(
                              "${toBeginningOfSentenceCase(city) ?? ''}, ${toBeginningOfSentenceCase(country) ?? ''}",
                              style: TextStyle(
                                fontFamily: Keys.fontFamily,
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ) /* ListTile(
                title: Text(
                  "Company: " + (userDatas.appUser?.company ?? ""),
                  style: TextStyle(fontFamily: Keys.fontFamily, color: Colors.white, fontSize: 15),
                ),
              ),*/
                      ),
                ),
                SizedBox(
                    height: isSplitScreen
                        ? getFullWidgetHeight(height: 3)
                        : getWidgetHeight(height: 3)),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: getWidgetWidth(width: 10)),
                  child: Container(
                      height: isSplitScreen
                          ? getFullWidgetHeight(height: 50)
                          : getWidgetHeight(height: 50),
                      decoration: BoxDecoration(
                          color: Color(0XFF314162),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(7),
                              bottomRight: Radius.circular(7))),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0XFFf66b5c),
                              child: Image.asset(
                                "assets/images/calendar_profile.png",
                                height: isSplitScreen
                                    ? getFullWidgetHeight(height: 15)
                                    : getWidgetHeight(height: 15),
                                width: getWidgetWidth(width: 15),
                              ),
                            ),
                            SizedBox(width: getWidgetWidth(width: 10)),
                            Text(
                              "Active from ${DateFormat('dd-MM-yyyy').format(DateTime.parse(joinDate))} to ${DateFormat('dd-MM-yyyy').format(DateTime.parse(endDate))}",
                              style: TextStyle(
                                  fontFamily: Keys.fontFamily,
                                  color: Colors.white,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ) /* ListTile(
                title: Text(
                  "Company: " + (userDatas.appUser?.company ?? ""),
                  style: TextStyle(fontFamily: Keys.fontFamily, color: Colors.white, fontSize: 15),
                ),
              ),*/
                      ),
                ),
                SizedBox(
                    height: isSplitScreen
                        ? getFullWidgetHeight(height: 16)
                        : getWidgetHeight(height: 16)),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: getWidgetWidth(width: 10),
                      vertical: isSplitScreen
                          ? getFullWidgetHeight(height: 5)
                          : getWidgetHeight(height: 5)),
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(7),
                          topLeft: Radius.circular(
                              7)), // Adjust the radius as needed
                    ),
                    color: Color(0XFF314162),
                    child: ListTile(
                      title: Text(
                        "Your login is tagged to this device, and you cannot use this login in any other mobile phone. If you need to change the mobile number or device, please raise a request through your trainer or manager.",
                        style: TextStyle(
                            fontFamily: Keys.fontFamily,
                            color: Colors.white,
                            fontSize: 15),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: getWidgetWidth(width: 10),
                      vertical: getWidgetHeight(height: 10)),
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    color: Color(0XFF314162),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(7),
                          bottomLeft: Radius.circular(
                              7)), // Adjust the radius as needed
                    ),
                    child: ListTile(
                      title: Text(
                        "Your access validity is based on the subscription status of your employer / institute. If you have any questions on your access validity, please contact your trainer or manager.",
                        style: TextStyle(
                            fontFamily: Keys.fontFamily,
                            color: Colors.white,
                            fontSize: 15),
                      ),
                    ),
                  ),
                ), /* ListTile(
                title: Text(
                  "Company: " + (userDatas.appUser?.company ?? ""),
                  style: TextStyle(fontFamily: Keys.fontFamily, color: Colors.white, fontSize: 15),
                ),
              ),*/ /*
                ),
          ),*/
              ],
            ),
      /*ListView(
        children: [
          Container(
            height: 100,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            color: Color(0xFF293750),
            child: Column(
              children: [
                Text(
                  userDatas.appUser?.UserMname ?? "",
                  style: TextStyle(fontFamily: Keys.fontFamily, color: Colors.white, fontSize: 25),
                ),
                Text(
                  userDatas.appUser?.email ?? "",
                  style: TextStyle(fontFamily: Keys.fontFamily, color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Card(
              child: ListTile(
                title: Text(
                  "Company: " + (userDatas.appUser?.company ?? ""),
                  style: TextStyle(fontFamily: Keys.fontFamily, color: Colors.black, fontSize: 15),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Card(
              child: ListTile(
                title: Text(
                  "Mobile number: " + (userDatas.appUser?.mobile ?? ""),
                  style: TextStyle(fontFamily: Keys.fontFamily, color: Colors.black, fontSize: 15),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Card(
              child: ListTile(
                title: Text(
                  "Profile Type: " + (userDatas.appUser?.profile ?? ""),
                  style: TextStyle(fontFamily: Keys.fontFamily, color: Colors.black, fontSize: 15),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Card(
              child: ListTile(
                title: Text(
                  "'Your login is tagged to this device and you cannot use this this login in any other mobile phone. if you need to change the device raise, the request through your trainer or mannager'",
                  style: TextStyle(fontFamily: Keys.fontFamily, color: Colors.black, fontSize: 15),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Card(
              child: ListTile(
                title: Text(
                  "Your Mobile Phone Model: " + (userDatas.appUser?.model ?? ""),
                  style: TextStyle(fontFamily: Keys.fontFamily, color: Colors.black, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),*/
    );
  }
}
