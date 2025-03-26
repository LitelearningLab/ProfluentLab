import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';

import '../../common_widgets/background_widget.dart';
import '../../common_widgets/common_app_bar.dart';
import '../../common_widgets/custom_button.dart';
import '../../common_widgets/spacings.dart';
import '../../utils/sizes_helpers.dart';
import '../dialogs/under_construction.dart';

class GrammerCheckScreen extends StatefulWidget {
  GrammerCheckScreen({Key? key}) : super(key: key);

  @override
  _GrammerCheckScreenState createState() {
    return _GrammerCheckScreenState();
  }
}

class _GrammerCheckScreenState extends State<GrammerCheckScreen>
    with AfterLayoutMixin<GrammerCheckScreen> {
  TextEditingController _sentence = TextEditingController();

  @override
  void dispose() {
    _sentence.dispose();
    super.dispose();
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    _openDialog();
  }

  void _openDialog() {
    showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          //this right here
          child: UnderConstruction(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      appBar: CommonAppBar(
        title: "Grammar Check",
        // height: displayHeight(context) / 12.6875,
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Theme(
                  data: new ThemeData(
                      primaryColor: AppColors.primary, hintColor: Colors.green),
                  child: TextFormField(
                    controller: _sentence,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: false,
                    validator: (val) {
                      if (val!.length < 6) return "Please enter word";
                      return null;
                    },
                    style: new TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.white),
                        ),
                        border: new UnderlineInputBorder(
                            borderSide:
                                new BorderSide(color: AppColors.primary)),
                        labelText: 'Try here',
                        labelStyle: TextStyle(color: AppColors.white)),
                  ),
                ),
                SPH(30),
                Container(
                  width: displayWidth(context) * 0.9,
                  child: CustomButton(
                    buttonText: "CHECK GRAMMAR",
                    onPressed: _openDialog,
                  ),
                ),
                SPH(20),
                Text(
                  "Note: This is a beta version with thousands of rules to validate. However if the tool misses to identify any grammar mistakes, mail us your feedback, we will the update the tool ASAP. Thank you for the support.",
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: Keys.fontFamily,
                      color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
