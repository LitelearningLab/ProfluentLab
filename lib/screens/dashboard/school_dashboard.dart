import 'package:flutter/material.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';

import '../../common_widgets/background_widget.dart';
import '../../common_widgets/common_drawer.dart';
import '../../constants/keys.dart';
import '../schools/lessons_screens.dart';
import '../schools/pro_lab_screen.dart';

class SchoolDashboard extends StatefulWidget {
  SchoolDashboard({Key? key}) : super(key: key);

  @override
  _SchoolDashboardState createState() {
    return _SchoolDashboardState();
  }
}

class _SchoolDashboardState extends State<SchoolDashboard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _tile(String menu, {List<Widget>? children}) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Color(0xff333a40),
      elevation: 2.0,
      child: ExpansionTile(
        collapsedIconColor: Colors.white,
        iconColor: Colors.white,
        backgroundColor: Color(0xff333a40),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            menu,
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
        // trailing: Theme(
        //   data: ThemeData(
        //     hintColor: Colors.white,
        //   ),
        //   child: Icon(Icons.keyboard_arrow_down),
        // ),
        children: children ??
            [
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LessonsScreens(
                                title: 'History',
                              )));
                },
                title: Row(
                  children: [
                    Icon(
                      Icons.list,
                      color: Color(0xff7ab800),
                    ),
                    SPW(10),
                    Text(
                      'History',
                      style: TextStyle(color: Color(0xff7ab800), fontSize: 17),
                    ),
                  ],
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LessonsScreens(
                                title: 'Geography',
                              )));
                },
                title: Row(
                  children: [
                    Icon(
                      Icons.list,
                      color: Color(0xff7ab800),
                    ),
                    SPW(10),
                    Text(
                      'Geography',
                      style: TextStyle(color: Color(0xff7ab800), fontSize: 17),
                    ),
                  ],
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LessonsScreens(
                                title: 'Civics',
                              )));
                },
                title: Row(
                  children: [
                    Icon(
                      Icons.list,
                      color: Color(0xff7ab800),
                    ),
                    SPW(10),
                    Text(
                      'Civics',
                      style: TextStyle(color: Color(0xff7ab800), fontSize: 17),
                    ),
                  ],
                ),
              ),
            ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff333a40),
        toolbarHeight: 100,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: Text(
                    "Profluent English",
                    style: TextStyle(
                        fontFamily: Keys.fontFamily, fontWeight: FontWeight.w500, color: Colors.white, fontSize: 25),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Text(
                    "TM",
                    style: TextStyle(fontFamily: Keys.fontFamily, color: Colors.white, fontSize: 11),
                  ),
                )
              ],
            ),
            Text(
              "School - Great 6",
              style: TextStyle(
                  fontFamily: Keys.fontFamily, fontWeight: FontWeight.w500, color: Colors.white, fontSize: 17),
            ),
          ],
        ),
      ),
      drawer: CommonDrawer(),
      body: ListView(
        children: [
          _tile("Social Science"),
          _tile("English"),
          _tile("Mathematics"),
          _tile("Science"),
          _tile("English Proficiency", children: [
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProlabScreen()));
              },
              title: Row(
                children: [
                  Icon(
                    Icons.list,
                    color: Color(0xff7ab800),
                  ),
                  SPW(10),
                  Text(
                    'Pronunciation Lab',
                    style: TextStyle(color: Color(0xff7ab800), fontSize: 17),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.list,
                    color: Color(0xff7ab800),
                  ),
                  SPW(10),
                  Text(
                    'Sentence Construction Lab',
                    style: TextStyle(color: Color(0xff7ab800), fontSize: 17),
                  ),
                ],
              ),
            ),
          ]),
          _tile("Role Play Games", children: [
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.list,
                    color: Color(0xff7ab800),
                  ),
                  SPW(10),
                  Text(
                    'Role Play Game 1',
                    style: TextStyle(color: Color(0xff7ab800), fontSize: 17),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.list,
                    color: Color(0xff7ab800),
                  ),
                  SPW(10),
                  Text(
                    'Role Play Game 2',
                    style: TextStyle(color: Color(0xff7ab800), fontSize: 17),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.list,
                    color: Color(0xff7ab800),
                  ),
                  SPW(10),
                  Text(
                    'Role Play Game 3',
                    style: TextStyle(color: Color(0xff7ab800), fontSize: 17),
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
