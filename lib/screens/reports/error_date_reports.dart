import 'package:flutter/material.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/models/ProLab.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';

import '../../common_widgets/background_widget.dart';

class ErrorsDateReports extends StatefulWidget {
  ErrorsDateReports({Key? key, required this.words}) : super(key: key);
  final List<ProLab> words;

  @override
  _ErrorsDateReportsState createState() {
    return _ErrorsDateReportsState();
  }
}

class _ErrorsDateReportsState extends State<ErrorsDateReports> {
  List<ProLab> _reports = [];
  FirebaseHelper db = new FirebaseHelper();

  @override
  void initState() {
    super.initState();
    _reports = widget.words;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: Colors.white),
        leadingWidth: 30,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PRONUNCIATION LAB REPORT",
              style: TextStyle(
                  fontFamily: Keys.fontFamily,
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              "CLICK ON THE WORD FOR DETAILED REPORT",
              style: TextStyle(
                  fontFamily: Keys.fontFamily,
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          SPH(20),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            //width: 300,
            height: 60,
            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  bottomLeft: Radius.circular(40.0)),
              color: AppColors.primary,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: new BoxDecoration(
                        borderRadius:
                            new BorderRadius.all(Radius.circular(40.0)),
                        color: AppColors.c40000000,
                      ),
                      child: Image.asset(
                        AllAssets.calndr,
                        width: 30,
                      )),
                  SPW(10),
                  Text(
                    _reports.first.word ?? "",
                    style: TextStyle(
                        fontFamily: Keys.fontFamily,
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: new BoxDecoration(
                        borderRadius:
                            new BorderRadius.all(Radius.circular(40.0)),
                        color: AppColors.c40000000,
                      ),
                      child: Image.asset(
                        AllAssets.clock,
                        width: 30,
                      )),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            color: Colors.white,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: _reports.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      children: [
                        if (index == 0)
                          Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 7),
                              decoration: new BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: new BorderRadius.all(
                                    Radius.circular(10.0),
                                  )),
                              child: new Center(
                                child: new Text(
                                  "CLICK HERE TO PRACTICE",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    fontFamily: Keys.fontFamily,
                                  ),
                                ),
                              )),
                        if (index == 0) SPH(20),
                        if (index == 0)
                          Container(
                            height: 30,
                            width: 150,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(
                                    10) // use instead of BorderRadius.all(Radius.circular(20))
                                ),
                            child: Text("Detailed Report",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: Keys.fontFamily,
                                    color: Colors.black)),
                          ),
                        if (index == 0) SPH(20),
                        if (index == 0)
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: Text(
                                  "           DATE",
                                  style: TextStyle(
                                      fontFamily: Keys.fontFamily,
                                      fontSize: 9,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5),
                                child: Text(
                                  "WRONG",
                                  style: TextStyle(
                                      fontFamily: Keys.fontFamily,
                                      fontSize: 9,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5),
                                child: Text(
                                  "CORRECT",
                                  style: TextStyle(
                                      fontFamily: Keys.fontFamily,
                                      fontSize: 9,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        Container(
                          //width: 300,
                          height: 40,
                          child: Row(
                            children: [
                              Image.asset(
                                AllAssets.calndr,
                                width: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5),
                                child: Text(
                                  _reports[index].date ?? "",
                                  style: TextStyle(
                                      fontFamily: Keys.fontFamily,
                                      fontSize: 12,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: new BoxDecoration(
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(40.0)),
                                    color: AppColors.c40000000,
                                  ),
                                  child: Text(
                                    ((_reports[index].pracatt ?? 0) -
                                            (_reports[index].correct ?? 0))
                                        .toString(),
                                    style: TextStyle(
                                        fontFamily: Keys.fontFamily,
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                width: 1,
                                height: double.maxFinite,
                                color: AppColors.c40000000,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: new BoxDecoration(
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(40.0)),
                                    color: AppColors.c40000000,
                                  ),
                                  child: Text(
                                    _reports[index].correct.toString(),
                                    style: TextStyle(
                                        fontFamily: Keys.fontFamily,
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
