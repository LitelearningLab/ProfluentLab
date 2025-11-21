import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/models/SoftSkills.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../models/InteracticeSimulationMain.dart';
import '../../../models/ProcessLearningMain.dart';
import '../../../utils/firebase_helper.dart';
import '../../../utils/shared_pref.dart';

class FirstRowMenu extends StatefulWidget {
  FirstRowMenu({
    Key? key,
    required this.backgroundImage,
    required this.menuImage,
    required this.menu,
    this.onTap,
    required this.size,
  }) : super(key: key);

  final String backgroundImage;
  final String menuImage;
  final String menu;
  final GestureTapCallback? onTap;
  final Size size;

  @override
  State<FirstRowMenu> createState() => _FirstRowMenuState();
}

class _FirstRowMenuState extends State<FirstRowMenu> {
  FirebaseHelper db = new FirebaseHelper();
//SoftSkill Variables
  List<SoftSkills> _categories = [];
  List<String> softSkillLinks = [];
  int activeLinkCount = 0;
  double softSkillProgressBar = 0.0;
//ArCall Simulations Variables
  List<InteracticeSimulationMain> _categoriesAr = [];
  List<String> arCallSimulationsLinks = [];
  int activeLink1Count = 0;
  int activeLink2Count = 0;
  int activeLink3Count = 0;
  int TotalActiveLinkCount = 0;
  double arCallSimulationsProgressBar = 0;
//processLearning Variables
  List<ProcessLearningMain> _processLeaning = [];
  List<String> processLearningLinks = [];
  int activeLinkCountPL = 0;
  int activeSimulationCountPL = 0;
  int activeVideoCountPL = 0;
  int activeFAQCountPL = 0;
  int activeKnowledgePL = 0;
  int totalActiveLinkCountPL = 0;
  double processLearningProgressBar = 0.0;
  bool isLoading = true;
  List<String> wordsFileUrl = [];
  List<String> wordsTapped = [];
  int wordsProgressPE = 0;
  int sentenceProgressPE = 0;

  void initState() {
    _getWords();
    super.initState();
  }

  Future<void> createDocumentWithSpecificId() async {
    String userId = await SharedPref.getSavedString('userId');
    if (kDebugMode) {
      print("creat document with specific ID >>>>>>");
      print(userId);
    }

    for (int i = 0; i < _categories.length; i++) {
      if (_categories[i].link!.isNotEmpty) {
        activeLinkCount += 1;
      }
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (userId != null && userId.isNotEmpty) {
      DocumentReference softSkills =
          firestore.collection('softSkillReports').doc(userId);
      DocumentSnapshot snapshot = await softSkills.get();
      if (snapshot.exists && snapshot.data() != null) {
        setState(() {
          softSkillLinks = List<String>.from(snapshot['isLink']);
          softSkillProgressBar = softSkillLinks.length / activeLinkCount;
        });
      }
      await softSkills
          .set({
            'activeLink': activeLinkCount,
            'isLink': softSkillLinks,
            'userId': userId,
          })
          .then((_) {})
          .catchError((e) {
            print('Error adding/updating document: $e');
          });
    } else {
      print('Error: userId is null or empty.');
    }
    //DocumentReference softSkills = firestore.collection('softSkillReports').doc(userId);
    //DocumentSnapshot snapshot = await softSkills.get();
  }

  void _getWords() async {
    _categories = [];
    _categories = await db.getSoftSkills();
    _categories = _categories.reversed.toList();
    _categoriesAr = [];
    _categoriesAr = await db.getInteractiveSimuations();
    _categoriesAr = _categoriesAr.reversed.toList();
    _processLeaning = [];
    _processLeaning = await db.getProcessLearning();
    _processLeaning = _processLeaning.reversed.toList();
    print("one");
    await createDocumentWithSpecificId();
    print("two");
    await createDocumentWithSpecificIdARCallSimulations();
    print('three');
    await createDocumentWithSpecificIdPL();
    print("four");
    await createDocumentWithSpecificIdPE();
    print('five');
    setState(() {
      isLoading = false;
    });
  }

  Future<void> createDocumentWithSpecificIdPE() async {
    print("Fetching document...");
    String userId = await SharedPref.getSavedString('userId');
    print("User ID: $userId");

    // Get document snapshot
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('proFluentEnglishReport')
        .doc(userId) // specify the document ID
        .get();
    if (documentSnapshot.exists) {
      // The document exists, retrieve data
      List wordsTapped = documentSnapshot.get('WordsTapped');
      List sentenceTapped = documentSnapshot.get('SentencesTapped');

      wordsProgressPE = wordsTapped.length;
      sentenceProgressPE = sentenceTapped.length;
    } else {
      await FirebaseFirestore.instance
          .collection('proFluentEnglishReport')
          .doc(userId)
          .set({
        'WordsTapped': [],
        'SentencesTapped': [],
        'userId': userId,
      });

      wordsProgressPE = 0;
      sentenceProgressPE = 0;
    }
  }

  /* Future<void> createDocumentWithSpecificIdPE() async {
    print("ssssssss sssss");
    String userId = await SharedPref.getSavedString('userId');
    print("dudvdsvdv:$userId");
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('proFluentEnglishReport')
        .doc(userId) // specify the document ID
        .get();
    List wordsTapped = documentSnapshot.get('WordsTapped');
    List sentenceTapped = documentSnapshot.get('SentencesTapped');
    print("words tapped : ${wordsTapped.length}");
    print("sentence tapped: ${sentenceTapped.length}");
    wordsProgressPE = wordsTapped.length;
    sentenceProgressPE = sentenceTapped.length;
    print("wordProgressPE:${wordsProgressPE}");

    */ /* FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference proFluentEnglish = firestore.collection('proFluentEnglishReport').doc(userId);

  DocumentSnapshot snapshot = await proFluentEnglish.get();
  List wordsTappeds = snapshot.get('WordsTapped');*/ /*
    */ /*print("words tapped length : ${wordsTappeds.length}");
  print("wordsTappedddLenthhhhh:${wordsTapped.length}");
  if (snapshot.exists && snapshot.data() != null) {
    print("snapshotAlreadyExistssss");
    setState(() {
      wordsTapped = List<String>.from(snapshot['WordsTapped']);
      wordsProgress = wordsTapped.length;
      print("wordsTappedLength:${wordsProgress}");
    });
  }
  await proFluentEnglish.set({
    'WordsTapped': wordsTapped,
    'SentencesTapped': "",
    'userId': userId,
  }).then((_) {
    print(userId);
  }).catchError((e) {
    print('Error adding/updating documenttttt: $e');
  });*/ /*
  }*/

  Future<void> createDocumentWithSpecificIdPL() async {
    String userId = await SharedPref.getSavedString('userId');
    print("userIdfdhfihi:$userId");

    for (int i = 0; i < _processLeaning.length; i++) {
      if (_processLeaning[i].subcategories != null) {
        print("categories name: ${_processLeaning[i].subcategories}");
        for (int j = 0; j < _processLeaning[i].subcategories!.length; j++) {
          print(
              "processLearning Subcategoreis length:${_processLeaning[i].subcategories!.length}");
          if (_processLeaning[i].subcategories![j].link != null) {
            if (_processLeaning[i].subcategories![j].link!.isNotEmpty) {
              print(
                  "linkCheckkkk:${_processLeaning[i].subcategories![j].link!.isNotEmpty}");
              print("linkkkkkkk:${_processLeaning[i].subcategories![j].link}");
              activeLinkCountPL += 1;
            }
          }
          if (_processLeaning[i].subcategories![j].linkCats != null) {
            print("sdmkmgmrgmv");
            for (int z = 0;
                z < _processLeaning[i].subcategories![j].linkCats!.length;
                z++) {
              print("samkdmv");
              if (_processLeaning[i]
                      .subcategories![j]
                      .linkCats![z]
                      .simulation !=
                  null) {
                if (_processLeaning[i]
                    .subcategories![j]
                    .linkCats![z]
                    .simulation!
                    .isNotEmpty) {
                  print(
                      "simulationLink:${_processLeaning[i].subcategories![j].linkCats![z].simulation!}");
                  print("dfdjj");
                  activeSimulationCountPL += 1;
                  print("activeSimulationCountPL:${activeSimulationCountPL}");
                }
              }
              if (_processLeaning[i].subcategories![j].linkCats![z].video !=
                  null) {
                if (_processLeaning[i]
                    .subcategories![j]
                    .linkCats![z]
                    .video!
                    .isNotEmpty) {
                  print(
                      "videoLinkkk:${_processLeaning[i].subcategories![j].linkCats![z].video!}");
                  activeVideoCountPL += 1;
                  print("activeVideoCountPl:$activeVideoCountPL");
                }
              }
              if (_processLeaning[i].subcategories![j].linkCats![z].faq !=
                  null) {
                if (_processLeaning[i]
                    .subcategories![j]
                    .linkCats![z]
                    .faq!
                    .isNotEmpty) {
                  print(
                      "faqLink:${_processLeaning[i].subcategories![j].linkCats![z].faq!}");
                  activeFAQCountPL += 1;
                  print("activeFAQCountPl:$activeFAQCountPL");
                }
              }
              if (_processLeaning[i].subcategories![j].linkCats![z].knowledge !=
                  null) {
                if (_processLeaning[i]
                    .subcategories![j]
                    .linkCats![z]
                    .knowledge!
                    .isNotEmpty) {
                  print(
                      "knowledgeLink:${_processLeaning[i].subcategories![j].linkCats![z].knowledge!}");
                  activeKnowledgePL += 1;
                  print("activeKnowledgePL:$activeKnowledgePL");
                }
              }
            }
          }
        }
        totalActiveLinkCountPL = activeLinkCountPL +
            activeSimulationCountPL +
            activeVideoCountPL +
            activeFAQCountPL +
            activeKnowledgePL;
        print("activeLinkCountPL:${activeLinkCountPL}");
        print('activeSimulationCountPl:$activeSimulationCountPL');
        print('activeVideoCountPL:$activeVideoCountPL');
        print('activeFAQCountPL:$activeFAQCountPL');
        print('activeKnowledgePL:$activeKnowledgePL');
        print('activeSimulationCountPl:$activeSimulationCountPL');
        print("totalActiveLinkCountpl:$totalActiveLinkCountPL");
      }
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference processLearningReport =
        firestore.collection('processLearningReports').doc(userId);

    DocumentSnapshot snapshot = await processLearningReport.get();

    if (snapshot.exists && snapshot.data() != null) {
      print("snapshotAlreadyExists");
      setState(() {
        processLearningLinks = List<String>.from(snapshot['isLink']);
        processLearningProgressBar =
            processLearningLinks.length / totalActiveLinkCountPL;
        print("processLearningProgressBar:$processLearningProgressBar");
        print("processLearningLinkLenth:${processLearningLinks.length}");
        print("totalActiveLinkCountPL:${totalActiveLinkCountPL}");
      });
    }
    String company = await SharedPref.getSavedString("companyId");
    String batch = await SharedPref.getSavedString("batch");
    await processLearningReport.set({
      'activeLink': totalActiveLinkCountPL,
      'isLink': processLearningLinks,
      'userId': userId,
      'batch': batch,
      "companyId": company
    }).then((_) {
      print(userId);
    }).catchError((e) {
      print('Error adding/updating document: $e');
    });
  }

  Future<void> updateFunction() async {
    print("updateFunctionCalledddddddddd");
    String userId = await SharedPref.getSavedString('userId');
    print("userIdfdhfihi:$userId");
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference arCallSimulations =
        firestore.collection('arCallSimulationsReport').doc(userId);
    print("arcallsimulation:$arCallSimulations");
    DocumentSnapshot snapshot = await arCallSimulations.get();
    print("Document Exists: ${snapshot.exists}");
    if (snapshot.exists && snapshot.data() != null) {
      print("snapshotAlreadyExistsarcallll");
      List<String> tempArCallSimulationsLinks =
          List<String>.from(snapshot['isLink']);

      setState(() {
        print("dsfeiofeif");
        arCallSimulationsLinks = tempArCallSimulationsLinks;
        print("arCallSimulationsLinks: $arCallSimulationsLinks");
        arCallSimulationsProgressBar =
            arCallSimulationsLinks.length / TotalActiveLinkCount;
        print("arCallSimulationsProgressBar: $arCallSimulationsProgressBar");
        print("TotalActiveLinkCount:$TotalActiveLinkCount");
        print("activeLinkCount: ${activeLinkCount}");
      });
    } else {
      print("snapshot does not exist");
    }

    await arCallSimulations.set({
      'activeLink': TotalActiveLinkCount,
      'isLink': arCallSimulationsLinks,
      'userId': userId,
    }).then((_) {
      print(userId);
    }).catchError((e) {
      print('Error adding/updating document: $e');
    });
  }

  Future<void> createDocumentWithSpecificIdARCallSimulations() async {
    print("sdjfijeijfiejfi");
    String userId = await SharedPref.getSavedString('userId');
    print("userIdfdhfihi:$userId");
    print("categories:${_categoriesAr}");
    for (int i = 0; i < _categoriesAr.length; i++) {
      print(":sjfdjkif");
      if (_categoriesAr[i].subcategories != null) {
        print("categories name: ${_categoriesAr[i].category}");
        print("categories after:${_categories}");
        for (int j = 0; j < _categoriesAr[i].subcategories!.length; j++) {
          if (_categoriesAr[i].subcategories![j].link1!.isNotEmpty) {
            print("Link1 is active:");
            print(_categoriesAr[i].subcategories![j].link1!);
            activeLink1Count += 1;
            print("activeLink1Count: $activeLink1Count");
          }
          if (_categoriesAr[i].subcategories![j].link2!.isNotEmpty) {
            print("Link2 is active:");
            activeLink2Count += 1;
            print("activeLink2Count: $activeLink2Count");
          }
          if (_categoriesAr[i].subcategories![j].link3!.isNotEmpty) {
            print("Link3 is active:");
            activeLink3Count += 1;
            print("activeLink3Count: $activeLink3Count");
          }
        }
        TotalActiveLinkCount =
            activeLink1Count + activeLink2Count + activeLink3Count;
        print("totalActivelinkCount: ${TotalActiveLinkCount}");
      }
    }
    print("forloop completed");
    await updateFunction();
  }

  Widget build(BuildContext context) {
    // double containerWidth = displayWidth(context) * 0.607;
    // double containerHeight = displayHeight(context) / 2.59;
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        width: kIsWeb ? getWidgetWidth(width: 70) : getWidgetWidth(width: 228),
        height: getWidgetHeight(height: kIsWeb ? 360 : 313.39),
        decoration: BoxDecoration(
          color: const Color(0xff34425D),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              // height: containerHeight / 2.5,
              // width: containerWidth,

              //  height: displayHeight(context)/5.293,
              height: getWidgetHeight(height: 153.41),
              width: kIsWeb
                  ? getWidgetWidth(width: 70)
                  : getWidgetWidth(width: 228),
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                color: const Color(0xFFFFFFFF),
                image: DecorationImage(
                  image: AssetImage(widget.menuImage),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // SPH(containerHeight * 0.03),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      widget.menu,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 17.5,
                        letterSpacing: 0,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    // SPH(containerHeight * 0.03),
                    Text(
                      widget.menu == "Soft Skills"
                          ? "Campus to Corporate, Being Smart & Effective on AR Calls, Meeting Etiquette..."
                          : widget.menu == "AR Call Simulation"
                              ? "Non-denials Follow Up, Denial Management, Auto Insurance..."
                              : widget.menu == "Process Learning"
                                  ? "Revenue Cycle Management, Accounts Receivable Management..."
                                  : "Fast Track Pronunciation for AR, Sounds, Sentence Construction...",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        color: const Color.fromARGB(125, 255, 255, 255),
                        fontSize: 14,
                        letterSpacing: 0,
                      ),
                    ),
                    // SPH(containerHeight * 0.03),
                    // Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6C63FE),
                            fontSize: 13.15,
                            letterSpacing: 0,
                          ),
                        ),
                        // const Spacer(),
                        widget.menu != "Profluent English"
                            ? Column(
                                children: [
                                  SizedBox(
                                    height: 7,
                                  ),
                                  isLoading
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              left: getWidgetWidth(width: 30)),
                                          height: getWidgetHeight(height: 7.62),
                                          width: getWidgetHeight(height: 10),
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 1,
                                          ))
                                      : Column(
                                          children: [
                                            LinearPercentIndicator(
                                              barRadius:
                                                  const Radius.circular(50),
                                              // width: displayWidth(context)/2.652,
                                              width: kIsWeb
                                                  ? getWidgetWidth(width: 50)
                                                  : getWidgetWidth(
                                                      width: 141.35),
                                              // lineHeight: displayHeight(context)/105.867,
                                              lineHeight:
                                                  getWidgetHeight(height: 6),
                                              percent: widget.menu ==
                                                      "Soft Skills"
                                                  ? softSkillProgressBar
                                                  : widget.menu ==
                                                          "AR Call Simulation"
                                                      ? arCallSimulationsProgressBar
                                                      : widget.menu ==
                                                              "Process Learning"
                                                          ? processLearningProgressBar
                                                          : 0.44,
                                              backgroundColor:
                                                  const Color(0xFFFFFFFF),
                                              progressColor:
                                                  const Color(0xFF6C63FE),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              widget.menu == "Soft Skills"
                                                  ? (softSkillProgressBar * 100)
                                                          .round()
                                                          .toString() +
                                                      '%'
                                                  : widget.menu ==
                                                          "AR Call Simulation"
                                                      ? (arCallSimulationsProgressBar *
                                                                  100)
                                                              .round()
                                                              .toString() +
                                                          '%'
                                                      : widget.menu ==
                                                              "Process Learning"
                                                          ? (processLearningProgressBar *
                                                                      100)
                                                                  .round()
                                                                  .toString() +
                                                              '%'
                                                          : "0",
                                              style: TextStyle(
                                                fontFamily: Keys.fontFamily,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: 12.05,
                                              ),
                                            ),
                                          ],
                                        )
                                ],
                              )
                            : isLoading
                                ? Container(
                                    margin: EdgeInsets.only(
                                        left: getWidgetWidth(width: 30)),
                                    height: getWidgetHeight(height: 7.62),
                                    width: getWidgetHeight(height: 7.62),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 1,
                                    ))
                                : Row(
                                    children: [
                                      Text(
                                        widget.menu == "Profluent English"
                                            ? " ${wordsProgressPE.toString()}"
                                            : "0",
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                          fontSize: 14,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                      Text(
                                        " Words ",
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w400,
                                          color: const Color.fromARGB(
                                              125, 255, 255, 255),
                                          fontSize: 14,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                      Text(
                                        widget.menu == "Profluent English"
                                            ? sentenceProgressPE.toString()
                                            : "0",
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                          fontSize: 14,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                      Text(
                                        " Sentences",
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w400,
                                          color: const Color.fromARGB(
                                              125, 255, 255, 255),
                                          fontSize: 14,
                                          letterSpacing: 0,
                                        ),
                                      )
                                    ],
                                  ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
