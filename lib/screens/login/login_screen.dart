import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:litelearninglab/common_widgets/background_widget.dart';
import 'package:litelearninglab/common_widgets/custom_button.dart';
import 'package:litelearninglab/common_widgets/spacings.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/keys.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  TextEditingController _otp = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _verificationId;
  StreamController<ErrorAnimationType>? errorController;
  late AuthState _authState;
  bool _isLogin = true;
  bool _isLoading = false;
  Timer? _timer;
  int _start = 30;
  @override
  void dispose() {
    _usernameController.dispose();
    _otp.dispose();
    _timer?.cancel();
    // _passwordController.dispose();
    super.dispose();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  // Future<void> _login() async {
  //   FocusManager.instance.primaryFocus?.unfocus();
  //   setState(() {});
  //   if (!_formKey.currentState!.validate()) return;
  //   _authState = Provider.of<AuthState>(context, listen: false);
  //   await _authState.signInWithPhoneNumber('+91 ${_usernameController.text}', onVerificationId: (val) async {
  //     _verificationId = val;
  //     if (val != null) {
  //       await SharedPref.saveString("phoneNo", _usernameController.text);
  //       if (mounted)
  //         setState(() {
  //           _isLogin = false;
  //           _isLoading = false;
  //           _start = 30;
  //           startTimer();
  //         });
  //     }
  //   }, onError: (val) {
  //     if (mounted) {
  //       setState(() {
  //         _isLogin = true;
  //         _isLoading = false;
  //       });
  //     }
  //   });
  //   setState(() {
  //     _isLoading = true;
  //   });
  // }

  // Future<void> _verifyOTP() async {
  //   FocusManager.instance.primaryFocus?.unfocus();
  //   _isLoading = true;
  //   bool result = false;
  //   setState(() {});
  //   try {
  //     result = await _authState.signInWithSmsCode(_otp.text, _verificationId!);
  //   } catch (e) {
  //     log("error >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
  //     print(e);
  //     // Utils.showToast(ToastType.ERROR, e.toString());
  //   }
  //   if (!result) {
  //     _isLoading = false;
  //     Toast.show(
  //       "Invalid OTP. Please check and try again",
  //       duration: Toast.lengthLong,
  //       gravity: Toast.bottom,
  //       backgroundColor: AppColors.white,
  //       textStyle: TextStyle(color: AppColors.black),
  //       backgroundRadius: 10,
  //     );
  //   }else{
  //     await SharedPref.saveBool('isFirst', true);
  //   }
  //   // allLoading = false;
  //   setState(() {});
  // }

  // Future<void> _resendOTP() async {
  //   setState(() {
  //     _isLoading = true;
  //     _start = 30;
  //   });
  //   await _login();
  //   startTimer();
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      body: ListView(
        children: [
          Form(
            key: _formKey,
            child: Container(
              height: displayHeight(context),
              width: displayWidth(context),
              // color: Color(0xff202328),
              color: Color(0xff293750),
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Image(
                      image: AssetImage(AllAssets.icon),
                      width: 140,
                      height: 140,
                    ),
                    SPH(20),
                    Text(
                      "Profluent",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.white, fontFamily: Keys.fontFamily, fontSize: 35),
                    ),
                    SPH(20),
                    Stack(
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
                                      color: AppColors.white,
                                      fontFamily: Keys.fontFamily,
                                      fontStyle: FontStyle.italic)),
                            )),
                      ],
                    ),
                    SPH(30),
                    if (!_isLogin && !_isLoading)
                      PinCodeTextField(
                        autoFocus: true,
                        autoDisposeControllers: false,
                        keyboardType: TextInputType.number,
                        textStyle: TextStyle(
                          fontFamily: 'Noto',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          letterSpacing: 0.25,
                        ),
                        length: 6,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.underline,
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 40,
                          fieldWidth: displayWidth(context) * 0.08,
                          activeColor: Colors.white,
                          disabledColor: Colors.white,
                          inactiveColor: Colors.white,
                          selectedColor: Colors.green,
                          activeFillColor: Colors.white,
                        ),
                        animationDuration: Duration(milliseconds: 300),
                        backgroundColor: Colors.transparent,
                        enableActiveFill: false,
                        errorAnimationController: errorController,
                        controller: _otp,
                        onChanged: (value) {},
                        beforeTextPaste: (text) {
                          return true;
                        },
                        appContext: context,
                      ),
                    if (_isLogin && !_isLoading)
                      TextFormField(
                        controller: _usernameController,
                        keyboardType: TextInputType.phone,
                        // inputFormatters: [TextInputFormatter],
                        style: new TextStyle(color: Colors.white),
                        validator: (val) {
                          if (val!.length < 10) return "Please enter phone number";
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          labelText: 'Phone number',
                          labelStyle: TextStyle(color: AppColors.white),
                        ),
                      ),
                    SPH(20),
                    if (!_isLogin && !_isLoading)
                      Row(
                        children: [
                          Text(
                            '''Didn't receive OTP ?''',
                            style: TextStyle(color: AppColors.white),
                          ),
                          SPW(10),
                          if (_start == 0)
                            GestureDetector(
                              onTap: () async {
                                // await _resendOTP();
                              },
                              child: Text(
                                'Resend',
                                style: TextStyle(color: AppColors.blue),
                              ),
                            ),
                          if (_start > 0)
                            Text(
                              'Resend in $_start seconds',
                              style: TextStyle(color: AppColors.chatBack),
                            ),
                        ],
                      ),
                    SPH(20),
                    if (!_isLoading)
                      CustomButton(
                        buttonText: _isLogin ? "SEND OTP" : "VERIFY OTP",
                        onPressed: () async {
                          // _isLogin ? await _login() : await _verifyOTP();
                        },
                      ),
                    if (_isLoading)
                      Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    SPH(30),
                    Spacer(),
                    if (!_isLoading && _isLogin)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          'Version 1.2.0',
                          style: TextStyle(
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
