import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/common_widgets/background_widget.dart';
import 'package:litelearninglab/common_widgets/common_app_bar.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/models/SentenceCat.dart';
import 'package:litelearninglab/screens/webview/webview_screen.dart';
import 'package:litelearninglab/screens/word_screen/widgets/drop_down_word_item.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/bottom_navigation.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:litelearninglab/utils/firebase_helper_RTD.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GrammarCheckScreen extends StatefulWidget {
  GrammarCheckScreen({Key? key, required this.title, required this.load})
      : super(key: key);
  final String title;
  final String load;

  @override
  _GrammarCheckScreenState createState() {
    return _GrammarCheckScreenState();
  }
}

late AuthState sentenceRepeatUser;
String sentenceRepeatLoad = "";

class _GrammarCheckScreenState extends State<GrammarCheckScreen> {
  FirebaseHelperRTD db = new FirebaseHelperRTD();
  List<SentenceCat> _sentCat = [];
  bool _isLoading = true;
  Map<Object?, Object?> _grammarData = {};
  Map<Object?, Object?> dataMap = {};
  List<MapEntry<Object?, Object?>> entriesList = [];
  String? _selectedWordOnClick;
  String? _selectedSentence;
  bool _isExpanded = false;
  Map<Object?, Object?> grammarMap = {};

  @override
  void initState() {
    super.initState();
    print("dsjfije");
    getDatabaseGrammar();

    // _getSentCat();
  }

  /* getDatabaseGrammar() async {
    developer.log("Starting database fetch", name: 'getDatabaseGrammar');
    DatabaseReference refer = FirebaseDatabase.instance.ref('/GrammarCheckConstructionLab');

    DataSnapshot data = await refer.get();

    developer.log("Data fetched", name: 'getDatabaseGrammar');
    developer.log('Data Type: ${data.value.runtimeType}', name: 'getDatabaseGrammar');

    if (data.value != null && data.value is Map) {
      developer.log('Full Grammar Data: $_grammarData', name: 'getDatabaseGrammar');
      developer.log('Specific Load Data: ${_grammarData![widget.load]}', name: 'getDatabaseGrammar');
    } else {
      developer.log("No data found or incorrect data format", name: 'getDatabaseGrammar');
    }
  }*/
  getDatabaseGrammar() async {
    _isLoading = true;
    print("sodjifjw");
    DatabaseReference refer =
        FirebaseDatabase.instance.ref('/GrammarCheckConstructionLab');
    await refer.get().then((DataSnapshot data) async {
      print("dpodjodjod");
      print("widgetload:${widget.load}");
      print(data.value.runtimeType);
      print(data.value as Map);
      _grammarData = data.value as Map<Object?, Object?>;
      dataMap = (data.value! as Map)[widget.load];
      print("data map : ${dataMap.runtimeType}");
      print("data map length : ${dataMap.length}");
      for (int i = 0; i < dataMap.length; i++) {
        print("title dcccccc : ${dataMap['001']}");
      }
      entriesList = dataMap.entries.toList();
      grammarMap = dataMap;
      print("grammar map : $grammarMap");
      print("entrylist length : ${entriesList.length}");
      /*var keys = data.children;
      // var data = snap.snapshot.value;
      grammarFinalList.clear();

      for (DataSnapshot key in keys) {
        // print(key.value);
        var data = json.decode(json.encode(key.value));
        print(data);
        GrammerCheckModel d = new GrammerCheckModel();
        d.Exercise = data['Exercise'] ?? "";
        d.Learningmodule = data['Learning module'] ?? "";

        grammarFinalList.add(d);
      }
      print("grammarFinalList : $grammarFinalList");*/
      //developer.log(data.value as Map);
      //print("grammarCheck : ${grammarCheck.grammarCheckConstructionLab?.partsOfSpeech!.adjectives!.learningModule}");
      print(data.value as Map);
      print("fkfjif ");
      print((data.value! as Map)[widget.load]);
      _isLoading = false;
      setState(() {});
    });
  }

  /*void _getSentCat() async {
    setState(() {
      _isLoading = true;
    });
    _sentCat = await db.getSentencesCat(widget.load, "SentenceConstructionLab");

    setState(() {
      _isLoading = false;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        stopTimerMainCategory();
      },
      child: BackgroundWidget(
        appBar: CommonAppBar(
          title: widget.title,
          // height: displayHeight(context) / 12.6875,
        ),
        body: Column(
          children: [
            Expanded(
              child: _isLoading == false
                  ? ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 10),
                      itemCount: entriesList.length, //_sentences.length,
                      itemBuilder: (BuildContext context, int index) {
                        print("entrieslist length:${entriesList.length}");
                        print("sddfdifjd:${entriesList[index]}");
                        print("sdmjdjvijivji:${entriesList[index]}");
                        MapEntry<Object?, Object?> entry = entriesList[index];
                        //print("AUDIO URL: ${_sentences[index].file}");
                        /*return Container(
                          //height: 54,
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Color(0XFF34425D), borderRadius: BorderRadius.circular(7)),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: Text(
                                entry.key.toString(),
                                style: TextStyle(color: Color(0XFFFFFFFF)),
                              ),
                              trailing: SizedBox.shrink(),
                              //  backgroundColor: Colors.yellow,
                              onExpansionChanged: (value) {},
                              childrenPadding: EdgeInsets.zero,
                              children: [
                                Container(
                                  height: 20,
                                  width: 300,
                                  color: Color(0XFFFFFFFF),
                                )
                              ],
                            ),
                          ),
                        );*/

                        List<Object?> dataList = dataMap.keys.toList();
                        Map<Object?, Object?>? firstData =
                            dataMap[dataList[index].toString()]
                                as Map<Object?, Object?>;
                        List<Object?> firstDataList = firstData.keys.toList();
                        Map<Object?, Object?>? internalData =
                            firstData[firstDataList[0].toString()]
                                as Map<Object?, Object?>;

                        return DropDownWordItem(
                          length: entriesList.length,
                          index: index,
                          isDownloaded: true,
                          isButtonsVisible: false,
                          //     localPath: _sentences[index].localPath,
                          load: "widget.load",
                          maintitle: "widget.title",
                          //     url: _sentences[index].file,
                          onExpansionChanged: (val) {
                            if (val) {
                              _selectedWordOnClick = entry.key.toString() ?? '';

                              log("${firstDataList[0].toString()}");
                              print("checkkkkkkk1111");
                              print("titleCheckkk:${entry.key.toString()}");
                              setState(() {});
                            }
                          },
                          initiallyExpanded: _selectedWordOnClick != null &&
                              _selectedWordOnClick == entry.key.toString(),
                          //   isFav: _sentences[index].isFav!,
                          //   wordId: _sentences[index].id!,
                          isWord: false,
                          /* isRefresh: (val) {
                            if (val) _getSentences(isRefresh: true);
                          },*/
                          title: firstDataList[0].toString(),
                          onTapForThreePlayerStop: () {},
                          wordId: index,
                          isRefresh: (bool) {},
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 30),
                              child: Container(
                                height: 59,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  color: Color(0xff293750),
                                ),
                                child: Row(
                                  children: [
                                    SPW(35),
                                    // if (!_isPlaying)
                                    InkWell(
                                      onTap: () async {
                                        print("d dddd");
                                        sessionName2 =
                                            firstDataList[0].toString() +
                                                " - Learning Module";
                                        String? learningModuleValue =
                                            internalData["Learningmodule"]
                                                .toString();
                                        print(
                                            "learningModuleValue : $learningModuleValue");
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        await prefs.setStringList(
                                            'InAppWebViewPage',
                                            [learningModuleValue ?? ""]);
                                        await prefs.setString(
                                            'lastAccess', 'InAppWebViewPage');
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    InAppWebViewPage(
                                                        url:
                                                            learningModuleValue ??
                                                                "")));
                                      },
                                      child: Row(
                                        children: [
                                          Image.asset(AllAssets.interaction,
                                              width: 25,
                                              height: 25,
                                              color: Colors.white),
                                          SPW(5),
                                          Text(
                                            "Learning Module",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    InkWell(
                                      onTap: () async {
                                        sessionName2 =
                                            firstDataList[0].toString() +
                                                " - Exercise";
                                        String? exerciseValue =
                                            internalData["Exercise"].toString();
                                        print("exercise : $exerciseValue");
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        await prefs.setStringList(
                                            'InAppWebViewPage',
                                            [exerciseValue ?? ""]);
                                        await prefs.setString(
                                            'lastAccess', 'InAppWebViewPage');
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    InAppWebViewPage(
                                                        url: exerciseValue ??
                                                            "")));
                                      },
                                      child: Wrap(
                                        children: [
                                          Image.asset(
                                            AllAssets.approval,
                                            width: 25,
                                            height: 25,
                                            color: Colors.white,
                                          ),
                                          SPW(5),
                                          Text(
                                            "Exercise",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                    SPW(20),
                                    Spacer(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      })
                  : Center(
                      child: CircularProgressIndicator(
                      color: Colors.white,
                    )),
            ),
            Container(
              height: isSplitScreen
                  ? getFullWidgetHeight(height: 60)
                  : getWidgetHeight(height: 60),
              width: kWidth,
              decoration: BoxDecoration(
                color: Color(0xFF34445F),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      icon: ImageIcon(
                        AssetImage(AllAssets.bottomHome),
                        color: context.read<AuthState>().currentIndex == 0
                            ? Color(0xFFAAAAAA)
                            : Color.fromARGB(132, 170, 170, 170),
                      ),
                      onPressed: () {
                        context.read<AuthState>().changeIndex(0);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BottomNavigation()));
                      }),
                  IconButton(
                      icon: ImageIcon(AssetImage(AllAssets.bottomPL),
                          color: context.read<AuthState>().currentIndex == 1
                              ? Color(0xFFAAAAAA)
                              : Color.fromARGB(132, 170, 170, 170)),
                      onPressed: () {
                        context.read<AuthState>().changeIndex(1);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BottomNavigation()));
                      }),
                  IconButton(
                      icon: ImageIcon(AssetImage(AllAssets.bottomIS),
                          color: context.read<AuthState>().currentIndex == 2
                              ? Color(0xFFAAAAAA)
                              : Color.fromARGB(132, 170, 170, 170)),
                      onPressed: () {
                        context.read<AuthState>().changeIndex(2);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BottomNavigation()));
                      }),
                  IconButton(
                      icon: ImageIcon(AssetImage(AllAssets.bottomPE),
                          color: context.read<AuthState>().currentIndex == 3
                              ? Color(0xFFAAAAAA)
                              : Color.fromARGB(132, 170, 170, 170)),
                      onPressed: () {
                        context.read<AuthState>().changeIndex(3);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BottomNavigation()));
                      }),
                  IconButton(
                      icon: ImageIcon(AssetImage(AllAssets.bottomPT),
                          color: context.read<AuthState>().currentIndex == 4
                              ? Color(0xFFAAAAAA)
                              : Color.fromARGB(132, 170, 170, 170)),
                      onPressed: () {
                        context.read<AuthState>().changeIndex(4);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BottomNavigation()));
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
