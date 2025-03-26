import 'package:flutter/material.dart';
import 'package:litelearninglab/common_widgets/background_widget.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/custom_button.dart';
import '../../states/auth_state.dart';

class UnauthScreen extends StatefulWidget {
  UnauthScreen({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  _UnauthScreenState createState() {
    return _UnauthScreenState();
  }
}

class _UnauthScreenState extends State<UnauthScreen> {
  @override
  void initState() {
    print("unauthInitstate>>>>>>>>");
    super.initState();
  }

  void didChangeDependencies() {
    print("unauth screen>>>>>>>>>>>>>");
    super.didChangeDependencies();
    getIsSplit(context);
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: isSplitScreen ? getFullWidgetHeight(height: 30) : getWidgetHeight(height: 30)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            //  crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "PROFLUENT",
                    style: TextStyle(fontSize: 30),
                  ),
                  Container(height: 40, width: 40, child: Image.asset("assets/images/profluent_ar_icon.png"))
                ],
              ),
              SPH(20),
              /*  Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Center(child: Image(image: AssetImage(AllAssets.watermark))),
                  ),
                  Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      child: Center(
                        child: Text("Powered by",
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: Keys.fontFamily,
                                fontStyle: FontStyle.italic,
                                fontSize: 15)),
                      )),
                ],
              ),*/
              SPH(widget.text == 'Please Check Your Network Connection' ? 230 : 50),
              Text(
                widget.text,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontFamily: Keys.fontFamily, fontSize: 20),
              ),
              SizedBox(height: 10),
              Image.asset(
                "assets/images/no_network_image.png",
                height: 40,
                width: 40,
              ),
              Spacer(),
              if (widget.text != 'Please Check Your Network Connection')
                CustomButton(
                  buttonText: "Logout",
                  onPressed: () async {
                    AuthState authState = Provider.of<AuthState>(context, listen: false);
                    await authState.signOut();

                    // Navigator.pushReplacement(context,
                    //     MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                ),
              SPH(30),
            ],
          ),
        ),
      ),
    );
  }
}
