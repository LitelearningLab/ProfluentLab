// import 'package:after_layout/after_layout.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:litelearninglab/constants/all_assets.dart';
// import 'package:litelearninglab/constants/app_colors.dart';
// import 'package:litelearninglab/constants/keys.dart';
// import 'package:litelearninglab/screens/call_flow/call_flow_cat_screen.dart';
// import 'package:litelearninglab/screens/dashboard/widgets/drop_down_menu.dart';
// import 'package:litelearninglab/screens/dashboard/widgets/first_row_menu.dart';
// import 'package:litelearninglab/screens/dashboard/widgets/search_field.dart';
// import 'package:litelearninglab/screens/dashboard/widgets/second_row_menu.dart';
// import 'package:litelearninglab/screens/dashboard/widgets/sub_menu_item.dart';
// import 'package:litelearninglab/screens/grammer_check/grammer_check_screen.dart';
// import 'package:litelearninglab/screens/process_learning/process_learning_screen.dart';
// import 'package:litelearninglab/screens/reports/pronunciation_report.dart';
// import 'package:litelearninglab/screens/reports/speech_report.dart';
// import 'package:litelearninglab/screens/sentences/sentences_screen.dart';
// import 'package:litelearninglab/screens/softskills/softskills_screen.dart';
// import 'package:litelearninglab/screens/word_screen/word_screen.dart';
// import 'package:litelearninglab/states/auth_state.dart';
// import 'package:litelearninglab/utils/sizes_helpers.dart';
// import 'package:provider/provider.dart';

// import '../../common_widgets/background_widget.dart';
// import '../../common_widgets/common_drawer.dart';
// import '../interactive_simulations/interactive_screen.dart';
// import '../profluent_english/profluent_english_screen.dart';
// import '../reports/call_flow_report.dart';

// class DashboardScreen extends StatefulWidget {
//   DashboardScreen({Key? key}) : super(key: key);

//   @override
//   _DashboardScreenState createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen>
//     with AfterLayoutMixin<DashboardScreen> {
//   bool _isProMenuOpen = false;
//   bool _isSentMenuOpen = false;
//   bool _isCallMenuOpen = false;
//   bool _isPerMenuOpen = false;

//   ScrollController _scrollController = new ScrollController();
//   late AuthState user;

//   @override
//   void initState() {

//     super.initState();
//     user = Provider.of<AuthState>(context, listen: false);
//   }

//   @override
//   void afterFirstLayout(BuildContext context) {}

//   @override
//   void dispose() {
//     super.dispose();
//   }




//   @override
//   Widget build(BuildContext context) {
//     return BackgroundWidget(
//         appBar: AppBar(
//           iconTheme: IconThemeData(color: Colors.white),
//           backgroundColor: Color(0xff333a40),
//           title: Stack(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(right: 18.0),
//                 child: Text(
//                   "Profluent",
//                   style: TextStyle(
//                       fontFamily: Keys.fontFamily,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.white,
//                       fontSize: 22),
//                 ),
//               ),
//               Positioned(
//                 right: 0,
//                 child: Text(
//                   "TM",
//                   style: TextStyle(
//                       fontFamily: Keys.fontFamily,
//                       color: Colors.white,
//                       fontSize: 11),
//                 ),
//               )
//             ],
//           ),
//         ),
//         drawer: CommonDrawer(),
//         body: ListView(
//           controller: _scrollController,
//           children: [
//             SearchField(),
//             Row(
//               children: [
//                 FirstRowMenu(
//                   onTap: () {
//                     print("getProcessLearning");
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => ProcessLearningScreen()));
//                   },
//                   backgroundImage: AllAssets.process,
//                   menuImage: AllAssets.processcenter,
//                   menu: "PROCESS\nLEARNING",
//                 ),
//                 Spacer(),
//                 FirstRowMenu(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => SoftSkillsScreen()));
//                   },
//                   backgroundImage: AllAssets.soft,
//                   menuImage: AllAssets.softskk,
//                   menu: "SOFT\nSKILLS",
//                 ),
//                 Spacer(),
//                 FirstRowMenu(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => ProfluentEnglishScreen()));
//                   },
//                   backgroundImage: AllAssets.ameri,
//                   menuImage: AllAssets.amm,
//                   menu: "PROFLUENT\nENGLISH",
//                 ),
//               ],
//             ),
//             Row(
//              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Expanded(
//                   child: SecondRowMenu(
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => InteractiveScreen()));
//                     },
//                     menuImage: AllAssets.interb,
//                     menu: "INTERACTIVE\nSIMULATIONS",
//                   ),
//                 ),
//                 /*SecondRowMenu(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => GrammerCheckScreen()));
//                   },
//                   menuImage: AllAssets.kngl,
//                   menu: "GRAMMAR\nCHECK",
//                 ),*/
//               ],
//             ),
//             Divider(
//               color: AppColors.black,
//               height: 0,
//               thickness: 1,
//             ),
//             /*DropDownMenu(
//               onExpansionChanged: (val) {
//                 _isProMenuOpen = val;
//                 _isCallMenuOpen = false;
//                 _isPerMenuOpen = false;
//                 _isSentMenuOpen = false;
//                 setState(() {});
//               },
//               isExpand: _isProMenuOpen &&
//                   !_isCallMenuOpen &&
//                   !_isPerMenuOpen &&
//                   !_isSentMenuOpen,
//               icon: AllAssets.cvv1,
//               title: "PRONUNCIATION LAB",
//               children: [
//                 SubMenuItem(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => WordScreen(
//                                   title: "Days, Dates, Months & Numbers",
//                                   load: "daysdates",
//                                 )));
//                   },
//                   backgroundImage: AllAssets.back1,
//                   menuText: "Days, Dates, Months & Numbers",
//                   image: AllAssets.cvv1,
//                 ),
//                 SubMenuItem(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => WordScreen(
//                                   title: "Letters & NATP Phonetic Codes",
//                                   load: "Latters and NATO",
//                                 )));
//                   },
//                   backgroundImage: AllAssets.back2,
//                   menuText: "Letters & NATP Phonetic Codes",
//                   image: AllAssets.cvv1,
//                 ),
//                 SubMenuItem(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => WordScreen(
//                                   title: "US States & Cities",
//                                   load: "States and Cities",
//                                 )));
//                   },
//                   backgroundImage: AllAssets.back1,
//                   menuText: "US States & Cities",
//                   image: AllAssets.cvv1,
//                 ),
//                 SubMenuItem(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => WordScreen(
//                                   title: "Most Commonly Used Words",
//                                   load: "CommonWords",
//                                 )));
//                   },
//                   backgroundImage: AllAssets.back2,
//                   menuText: "Most Commonly Used Words",
//                   image: AllAssets.cvv1,
//                 ),
//                 SubMenuItem(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => WordScreen(
//                                   title: "Common American Names",
//                                   load: "ProcessWords",
//                                 )));
//                   },
//                   backgroundImage: AllAssets.back1,
//                   menuText: "Common American Names",
//                   image: AllAssets.cvv1,
//                 ),
//                 SubMenuItem(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => WordScreen(
//                                   title:
//                                       "US Healthcare - Revenue Cycle Management",
//                                   load: "US Healthcare",
//                                 )));
//                   },
//                   backgroundImage: AllAssets.back2,
//                   menuText: "US Healthcare - Revenue Cycle Management",
//                   image: AllAssets.cvv1,
//                 ),
//                 SubMenuItem(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => WordScreen(
//                                   title: "Restaurant, Hotel & Travel",
//                                   load: "Restaurant Hotel Travel",
//                                 )));
//                   },
//                   backgroundImage: AllAssets.back1,
//                   menuText: "Restaurant, Hotel & Travel",
//                   image: AllAssets.cvv1,
//                 ),
//                 SubMenuItem(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => WordScreen(
//                                   title: "Business Words",
//                                   load: "Business Words",
//                                 )));
//                   },
//                   backgroundImage: AllAssets.back2,
//                   menuText: "Business Words",
//                   image: AllAssets.cvv1,
//                 ),
//                 SubMenuItem(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => WordScreen(
//                                   title: "Information Technology",
//                                   load: "Information Technology",
//                                 )));
//                   },
//                   backgroundImage: AllAssets.back1,
//                   menuText: "Information Technology",
//                   image: AllAssets.cvv1,
//                 ),
//               ],
//             ),
//             Divider(
//               color: AppColors.black,
//               height: 0,
//               thickness: 1.5,
//             ),
//             DropDownMenu(
//                 onExpansionChanged: (val) {
//                   _isSentMenuOpen = val;
//                   _isCallMenuOpen = false;
//                   _isPerMenuOpen = false;
//                   _isProMenuOpen = false;
//                   setState(() {});
//                 },
//                 isExpand: _isSentMenuOpen &&
//                     !_isCallMenuOpen &&
//                     !_isPerMenuOpen &&
//                     !_isProMenuOpen,
//                 icon: AllAssets.cvv2,
//                 title: "SENTENCE CONSTRUCTION LAB",
//                 children: [
//                   SubMenuItem(
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => SentencesScreen(
//                                     user: user,
//                                     title: "Professional Call Procedures",
//                                     load: "Professional Call Procedures",
//                                   )));
//                     },
//                     backgroundImage: AllAssets.back1,
//                     menuText: "Professional Call Procedures",
//                     image: AllAssets.cvv2,
//                   ),
//                   SubMenuItem(
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => SentencesScreen(
//                                     user: user,
//                                     title: "Questions Lab",
//                                     load: "Questions Lab",
//                                   )));
//                     },
//                     backgroundImage: AllAssets.back2,
//                     menuText: "Questions Lab",
//                     image: AllAssets.cvv2,
//                   ),
//                   SubMenuItem(
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => SentencesScreen(
//                                     user: user,
//                                     title: "Samples for frequent scenarios",
//                                     load: "Samples for frequent scenarios",
//                                   )));
//                     },
//                     backgroundImage: AllAssets.back1,
//                     menuText: "Samples for frequent scenarios",
//                     image: AllAssets.cvv2,
//                   ),
//                 ]),
//             Divider(
//               color: AppColors.black,
//               height: 0,
//               thickness: 1.5,
//             ),
//             DropDownMenu(
//               onExpansionChanged: (val) {
//                 _isCallMenuOpen = val;
//                 _isSentMenuOpen = false;
//                 _isPerMenuOpen = false;
//                 _isProMenuOpen = false;
//                 setState(() {});
//               },
//               isExpand: _isCallMenuOpen &&
//                   !_isProMenuOpen &&
//                   !_isPerMenuOpen &&
//                   !_isSentMenuOpen,
//               icon: AllAssets.cvv3,
//               title: "CALL FLOW PRACTICE LAB",
//               children: [
//                 SubMenuItem(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => CallFlowCatScreen(
//                                   user: user,
//                                   title: "Denial Management",
//                                   load: "Denial Management",
//                                 )));
//                   },
//                   backgroundImage: AllAssets.back1,
//                   menuText: "Denial Management",
//                   image: AllAssets.cvv3,
//                 ),
//                 SubMenuItem(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => CallFlowCatScreen(
//                                   user: user,
//                                   title: "Non-Denials Follow-up",
//                                   load: "Non Denials Follow up",
//                                 )));
//                   },
//                   backgroundImage: AllAssets.back2,
//                   menuText: "Non-Denials Follow-up",
//                   image: AllAssets.cvv3,
//                 ),
//               ],
//             ),
//             Divider(
//               color: AppColors.black,
//               height: 0,
//               thickness: 1.5,
//             ),*/
//             DropDownMenu(
//               onExpansionChanged: (val) {
//                 _isPerMenuOpen = val;
//                 _isSentMenuOpen = false;
//                 _isCallMenuOpen = false;
//                 _isProMenuOpen = false;
//                 setState(() {});
//                 // _scrollController.animateTo(
//                 //   _scrollController.position.maxScrollExtent,
//                 //   curve: Curves.easeOut,
//                 //   duration: const Duration(milliseconds: 300),
//                 // );
//               },
//               isExpand: _isPerMenuOpen &&
//                   !_isProMenuOpen &&
//                   !_isCallMenuOpen &&
//                   !_isSentMenuOpen,
//               icon: AllAssets.cvv4,
//               title: "PERFORMANCE TRACKING",
//               children: [
//                 SubMenuItem(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => PronunciationReport()));
//                   },
//                   backgroundImage: AllAssets.back1,
//                   menuText: "Pronunciation Lab Report",
//                   image: AllAssets.cvv4,
//                 ),
//                 SubMenuItem(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => SpeechReport()));
//                   },
//                   backgroundImage: AllAssets.back2,
//                   menuText: "Sentence Construction Lab Report",
//                   image: AllAssets.cvv4,
//                 ),
        
//                 SubMenuItem(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => CallFlowReport()));
//                   },
//                   backgroundImage: AllAssets.back2,
//                   menuText: "Call Flow Practice Report",
//                   image: AllAssets.cvv4,
//                 ),
//                 // SubMenuItem(
//                 //   onTap: () {
//                 //     Navigator.push(
//                 //         context,
//                 //         MaterialPageRoute(
//                 //             builder: (context) => ErrorsReport()));
//                 //   },
//                 //   backgroundImage: AllAssets.back1,
//                 //   menuText: "Pronunciation Errors from Speech Lab",
//                 //   image: AllAssets.cvv4,
//                 // ),
//               ],
//             ),
//             Divider(
//               color: AppColors.black,
//               height: 0,
//               thickness: 1.5,
//             ),
//           ],
//         ));
//   }
// }
