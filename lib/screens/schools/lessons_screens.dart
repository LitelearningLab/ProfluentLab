import 'package:flutter/material.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/background_widget.dart';
import '../../common_widgets/common_app_bar.dart';
import '../word_screen/word_screen.dart';

class LessonsScreens extends StatefulWidget {
  LessonsScreens({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _LessonsScreensState createState() {
    return _LessonsScreensState();
  }
}

class _LessonsScreensState extends State<LessonsScreens> {
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
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setStringList('WordScreen', ['Most Commonly Used Words','CommonWords']);
                  await prefs.setString('lastAccess', 'WordScreen');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WordScreen(
                                title: "Most Commonly Used Words",
                                load: "CommonWords",
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
                    SizedBox(
                      width: displayWidth(context) * 0.73,
                      child: Text(
                        'Practice Sentences From The Book',
                        style:
                            TextStyle(color: Color(0xff7ab800), fontSize: 17),
                      ),
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
                    SizedBox(
                      width: displayWidth(context) * 0.73,
                      child: Text(
                        'Sentence Construction - Discussing The Lesson',
                        style:
                            TextStyle(color: Color(0xff7ab800), fontSize: 17),
                      ),
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
      appBar: CommonAppBar(title: widget.title,
      // height: displayHeight(context) / 12.6875,
      ),
      body: ListView(
        children: [
          _tile("What is History?"),
          _tile("Human Evolution"),
          _tile("Indus Civilisation"),
          _tile("Ancient Cities of Tamilagam"),
        ],
      ),
    );
  }
}
