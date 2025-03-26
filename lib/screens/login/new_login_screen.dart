import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:litelearninglab/common_widgets/custom_button.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/main.dart';
import 'package:litelearninglab/screens/login/unauth_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:upgrader/upgrader.dart';
import 'package:http/http.dart' as http;

import '../../API/api.dart';

class NewLoginScreen extends StatefulWidget {
  const NewLoginScreen({key});

  @override
  State<NewLoginScreen> createState() => _NewLoginScreenState();
}

class _NewLoginScreenState extends State<NewLoginScreen> {
  @override
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  TextEditingController _otp = TextEditingController();
  late AuthState _authState;
  String? _verificationId;
  StreamController<ErrorAnimationType>? errorController;
  bool _isLogin = true;
  bool _isLoading = false;
  Timer? _timer;
  int _start = 0;
  String mobileSendId = "";
  String otp = "";
  String message = "";
  String city = "";
  String country = "";
  String companyName = "";
  String joinDate = "";
  String endDate = "";
  bool redBox = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _otp.dispose();
    _timer?.cancel();
    // _passwordController.dispose();
    super.dispose();
  }

  loginNew() async {
    print("entering loginNew");
    String url = baseUrl + sentOtp;
    String mobileNumber = _usernameController.text;
    print("url : $url");
    print("mobile number : $mobileNumber");
    try {
      var response = await http.post(Uri.parse(baseUrl + sentOtp), body: {"phone": mobileNumber});
      print("response of send otp : ${response.body}");
      var decodedResponse = jsonDecode(response.body);
      if (decodedResponse["status"] == false) {
        print("status is falseeee");
        message = decodedResponse["message"] ?? "";
        print("message is:$message");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message, style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0XFF34425D),
        ));
      } else {
        print("statuss true");
        mobileSendId = decodedResponse['_id'] ?? "";
        print("smdgjdigjfij: ${country}");
        await SharedPref.saveString('userId', mobileSendId);
        print("useridddd:${await SharedPref.getSavedString('userId')}");
        otp = decodedResponse['otp'] ?? "";
        print("otp is:$otp");
        _start = 30;
        startTimer();
        _isLogin = false;
        /*  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(otp, style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0XFF34425D),
        ));*/
        setState(() {});
      }
    } catch (e) {
      print("error loginnn : $e");
    }
  }

  verifyOtp() async {
    print("dgmdo");
    if (_otp.text.isEmpty || _otp.text.length != 6) {
      print("mcvdmxv");
      redBox = true;
      setState(() {});
    } else {
      _isLoading = true;
      setState(() {});
      print("else function callledd");
      String url = baseUrl + verifyOtpApi;
      String mobileNumber = _usernameController.text;
      print("url : $url");
      print("mobile number : $mobileNumber");
      print("otp : $otp");
      print("id : $mobileSendId");
      try {
        var response = await http.post(Uri.parse(baseUrl + verifyOtpApi), body: {
          "_id": mobileSendId,
          "otp": _otp.text.trim(), //otp
          "mobile": mobileNumber
        });

        print("response otp : ${response.body}");
        print("response otp : ${response.body}");
        final result = jsonDecode(response.body);
        print(result.runtimeType);
        if (result["status"] == true) {
          if (result['userdata']['access'] == "company") {
            city = (result['userdata']['city0'] as List).join(',');
            country = (result['userdata']['country0']);
            companyName = result['userdata']['companyname'];
            joinDate = result['userdata']['joindate'];
            endDate = result["userdata"]["endDate"];

            await SharedPref.saveString('companyName', companyName);
          } else {
            city = result['userdata']['city'] ?? "";
            country = result['userdata']['country'] ?? "";
            joinDate = result['userdata']['joindate'] ?? "";
            endDate = result["userdata"]["endDate"] ?? "";
            print("joindateee:$joinDate");
          }
          await SharedPref.saveBool('isFirst', true);
          await SharedPref.saveString("phoneNo", mobileNumber);
          await SharedPref.saveString('newCity', city);
          await SharedPref.saveString('newCountry', country);
          await SharedPref.saveString('joinDate', joinDate);
          await SharedPref.saveString("endDate", endDate);
          AuthState authState = Provider.of<AuthState>(context, listen: false);
          authState.checkAuthStatus();
        } else {
          redBox = true;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result["message"], style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0XFF34425D),
          ));
        }
      } catch (e) {
        print("error login : $e");
      }
      _isLoading = false;
      setState(() {});
    }
  }

  /*Future<void> _login() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {});
    if (!_formKey.currentState!.validate()) return;
    _authState = Provider.of<AuthState>(context, listen: false);
    await _authState.signInWithPhoneNumber('+91 ${_usernameController.text}', onVerificationId: (val) async {
      _verificationId = val;
      if (val != null) {
        await SharedPref.saveString("phoneNo", _usernameController.text);
        if (mounted)
          setState(() {
            _isLogin = false;
            _isLoading = false;
            _start = 30;
            startTimer();
          });
      }
    }, onError: (val) {
      if (mounted) {
        setState(() {
          _isLogin = true;
          _isLoading = false;
        });
      }
    });
    setState(() {
      _isLoading = true;
    });
  }*/

  /*Future<void> _verifyOTP() async {
    FocusManager.instance.primaryFocus?.unfocus();
    _isLoading = true;
    bool result = false;
    setState(() {});
    try {
      print("checkkk11111111111111111");
      result = await _authState.signInWithSmsCode(_otp.text, _verificationId!);

      print("do[ldkoddi jijjijf");
    } catch (e) {
      log("error >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      print(e);
      // Utils.showToast(ToastType.ERROR, e.toString());
    }
    print("result rsess : $result");
    if (!result) {
      _isLoading = false;
      Toast.show(
        "Invalid OTP. Please check and try again",
        duration: Toast.lengthLong,
        gravity: Toast.bottom,
        backgroundColor: AppColors.white,
        textStyle: TextStyle(color: AppColors.black),
        backgroundRadius: 10,
      );
    } else {
      // _isLoading = false;
      // print("fpofjfifi if if ifj");
      await SharedPref.saveBool('isFirst', true);

      // AuthState authState = AuthState();
      // authState.checkAuthStatus();
      Navigator.push(context, MaterialPageRoute(builder: (context) => AuthWrapper()));

      setState(() {});
    }
    // allLoading = false;
    setState(() {});
  }*/

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
      _otp.clear();
      _start = 30;
    });
    await loginNew();
    startTimer();
    setState(() {
      _isLoading = false;
    });
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

  resendOnChangedOnTap() {
    redBox = false;
    setState(() {});
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
    getIsSplit(context);
    setState(() {});
  }

  Widget build(BuildContext context) {
    return UpgradeAlert(
      dialogStyle: Platform.isAndroid ? UpgradeDialogStyle.material : UpgradeDialogStyle.cupertino,
      showReleaseNotes: false,
      showIgnore: false,
      shouldPopScope: () => true,
      upgrader: Upgrader(
        messages: UpgraderMessages(),
      ),
      child: WillPopScope(
        onWillPop: () async {
          if (!_isLogin) {
            print("Back Button tappeddd");
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => NewLoginScreen()),
            );
            return false;
          }
          return true;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: SizedBox(
              height: kHeight,
              child: Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.only(
                        top: isSplitScreen ? getFullWidgetHeight(height: 30) : getWidgetHeight(height: 30), bottom: MediaQuery.of(context).viewInsets.bottom),
                    width: kWidth,
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getFullWidgetHeight(height: 25),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "PROFLUENT",
                                style: TextStyle(fontSize: 25),
                              ),
                              Container(height: 40, width: 40, child: Image.asset("assets/images/profluent_ar_icon.png"))
                            ],
                          ),
                        ),
                        SizedBox(height: 40),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getFullWidgetHeight(height: 25),
                          ),
                          child: SizedBox(
                              height: isSplitScreen ? getFullWidgetHeight(height: 280) : getWidgetHeight(height: 280),
                              child: Image.asset(_isLogin && !_isLoading ? 'assets/images/undraw_Messaging_app_re_aytg.png' : 'assets/images/SMSOTP.png')),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getFullWidgetHeight(height: 25),
                          ),
                          child: Text(
                            _isLogin && !_isLoading ? "Enter Your Mobile Number" : "Enter the OTP from SMS",
                            style: TextStyle(color: Color(0XFFF8F8F8F)),
                          ),
                        ),
                        SizedBox(height: 23),
                        if (!_isLogin && !_isLoading)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: getFullWidgetHeight(height: 25)),
                            width: kWidth,
                            child: PinCodeTextField(
                              autoFocus: true,
                              autoDisposeControllers: false,
                              keyboardType: TextInputType.number,
                              textStyle: TextStyle(
                                fontFamily: 'Noto',
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                                letterSpacing: 0.25,
                              ),
                              length: 6,
                              obscureText: false,
                              animationType: AnimationType.fade,
                              pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(10),
                                  fieldHeight: 45,
                                  fieldWidth: 43,
                                  activeColor: Color(0XFFE8E8E8),
                                  disabledColor: Color(0XFFE8E8E8),
                                  inactiveColor: redBox ? Colors.red : Color(0XFFE8E8E8),
                                  selectedColor: Color(0XFFE8E8E8),
                                  activeFillColor: Color(0XFFE8E8E8),
                                  inactiveFillColor: Color(0XFFE8E8E8),
                                  selectedFillColor: Color(0XFFE8E8E8)),
                              animationDuration: Duration(milliseconds: 300),
                              backgroundColor: Colors.transparent,
                              enableActiveFill: true,
                              enablePinAutofill: true,
                              errorAnimationController: errorController,
                              controller: _otp,
                              onChanged: (value) {
                                resendOnChangedOnTap();
                              },
                              beforeTextPaste: (text) {
                                return true;
                              },
                              appContext: context,
                            ),
                          ),
                        if (_isLogin && !_isLoading)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: getFullWidgetHeight(height: 25),
                            ),
                            child: Container(
                              height: 50,
                              child: TextFormField(
                                controller: _usernameController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                validator: (val) {
                                  if (val == null || val.length != 10) {
                                    print("validator:$val");
                                    return "Please enter a valid 10-digit phone number";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    counterText: "",
                                    hintText: "Mobile Number",
                                    fillColor: Color(0XFFE8E8E8),
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.all(13),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '+91',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Container(
                                            padding: EdgeInsets.zero,
                                            width: 1,
                                            height: 20,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0XFFE8E8E8)),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0XFFE8E8E8)),
                                      borderRadius: BorderRadius.circular(10.0),
                                    )),
                              ),
                            ),
                          ),
                        SizedBox(height: 23),
                        if (!_isLoading)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: getFullWidgetHeight(height: 25),
                            ),
                            child: CustomButton(
                              buttonText: _isLogin ? "Get OTP" : "Verify & Login",
                              onPressed: () async {
                                print("otppp:${_otp.text.trim()}");
                                print("fvbdvd:${otp.toString().trim()}");
                                _isLogin ? await loginNew() : await verifyOtp();
                              },
                            ),
                          ),
                        if (_isLoading)
                          const Center(
                            child:
                                SizedBox(height: 25, width: 25, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xff293750)))),
                          ),
                        SizedBox(height: 30),
                        if (!_isLogin && !_isLoading)
                          if (_start == 0)
                            GestureDetector(
                              onTap: () async {
                                print("resend otp tappeddd");
                                await _resendOTP();
                              },
                              child: Text(
                                'Resend OTP',
                                style:
                                    TextStyle(color: Color(0XFF9D9D9D), decoration: TextDecoration.underline, decorationColor: Color(0XFFA9A9A9), fontSize: 15),
                              ),
                            ),
                        if (!_isLogin && !_isLoading)
                          //if (!_isLogin && !_isLoading)
                          if (_start > 0)
                            Text(
                              'Resend in $_start seconds',
                              style: TextStyle(color: AppColors.chatBack),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
