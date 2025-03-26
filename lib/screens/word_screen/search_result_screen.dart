import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:litelearninglab/common_widgets/boom_menu_item.dart' as bm;
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/models/Word.dart';
import 'package:litelearninglab/screens/dialogs/own_word_dialog.dart';
import 'package:litelearninglab/screens/dialogs/speech_analytics_dialog.dart';
import 'package:litelearninglab/screens/word_screen/widgets/drop_down_word_item.dart';
import 'package:litelearninglab/screens/word_screen/widgets/word_menu.dart';
import 'package:litelearninglab/screens/word_screen/word_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/firebase_helper_RTD.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;
import '../../common_widgets/background_widget.dart';
import '../../common_widgets/boom_menu.dart';
import '../../common_widgets/common_app_bar.dart';
import '../../common_widgets/spacings.dart';
import '../../constants/all_assets.dart';
import '../../constants/enums.dart';
import '../../constants/keys.dart';
import '../../database/SentDao.dart';
import '../../database/SentDatabaseProvider.dart';
import '../../database/SentencesDatabaseRepository.dart';
import '../../models/Sentence.dart';
import '../../utils/audio_player_manager.dart';
import '../../utils/firebase_helper.dart';
import '../../utils/sizes_helpers.dart';
import '../call_flow/follow_up_screen.dart';
import '../webview/webview_screen.dart';

class SearchResultScreen extends StatefulWidget {
  SearchResultScreen({Key? key, this.user, required this.searchTerm, required this.labType}) : super(key: key);
  final AuthState? user;
  final String searchTerm;
  final String labType;

  @override
  _SearchResultScreenState createState() {
    return _SearchResultScreenState();
  }
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  // final GlobalKey<SpeechAnalyticsDialogState> _speechAnalyticsDialogState =
  //     GlobalKey<SpeechAnalyticsDialogState>();

  String selectedExp = '';
  FirebaseHelperRTD db = new FirebaseHelperRTD();
  List<Word> _words = [];
  static const platform = const MethodChannel('headsetConnectivity');
  bool _isCorrect = false;
  String _selectedWord = "";
  String? _selectedWordOnClick;
  List<SearchNewClass> wordss = [];
  List<Sentence> _sentences = [];
  List<List<Sentence>> _sentences1 = [];
  Sentence? _selectedSentence;
  bool _isPlaying = false;
  int _currentPlayingIndex = -1;
  final _audioPlayerManager = AudioPlayerManager();
  late StreamSubscription _playerStateSubscription;
  String sentenceLabTitle = "Avoiding Personal Information";
  String sentenceLabLoad = "Avoiding Personal Information";
  String sentenceLabMain = "Professional Call Procedures";
  final dao = SentDao();
  bool isLoading = true;
  List<CallFollowUpsModels> getCallFollowUpsValues = [];
  List<MapEntry<Object?, Object?>> entriesList = [];

  @override
  void initState() {
    super.initState();
    print("the searched words is ${widget.searchTerm}");
    if (widget.labType == 'Pronunciation Lab') {
      print("Pronunciation Lab Search functionality");
      _getWords(isRefresh: false);
    } else if (widget.labType == 'Sentence Lab') {
      print("Sentence Lab Search functionality");
      _getSentences(isRefresh: false);
      _playerStateSubscription = _audioPlayerManager.onPlayerStateChanged.listen((event) {
        if (event == PlayerState.playing) {
          _isPlaying = true;
        } else {
          _isPlaying = false;
        }
        setState(() {});
      });
    } else if (widget.labType == 'Call Flow Lab') {
      isLoading = false;
      getFollowUps(isRefresh: false);
      setState(() {});
      print("Call Flow Lab Search functionality");
    } else {
      isLoading = false;
      getGrammer(isRefresh: false);
      setState(() {});
      print("Call Flow Lab Search functionality");
    }
    // searchAllFolders(searchWord: widget.searchTerm);
  }

  Future<void> _play(String sentence, int index, {required String url, String? localPath}) async {
    FirebaseHelper db = new FirebaseHelper();
    AuthState userDatas = Provider.of<AuthState>(context, listen: false);
    String? eLocalPath;
    _currentPlayingIndex = index;

    try {
      print("*********AUDIO PLAY STARTED");
      print("*********URL : : : $url");

      await _audioPlayerManager.stop();
      await _audioPlayerManager.play(url, localPath: localPath, context: context, decodedPath: (val) {
        eLocalPath = val;
      });
      print("*********AUDIO PLAY COMPLETED : $eLocalPath");
      await db.saveSentenceListReport(
          isPractice: false,
          company: userDatas.appUser!.company!,
          name: userDatas.appUser!.UserMname,
          userID: userDatas.appUser!.id!,
          sentence: sentence,
          team: userDatas.appUser?.team,
          userprofile: userDatas.appUser?.profile,
          city: userDatas.appUser?.city,
          date: DateFormat('dd-MMM-yyyy').format(DateTime.now()),
          title: sentenceLabTitle,
          load: sentenceLabLoad,
          main: sentenceLabMain);

      if (eLocalPath != null && eLocalPath!.isNotEmpty) {
        try {
          await File(eLocalPath!).delete();
          print('*********** LOCALPATH CMPLTD');
        } catch (e) {
          print('*********** LOCALPATH FAILED : $e');
        }
      }
    } catch (e) {
      print(">>>>>>>>>>>>>>>AUdio play Failed : : : $e");
    }
  }

  Future<bool> _getHeadsetConnectivity() async {
    bool connected = false;
    try {
      connected = await platform.invokeMethod('status');
    } on PlatformException catch (e) {
      print("Failed to get battery level: '${e.message}'.");
    }
    return connected;
  }

  void _getWords({bool? isRefresh}) async {
    _words = await db.searchWord(widget.searchTerm);

    print("words words : ${_words}");
    print(_words.length);

    isLoading = false;
    setState(() {});
  }

  void getFollowUps({String? searchTerm, required bool isRefresh}) async {
    isLoading = true;
    setState(() {});
    DatabaseReference refer = FirebaseDatabase.instance.ref('Call Flow Practice');

    await refer.get().then((DataSnapshot data) async {
      print("_getSentences");
      //   developer.log( (data.value! as Map).toString());
      Map<Object?, Object?> _grammarData = data.value as Map<Object?, Object?>;
      //  Map<String,dynamic> sentenceDatas = _grammarData as Map<String,dynamic>;
      Map<String, dynamic> sentenceDatas = Map<String, dynamic>.from(data.value as Map);
      // log("sentenceDatas : $sentenceDatas");
      getCallFollowUpsValues.clear();
      sentenceDatas.forEach((k, v) {
        print("got key $k with $v");
        v.forEach((k1, v1) {
          print("got key1 $k1 with $v1");
          print("got key $k with $v");
          print("dpkdjid uhdud");
          print(k1);
          print(widget.searchTerm);
          print("dod idid");
          if (k1 == widget.searchTerm) {
            print("ips i isiosihs");
            getCallFollowUpsValues.add(CallFollowUpsModels(title: k1, load: k1, main: k));
          }
        });
      });
    });
    print("call flow length : ${getCallFollowUpsValues.length}");
    isLoading = false;
    setState(() {});
  }

  void getGrammer({String? searchTerm, required bool isRefresh}) async {
    print("dkpjdi d duh du");
    isLoading = true;
    setState(() {});
    DatabaseReference refer = FirebaseDatabase.instance.ref('GrammarCheckConstructionLab');

    await refer.get().then((DataSnapshot data) async {
      print("_getSentences");
      //   developer.log( (data.value! as Map).toString());
      Map<Object?, Object?> _grammarData = data.value as Map<Object?, Object?>;
      //  Map<String,dynamic> sentenceDatas = _grammarData as Map<String,dynamic>;
      Map<String, dynamic> sentenceDatas = Map<String, dynamic>.from(data.value as Map);
      // log("sentenceDatas : $sentenceDatas");
      getCallFollowUpsValues.clear();
      sentenceDatas.forEach((k, v) {
        print("got key $k with $v");
        v.forEach((k1, v1) {
          print("got key1 $k1 with $v1");
          print("got key $k with $v");
          print("dpkdjid uhdud");
          print(k1);
          print(widget.searchTerm);
          print("dod idid");
          if (k1 == widget.searchTerm) {
            print("ips i isiosihs");
            entriesList.add(MapEntry(k1, v1));
          }
        });
      });
    });
    print("call flow length : ${getCallFollowUpsValues.length}");
    isLoading = false;
    setState(() {});
  }

  void _getSentences({String? searchTerm, required bool isRefresh}) async {
    SentDatabaseProvider dbb = SentDatabaseProvider.get;
    SentencesDatabaseRepository dbRef = SentencesDatabaseRepository(dbb);
    _sentences = await dbRef.getSearch(searchText: widget.searchTerm);
    print("sentence : $_sentences");
    isLoading = false;
    setState(() {});
  }

  /*searchAllFolders({required String searchWord}) async {
    setState(() {
      _isLoading = true;
    });
    wordss.clear();
    */ /*await getPronuncationLab(folder: 'daysdates',searchWord: searchWord);
    await getPronuncationLab(folder: 'Latters and NATO',searchWord: searchWord);
    await getPronuncationLab(folder: 'States and Cities',searchWord: searchWord);
    await getPronuncationLab(folder: 'CommonWords',searchWord: searchWord);
    await getPronuncationLab(folder: 'ProcessWords',searchWord: searchWord);
    await getPronuncationLab(folder: 'US Healthcare',searchWord: searchWord);
    await getPronuncationLab(folder: 'Travel Tourism',searchWord: searchWord);
    await getPronuncationLab(folder: 'Business Words',searchWord: searchWord);
    await getSentenceContstuctionLab(folder: 'SentenceConstructionLab',searchWord: searchWord);*/ /*
    await getCallFlowPracticeLab(folder: 'Call Flow Practice',searchWord: searchWord);
   // log("wordss : $wordss");
    setState(() {
      _isLoading = false;
    });
  }*/

  getPronuncationLab({required String folder, required String searchWord}) async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child(folder);
    var sample = await databaseReference.get();
    final data = Map<String, dynamic>.from(sample.value as Map);
    data.forEach((key, value) {
      value.forEach((key1, value1) {
        if (key1 == "text" && value1.toString().toLowerCase().startsWith(searchWord.toLowerCase())) {
          wordss.add(SearchNewClass(folderName: 'Profluent English/Pronuncation Lab/$folder', text: value1));
        }
      });
    });
  }

  getSentenceContstuctionLab({required String folder, required String searchWord}) async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child(folder);
    var sample = await databaseReference.get();
    final data = Map<String, dynamic>.from(sample.value as Map);
    data.forEach((key, value) {
      print("sentence key : $key");
      value.forEach((key1, value1) {
        print("sentence key1 : $key1");
        value1.forEach((key2, value2) {
          print("sentence key2 : $key2");
          value2.forEach((key3, value3) {
            print("sentence key3 : $key3");
            if (key3 == "text" && value3.toString().toLowerCase().startsWith(searchWord.toLowerCase())) {
              print("///// $key3 : $value3 ////");
              // wordss.add(value);
              wordss.add(SearchNewClass(folderName: '$folder/$key/$key1', text: value3));
            }
          });
        });
      });
    });
  }

  getCallFlowPracticeLab({required String folder, required String searchWord}) async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child(folder);
    var sample = await databaseReference.get();
    final data = Map<String, dynamic>.from(sample.value as Map);
    data.forEach((key, value) {
      print("call flow pratice lab key : $key");
      value.forEach((key1, value1) {
        print("call flow pratice lab key1 : $key1");
        print("call flow pratice lab value1 : $value1");
        if (key1.toString().toLowerCase().startsWith(searchWord.toLowerCase())) {
          print("///// $key1 : $value1 ////");
          wordss.add(SearchNewClass(folderName: 'Profluent English/Call Flow Practice Lab/$key/$key1', text: key1));
        }
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  /*getCallFlowPraticeLab({required String folder,required String searchWord}) async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child(folder);
    var sample = await databaseReference.get();
    final data = Map<String, dynamic>.from(sample.value as Map);
    data.forEach((key, value) {
      value.forEach((key1,value1){
        if(key1 == "text" && value1.toString().toLowerCase().startsWith(searchWord.toLowerCase())){
          wordss.add(value);
        }
      });
    });
  }*/

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _audioPlayerManager.dispose();

    super.dispose();
  }

  void _showDialog(String word, bool notCatch, BuildContext context) async {
    print("show Dialog calleddd");
    Get.dialog(Container(
      // color: Color(0xCC000000),
      child: Dialog(
        // backgroundColor: AppColors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        //this right here
        child: SpeechAnalyticsDialog(
          true,
          isShowDidNotCatch: notCatch,
          word: word,
        ),
      ),
    )).then((value) {
      if (value.isCorrect == "true" || value.isCorrect == "false") {
        print("checkkkkkkk");
        _selectedWord = word;
        _isCorrect = value.isCorrect == "true" ? true : false;
        print("correcttttcorrecttttcorrecttttcorrectttt:${_isCorrect}");
        setState(() {});
      } else if (value.isCorrect == "notCatch") {
        _showDialog(word, true, context);
      } else if (value.isCorrect == "openDialog") {
        _showDialog(word, false, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: Theme.of(context).platform == TargetPlatform.android,
      bottom: Theme.of(context).platform == TargetPlatform.android,
      child: BackgroundWidget(
        appBar: CommonAppBar(
          title: "Search Result for: ${widget.searchTerm}",
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: Colors.white,
              ))
            : widget.labType == 'Pronunciation Lab'
                ? _words.length == 0
                    ? Center(
                        child: Text(
                          "List is empty",
                          style: TextStyle(color: AppColors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _words.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(AllAssets.wordback),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: DropDownWordItem(
                              localPath: _words[index].localPath,
                              load: 'Search Result for: ${widget.searchTerm}',
                              maintitle: 'Search Result for: ${widget.searchTerm}',
                              onExpansionChanged: (val) {
                                // _toggleExpansion(index);
                                print("check11111111111111111111111113333>");
                                setState(() {
                                  _selectedWord = '';
                                });
                                if (val) {
                                  _selectedWordOnClick = _words[index].text;
                                  setState(() {});
                                  // if (_words.length - 2 <= index) {
                                  //   WidgetsBinding.instance.addPostFrameCallback((_) {
                                  //     _scrollToItem(index);
                                  //   });
                                  // }
                                }
                              },
                              initiallyExpanded:
                                  _selectedWordOnClick != null && _selectedWordOnClick == _words[index].text,
                              isWord: true,
                              isRefresh: (val) {
                                if (val) _getWords(isRefresh: true);
                              },
                              wordId: _words[index].id!,
                              isFav: _words[index].isFav!,
                              title: _words[index].text!,
                              url: _words[index].file!,
                              index: index,
                              length: _words.length,
                              isDownloaded: _words[index].localPath != null && _words[index].localPath!.isNotEmpty,
                              //isDownloaded: ,
                              children: [
                                WordMenu(
                                  pronun: _words[index].pronun!,
                                  selectedWord: _selectedWord,
                                  isCorrect: _selectedWord == _words[index].text && _isCorrect,
                                  text: _words[index].text!,
                                  syllables: _words[index].syllables!,
                                  onTapHeadphone: () async {},
                                  onTapMic: () async {
                                    _showDialog(_words[index].text!, false, context);
                                  },
                                )
                              ],
                            ),
                          );
                        })
                : widget.labType == 'Sentence Lab'
                    ? _sentences.isEmpty
                        ? Center(
                            child: Text(
                              "List is empty",
                              style: TextStyle(color: AppColors.white),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.only(top: 10),
                            itemCount: _sentences.length,
                            itemBuilder: (BuildContext context, int index) {
                              print("AUDIO URL: ${_sentences[index].file}");
                              return DropDownWordItem(
                                length: _sentences.length,
                                index: index,
                                isDownloaded: false,
                                localPath: _sentences[index].localPath,
                                load: sentenceLabLoad,
                                maintitle: sentenceLabTitle,
                                url: _sentences[index].file,
                                onExpansionChanged: (val) {
                                  if (_selectedSentence != _sentences[index]) {
                                    _selectedSentence = _sentences[index];
                                    setState(() {});
                                  } else {
                                    _selectedSentence = null;
                                  }
                                },
                                initiallyExpanded: _selectedSentence != null && _selectedSentence == _sentences[index],
                                isFav: _sentences[index].isFav!,
                                wordId: _sentences[index].id!,
                                isWord: false,
                                isRefresh: (val) {
                                  if (val) _getSentences(isRefresh: true);
                                },
                                title: _sentences[index].text!,
                                onTapForThreePlayerStop: () {},
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30, right: 30),
                                    child: Container(
                                      height: 59,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              print('INDEX : : : $index');
                                              if (_isPlaying && _currentPlayingIndex == index) {
                                                _audioPlayerManager.stop();
                                              } else {
                                                _play(
                                                  _sentences[index].text!, index,
                                                  url: _sentences[index].file!,
                                                  // localPath:
                                                  //     _sentences[index].localPath!,
                                                );
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                SPW(35),
                                                Icon(
                                                  _isPlaying && _currentPlayingIndex == index
                                                      ? Icons.pause_circle_outline
                                                      : Icons.play_circle_outline,
                                                  color: AppColors.black,
                                                ),
                                                SPW(5),
                                                Text(
                                                  "Native Speaker",
                                                  style: TextStyle(fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // if (_isPlaying)
                                          //   InkWell(
                                          //       onTap: () {
                                          //         _audioPlayerManager.stop();
                                          //       },
                                          //       child: Icon(
                                          // Icons.pause_circle_outline,
                                          // color: AppColors.black,
                                          //       )),
                                          InkWell(
                                            onTap: () {
                                              _showDialog(_sentences[index].text!, false, context);
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.mic,
                                                ),
                                                SPW(5),
                                                Text(
                                                  "Practice",
                                                  style: TextStyle(fontSize: 13),
                                                ),
                                                SPW(35),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            })
                    : widget.labType == 'Call Flow Lab'
                        ? getCallFollowUpsValues.isNotEmpty
                            ? ListView.builder(
                                padding: EdgeInsets.only(
                                    top: isSplitScreen ? getFullWidgetHeight(height: 14) : getWidgetHeight(height: 14),
                                    left: getWidgetWidth(width: 20),
                                    right: getWidgetWidth(width: 20)),
                                itemCount: getCallFollowUpsValues.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                      SizedBox(
                                          height: isSplitScreen
                                              ? getFullWidgetHeight(height: 12)
                                              : getWidgetHeight(height: 12)),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        onTap: () async {
                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                          await prefs.setStringList('FollowUpScreen', [
                                            getCallFollowUpsValues[index].title,
                                            getCallFollowUpsValues[index].load ?? "",
                                            getCallFollowUpsValues[index].main
                                          ]);
                                          await prefs.setString('lastAccess', 'FollowUpScreen');
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => FollowUpScreen(
                                                        user: Provider.of<AuthState>(context, listen: false),
                                                        title: getCallFollowUpsValues[index].title,
                                                        load: getCallFollowUpsValues[index].load,
                                                        main: getCallFollowUpsValues[index].main,
                                                        // main: 'Denied As Maximum Benefits Exhausted',
                                                      )));
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                getCallFollowUpsValues[index].title,
                                                style: TextStyle(
                                                    color: AppColors.white,
                                                    fontFamily: Keys.fontFamily,
                                                    fontSize: kText.scale(17)),
                                              ),
                                            ),
                                            SizedBox(
                                              // height: 30,
                                              // width: 30,
                                              child: Icon(
                                                Icons.chevron_right_rounded,
                                                color: Color(0xFF34445F),
                                                size: 30,
                                              ),
                                            )
                                          ],
                                        ),
                                        /* child: Card(
                                margin: EdgeInsets.symmetric(vertical: 1),
                                color: Color(0xff333a40),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                  child: Row(
                                    children: [
                                      Container(height: 9, width: 16, child: Image.asset("assets/images/left_arrow.png")),
                                      SPW(10),
                                      Flexible(
                                        child: Text(
                                          _sentCat[index].title ?? "",
                                          style: TextStyle(color: AppColors.white, fontFamily: Keys.fontFamily, fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),*/
                                      ),
                                      SizedBox(
                                          height: isSplitScreen
                                              ? getFullWidgetHeight(height: 12)
                                              : getWidgetHeight(height: 12)),
                                      Divider(
                                        color: Color(0XFF34425D),
                                        thickness: 1,
                                      ),
                                    ],
                                  );
                                })
                            : Center(
                                child: Text(
                                  "List is empty",
                                  style: TextStyle(color: AppColors.white),
                                ),
                              )
                        : entriesList.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.only(top: 10),
                                itemCount: entriesList.length, //_sentences.length,
                                itemBuilder: (BuildContext context, int index) {
                                  print("entrieslist length:${entriesList.length}");
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
                                        setState(() {});
                                      }
                                    },
                                    initiallyExpanded:
                                        _selectedWordOnClick != null && _selectedWordOnClick == entry.key.toString(),
                                    //   isFav: _sentences[index].isFav!,
                                    //   wordId: _sentences[index].id!,
                                    isWord: false,
                                    /* isRefresh: (val) {
                          if (val) _getSentences(isRefresh: true);
                        },*/
                                    title: entry.key.toString() ?? "",
                                    onTapForThreePlayerStop: () {},
                                    wordId: index,
                                    isRefresh: (bool) {},
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 30, right: 30),
                                        child: Container(
                                          height: 59,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            children: [
                                              SPW(35),
                                              // if (!_isPlaying)
                                              InkWell(
                                                onTap: () async {
                                                  String? learningModuleValue = "";
                                                  if (entry.value is Map) {
                                                    Map<dynamic, dynamic> valueMap =
                                                        entry.value as Map<dynamic, dynamic>;

                                                    learningModuleValue = valueMap['Learning module'] as String?;

                                                    print('Learning module: ${learningModuleValue.runtimeType}');
                                                  } else {
                                                    print('The entry value is not a Map.');
                                                  }
                                                  print("checkEntryValue:${entry.value}");
                                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                                  await prefs
                                                      .setStringList('InAppWebViewPage', [learningModuleValue ?? ""]);
                                                  await prefs.setString('lastAccess', 'InAppWebViewPage');
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              InAppWebViewPage(url: learningModuleValue ?? "")));
                                                },
                                                child: Image.asset(AllAssets.interaction,
                                                    width: 25, height: 25, color: Colors.black),
                                              ),
                                              SPW(5),
                                              Text(
                                                "Learning Module",
                                                style: TextStyle(fontSize: 13),
                                              ),
                                              Spacer(),
                                              InkWell(
                                                onTap: () async {
                                                  String? exerciseValue = "";
                                                  if (entry.value is Map) {
                                                    Map<dynamic, dynamic> valueMap =
                                                        entry.value as Map<dynamic, dynamic>;

                                                    exerciseValue = valueMap['Exercise'] as String?;

                                                    print('Exercise: ${exerciseValue.runtimeType}');
                                                  } else {
                                                    print('The entry value is not a Map.');
                                                  }
                                                  print("checkEntryValue:${entry.value}");
                                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                                  await prefs.setStringList('InAppWebViewPage', [exerciseValue ?? ""]);
                                                  await prefs.setString('lastAccess', 'InAppWebViewPage');
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              InAppWebViewPage(url: exerciseValue ?? "")));
                                                },
                                                child: Wrap(
                                                  children: [
                                                    Image.asset(
                                                      AllAssets.approval,
                                                      width: 25,
                                                      height: 25,
                                                      color: Colors.black,
                                                    ),
                                                    SPW(5),
                                                    Text(
                                                      "Exercise",
                                                      style: TextStyle(fontSize: 13),
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
                                child: Text(
                                  "List is empty",
                                  style: TextStyle(color: AppColors.white),
                                ),
                              ),
        /*floatingActionButton: buildBoomMenu()*/
      ),
    );
  }

  BoomMenu buildBoomMenu() {
    return BoomMenu(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0, color: AppColors.white),
        //child: Icon(Icons.add),
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        backgroundColor: AppColors.green,
        // scrollVisible: scrollVisible,
        overlayColor: Colors.black,
        overlayOpacity: 0.7,
        children: [
          bm.MenuItem(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(
                Icons.home,
                color: Colors.grey,
                size: 18,
              ),
            ),
            title: "Home",
            titleColor: Colors.white,
            backgroundColor: Colors.transparent,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          bm.MenuItem(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(
                Icons.keyboard,
                color: Colors.grey,
                size: 18,
              ),
            ),
            title: "Try Unlisted Words",
            titleColor: Colors.white,
            backgroundColor: Colors.transparent,
            onTap: () {
              showDialog(
                useRootNavigator: true,
                context: context,
                builder: (BuildContext context) {
                  return OwnWordDialog(
                    isFromWord: true,
                  );
                  // return OwnWordResultDialog();
                },
              );
            },
          ),
          // bm.MenuItem(
          //   child: Container(
          //     padding: EdgeInsets.all(12),
          //     decoration:
          //         BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          //     child: Icon(
          //       Icons.check_box,
          //       color: Colors.grey,
          //       size: 18,
          //     ),
          //   ),
          //   title: "Filter Priority",
          //   titleColor: Colors.white,
          //   backgroundColor: Colors.transparent,
          //   onTap: () {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => WordScreen(
          //                   title: "Priority List",
          //                   load: "",
          //                 ))).then((val) => _getWords(isRefresh: false));
          //   },
          // ),
          bm.MenuItem(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(
                Icons.check_box,
                color: Colors.grey,
                size: 18,
              ),
            ),
            title: "Filter All Priority",
            titleColor: Colors.white,
            backgroundColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WordScreen(
                            title: "Priority List",
                            load: "",
                          ))).then((val) => _getWords(isRefresh: false));
            },
          ),
          // bm.MenuItem(
          //   child: Icon(
          //     Icons.check_box,
          //     color: Colors.red,
          //     size: 40,
          //   ),
          //   title: "Open priority list",
          //   titleColor: Colors.grey[850],
          //   backgroundColor: AppColors.primary,
          //   onTap: () {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => WordScreen(
          //                   title: "Priority List",
          //                   load: "",
          //                 ))).then((val) => _getWords(isRefresh: false));
          //   },
          // ),
        ]);
  }
}

class SearchNewClass {
  final String folderName;
  final String text;
  const SearchNewClass({required this.folderName, required this.text});
}

class CallFollowUpsModels {
  final String title;
  final String load;
  final String main;
  const CallFollowUpsModels({required this.title, required this.load, required this.main});
}
