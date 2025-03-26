import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';

class OwnWordResultDialog extends StatefulWidget {
  OwnWordResultDialog({Key? key, required this.isCorrect, required this.word, required this.heard}) : super(key: key);
  final String word;
  final String heard;
  final bool isCorrect;

  @override
  _OwnWordResultDialogState createState() {
    return _OwnWordResultDialogState();
  }
}

class _OwnWordResultDialogState extends State<OwnWordResultDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 320,
          // margin: EdgeInsets.only(bottom: 0),
          // padding: EdgeInsets.all(3),
          decoration: new BoxDecoration(
            color: AppColors.c262626,
            borderRadius: new BorderRadius.all(
              const Radius.circular(10.0),
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 80,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: new BoxDecoration(
                  color: AppColors.green,
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10.0), topRight: const Radius.circular(10.0)),
                ),
                child: Align(
                  child: Text("Pronunciation Analysis Report",
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontFamily: Keys.fontFamily)),
                  alignment: Alignment.center,
                ),
              ),
              SPH(20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          height: 30,
                          // width: displayWidth(context) * 0.28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.green[500]!,
                              ),
                              borderRadius:
                                  BorderRadius.circular(10) // use instead of BorderRadius.all(Radius.circular(20))
                              ),
                          child: Text("CORRECT",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: displayWidth(context) * 0.035,
                                  fontFamily: Keys.fontFamily,
                                  color: Colors.green[500])),
                        ),
                        Container(
                          height: 30,
                          width: displayWidth(context) * 0.38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.red[500]!,
                              ),
                              borderRadius:
                                  BorderRadius.circular(10) // use instead of BorderRadius.all(Radius.circular(20))
                              ),
                          child: Text("WRONG/MISSED",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: displayWidth(context) * 0.035,
                                  fontFamily: Keys.fontFamily,
                                  color: Colors.red[500])),
                        ),
                      ],
                    ),
                    SPH(20),
                    Row(
                      children: [
                        Text("Word",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.white, fontSize: 15, fontFamily: Keys.fontFamily)),
                        Icon(
                          Icons.arrow_right_rounded,
                          color: AppColors.white,
                        ),
                        Spacer(),
                        Container(
                          height: 30,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.green[500]!,
                              ),
                              borderRadius:
                                  BorderRadius.circular(10) // use instead of BorderRadius.all(Radius.circular(20))
                              ),
                          child: Text(widget.word,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: displayWidth(context) * 0.035,
                                  fontFamily: Keys.fontFamily,
                                  color: Colors.green[500])),
                        ),
                      ],
                    ),
                    SPH(10),
                    Row(
                      children: [
                        Text("Heard",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, fontFamily: Keys.fontFamily, color: AppColors.white)),
                        Icon(Icons.arrow_right_rounded, color: AppColors.white),
                        Spacer(),
                        Container(
                          height: 30,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          // width: displayWidth(context) * 0.28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: widget.isCorrect ? Colors.green[500]! : Colors.red[500]!,
                              ),
                              borderRadius:
                                  BorderRadius.circular(10) // use instead of BorderRadius.all(Radius.circular(20))
                              ),
                          child: Text(widget.heard,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: displayWidth(context) * 0.035,
                                  fontFamily: Keys.fontFamily,
                                  color: widget.isCorrect ? Colors.green[500] : Colors.red[500])),
                        ),
                      ],
                    ),
                    SPH(20),
                    new Container(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: new BoxDecoration(
                            color: AppColors.green,
                            borderRadius: new BorderRadius.all(
                              Radius.circular(10.0),
                            )),
                        child: new Center(
                          child: new Text(
                            widget.isCorrect
                                ? "Good! Continue to practice!"
                                : "Listen to native speaker carefully and practice more!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontFamily: Keys.fontFamily,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              //  SPH(20),
            ],
          ),
        ),
        Positioned(
            right: 0,
            top: 0,
            child: InkWell(
              onTap: () {
                Get.back();
              },
              child: Icon(
                Icons.cancel,
                color: Colors.red[500],
              ),
            ))
      ],
    );
  }
}
