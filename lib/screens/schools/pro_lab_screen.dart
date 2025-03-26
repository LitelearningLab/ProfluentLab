import 'package:flutter/material.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/background_widget.dart';
import '../../common_widgets/common_app_bar.dart';
import '../word_screen/word_screen.dart';

class ProlabScreen extends StatefulWidget {
  ProlabScreen({Key? key}) : super(key: key);

  @override
  _ProlabScreenState createState() {
    return _ProlabScreenState();
  }
}

class _ProlabScreenState extends State<ProlabScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _tile(String menu, {required GestureTapCallback? onTap}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: new BorderRadius.all(Radius.circular(10.0)),
        color: Color(0xff333a40),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          menu,
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: CommonAppBar(title: "Pronunciation Lab",
      // height: displayHeight(context) / 12.6875,
      ),
      body: ListView(
        children: [
          _tile("Days, Dates, Months & Numbers", onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setStringList('WordScreen', ['Days, Dates, Months & Numbers','daysdates']);
            await prefs.setString('lastAccess', 'WordScreen');
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WordScreen(
                          title: "Days, Dates, Months & Numbers",
                          load: "daysdates",
                        )));
          }),
          _tile("Letters & Phonetic Codes", onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setStringList('WordScreen', ['Letters & NATO Phonetic Codes','Latters and NATO']);
            await prefs.setString('lastAccess', 'WordScreen');
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WordScreen(
                          title: "Letters & NATO Phonetic Codes",
                          load: "Latters and NATO",
                        )));
          }),
          _tile("Most Commonly Used Words", onTap: () async {
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
          }),
        ],
      ),
    );
  }
}
