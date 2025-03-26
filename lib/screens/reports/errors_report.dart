import 'package:flutter/material.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/models/ProLab.dart';
import 'package:litelearninglab/screens/reports/pronunciation_report.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/background_widget.dart';
import 'error_date_reports.dart';

class ErrorsReport extends StatefulWidget {
  ErrorsReport({Key? key}) : super(key: key);

  @override
  _ErrorsReportState createState() {
    return _ErrorsReportState();
  }
}

class _ErrorsReportState extends State<ErrorsReport> {
  Map<String, ProReport> _reports = {};
  FirebaseHelper db = new FirebaseHelper();

  @override
  void initState() {
    super.initState();
    _getReports();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getReports() async {
    AuthState userDatas = Provider.of<AuthState>(context, listen: false);
    var reports = await db.getErrorsReport(userDatas.appUser!.id!);
    for (ProLab pl in reports) {
      if (_reports[pl.word] == null) {
        _reports[pl.word!] = ProReport();
        _reports[pl.word]!.words = [];
      }
      _reports[pl.word]!.words?.add(pl);
      _reports[pl.word]?.correct =
          (_reports[pl.word]?.correct ?? 0) + (pl.correct ?? 0);
      _reports[pl.word]?.pracatt =
          (_reports[pl.word]?.pracatt ?? 0) + (pl.pracatt ?? 0);
    }
    setState(() {});
    print(_reports.length);
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
              "PRONUNCIATION ERRORS FROM SPEECH LAB",
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
      body: ListView.builder(
          shrinkWrap: true,
          itemCount: _reports.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                children: [
                  if (index == 0)
                    Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "FOCUS WORD",
                            style: TextStyle(
                                fontFamily: Keys.fontFamily,
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "WRONG",
                            style: TextStyle(
                                fontFamily: Keys.fontFamily,
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "CORRECT",
                            style: TextStyle(
                                fontFamily: Keys.fontFamily,
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ErrorsDateReports(
                                    words: _reports[
                                            _reports.keys.toList()[index]]!
                                        .words!,
                                  )));
                    },
                    child: Container(
                      //width: 300,
                      height: 60,
                      decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.only(
                            topLeft: Radius.circular(40.0),
                            bottomLeft: Radius.circular(40.0)),
                        color: AppColors.primary,
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              _reports.keys.toList()[index],
                              style: TextStyle(
                                  fontFamily: Keys.fontFamily,
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.all(
                                    Radius.circular(40.0)),
                                color: AppColors.c40000000,
                              ),
                              child: Text(
                                ((_reports[_reports.keys.toList()[index]]
                                                ?.pracatt ??
                                            0) -
                                        (_reports[_reports.keys
                                                    .toList()[index]]
                                                ?.correct ??
                                            0))
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.all(
                                    Radius.circular(40.0)),
                                color: AppColors.c40000000,
                              ),
                              child: Text(
                                _reports[_reports.keys.toList()[index]]
                                        ?.correct
                                        .toString() ??
                                    "0",
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
                  ),
                ],
              ),
            );
          }),
    );
  }
}
