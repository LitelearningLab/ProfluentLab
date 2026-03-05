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
  bool isHovered = false;

  void initState() {
    _getWords();
    super.initState();
  }

  Future<void> createDocumentWithSpecificId() async {
    String userId = await SharedPref.getSavedString('userId');

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

  Future<void> createDocumentWithSpecificIdPL() async {
    String userId = await SharedPref.getSavedString('userId');

    for (int i = 0; i < _processLeaning.length; i++) {
      if (_processLeaning[i].subcategories != null) {
        for (int j = 0; j < _processLeaning[i].subcategories!.length; j++) {
          if (_processLeaning[i].subcategories![j].link != null) {
            if (_processLeaning[i].subcategories![j].link!.isNotEmpty) {
              activeLinkCountPL += 1;
            }
          }
          if (_processLeaning[i].subcategories![j].linkCats != null) {
            for (int z = 0;
                z < _processLeaning[i].subcategories![j].linkCats!.length;
                z++) {
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
                  activeSimulationCountPL += 1;
                }
              }
              if (_processLeaning[i].subcategories![j].linkCats![z].video !=
                  null) {
                if (_processLeaning[i]
                    .subcategories![j]
                    .linkCats![z]
                    .video!
                    .isNotEmpty) {
                  activeVideoCountPL += 1;
                }
              }
              if (_processLeaning[i].subcategories![j].linkCats![z].faq !=
                  null) {
                if (_processLeaning[i]
                    .subcategories![j]
                    .linkCats![z]
                    .faq!
                    .isNotEmpty) {
                  activeFAQCountPL += 1;
                }
              }
              if (_processLeaning[i].subcategories![j].linkCats![z].knowledge !=
                  null) {
                if (_processLeaning[i]
                    .subcategories![j]
                    .linkCats![z]
                    .knowledge!
                    .isNotEmpty) {
                  activeKnowledgePL += 1;
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
      }
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference processLearningReport =
        firestore.collection('processLearningReports').doc(userId);

    DocumentSnapshot snapshot = await processLearningReport.get();

    if (snapshot.exists && snapshot.data() != null) {
      setState(() {
        processLearningLinks = List<String>.from(snapshot['isLink']);
        processLearningProgressBar =
            processLearningLinks.length / totalActiveLinkCountPL;
      });
    }
    String company = await SharedPref.getSavedString("companyId");
    String batch = await SharedPref.getSavedString("batch");
    await processLearningReport
        .set({
          'activeLink': totalActiveLinkCountPL,
          'isLink': processLearningLinks,
          'userId': userId,
          'batch': batch,
          "companyId": company
        })
        .then((_) {})
        .catchError((e) {
          print('Error adding/updating document: $e');
        });
  }

  Future<void> updateFunction() async {
    String userId = await SharedPref.getSavedString('userId');

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference arCallSimulations =
        firestore.collection('arCallSimulationsReport').doc(userId);

    DocumentSnapshot snapshot = await arCallSimulations.get();

    if (snapshot.exists && snapshot.data() != null) {
      List<String> tempArCallSimulationsLinks =
          List<String>.from(snapshot['isLink']);

      setState(() {
        arCallSimulationsLinks = tempArCallSimulationsLinks;
        arCallSimulationsProgressBar =
            arCallSimulationsLinks.length / TotalActiveLinkCount;
      });
    } else {
      print("snapshot does not exist");
    }

    await arCallSimulations
        .set({
          'activeLink': TotalActiveLinkCount,
          'isLink': arCallSimulationsLinks,
          'userId': userId,
        })
        .then((_) {})
        .catchError((e) {
          print('Error adding/updating document: $e');
        });
  }

  Future<void> createDocumentWithSpecificIdARCallSimulations() async {
    String userId = await SharedPref.getSavedString('userId');

    for (int i = 0; i < _categoriesAr.length; i++) {
      if (_categoriesAr[i].subcategories != null) {
        for (int j = 0; j < _categoriesAr[i].subcategories!.length; j++) {
          if (_categoriesAr[i].subcategories![j].link1!.isNotEmpty) {
            activeLink1Count += 1;
          }
          if (_categoriesAr[i].subcategories![j].link2!.isNotEmpty) {
            activeLink2Count += 1;
          }
          if (_categoriesAr[i].subcategories![j].link3!.isNotEmpty) {
            activeLink3Count += 1;
          }
        }
        TotalActiveLinkCount =
            activeLink1Count + activeLink2Count + activeLink3Count;
      }
    }
    await updateFunction();
  }

  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: kIsWeb && isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: kIsWeb
              ? MediaQuery.of(context).size.width / 5
              : getWidgetWidth(width: 228),
          height: kIsWeb ? 340 : getWidgetHeight(height: 320),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xff3d4e6d),
                const Color(0xff2a364d),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered
                  ? const Color(0xFF6C63FE).withOpacity(0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isHovered
                    ? const Color(0xFF6C63FE).withOpacity(0.3)
                    : Colors.black26,
                blurRadius: isHovered ? 25 : 15,
                spreadRadius: isHovered ? 4 : 2,
                offset: isHovered ? const Offset(0, 12) : const Offset(0, 8),
              )
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: kIsWeb ? 160 : getWidgetHeight(height: 160),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        widget.menuImage,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.menu,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                letterSpacing: 0.5,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.menu == "Soft Skills"
                                  ? "Master communication, etiquette, and corporate professionalism."
                                  : widget.menu == "AR Call Simulation"
                                      ? "Interactive scenarios for denial management and insurance."
                                      : widget.menu == "Process Learning"
                                          ? "Deep dive into Revenue Cycle and Accounts Receivable."
                                          : "Perfect your pronunciation and sentence construction.",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF8B85FF),
                                    fontSize: 13,
                                  ),
                                ),
                                if (widget.menu != "Profluent English" &&
                                    !isLoading)
                                  Text(
                                    widget.menu == "Soft Skills"
                                        ? '${(softSkillProgressBar * 100).round()}%'
                                        : widget.menu == "AR Call Simulation"
                                            ? '${(arCallSimulationsProgressBar * 100).round()}%'
                                            : widget.menu == "Process Learning"
                                                ? '${(processLearningProgressBar * 100).round()}%'
                                                : "0%",
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            widget.menu != "Profluent English"
                                ? isLoading
                                    ? SizedBox(
                                        height: 6,
                                        width: 20,
                                        child: LinearProgressIndicator(
                                          backgroundColor: Colors.white24,
                                          color: const Color(0xFF6C63FE),
                                        ),
                                      )
                                    : LinearPercentIndicator(
                                        padding: EdgeInsets.zero,
                                        barRadius: const Radius.circular(10),
                                        width: kIsWeb
                                            ? 150
                                            : getWidgetWidth(width: 150),
                                        lineHeight: 6,
                                        percent: widget.menu == "Soft Skills"
                                            ? softSkillProgressBar.clamp(
                                                0.0, 1.0)
                                            : widget.menu ==
                                                    "AR Call Simulation"
                                                ? arCallSimulationsProgressBar
                                                    .clamp(0.0, 1.0)
                                                : widget.menu ==
                                                        "Process Learning"
                                                    ? processLearningProgressBar
                                                        .clamp(0.0, 1.0)
                                                    : 0.0,
                                        backgroundColor:
                                            Colors.white.withOpacity(0.1),
                                        progressColor: const Color(0xFF6C63FE),
                                      )
                                : isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : FittedBox(
                                        child: Row(
                                          children: [
                                            _buildPEStat(
                                                wordsProgressPE.toString(),
                                                "Words"),
                                            const SizedBox(width: 12),
                                            _buildPEStat(
                                                sentenceProgressPE.toString(),
                                                "Sentences"),
                                          ],
                                        ),
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
        ),
      ),
    );
  }

  Widget _buildPEStat(String count, String label) {
    return Row(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
