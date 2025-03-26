import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class ShowCaseView extends StatelessWidget {
  const ShowCaseView(
      {key,
      required this.globalKey,
      required this.title,
      required this.description,
      required this.child,
      this.shapeBorder = const CircleBorder()});

  final GlobalKey globalKey;
  final String title;
  final String description;
  final Widget child;
  final ShapeBorder shapeBorder;

  @override
  Widget build(BuildContext context) {
    double kHeight = 0.0;
    double kWidth = 0.0;
    late TextScaler kText;

    kHeight = MediaQuery.of(context).size.height;
    kWidth = MediaQuery.of(context).size.width;
    kText = MediaQuery.of(context).textScaler;

    return Showcase.withWidget(
      //title: title,
      key: globalKey,
      targetShapeBorder: shapeBorder,
      //description: description,
      child: child,
      targetPadding: EdgeInsets.all(8),
      height: MediaQuery.of(context).size.height / 2,
      width: double.infinity,
      container: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Text(title, style: TextStyle(color: Colors.white, fontSize: kText.scale(12))),
            Text(
              description,
              style: TextStyle(color: Colors.white, fontSize: kText.scale(14)),
            ),
            SizedBox(
              height: kHeight / 27.06,
              child: TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.white),
                child: Text(
                  "skip",
                  style: TextStyle(color: Colors.black, fontSize: kText.scale(10)),
                ),
                onPressed: ShowCaseWidget.of(context).dismiss,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
