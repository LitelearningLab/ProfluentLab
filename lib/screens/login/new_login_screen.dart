import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:litelearninglab/common_widgets/custom_button.dart';
import 'package:litelearninglab/constants/all_assets.dart';
import 'package:litelearninglab/constants/app_colors.dart';
import 'package:litelearninglab/constants/enums.dart';
import 'package:litelearninglab/main.dart';
import 'package:litelearninglab/screens/login/unauth_screen.dart';
import 'package:litelearninglab/states/auth_state.dart';
import 'package:litelearninglab/utils/constants.dart';
import 'package:litelearninglab/utils/device_type.dart';
import 'package:litelearninglab/utils/firebase_helper.dart';
import 'package:litelearninglab/utils/shared_pref.dart';
import 'package:litelearninglab/utils/sizes_helpers.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  Timer? _hideTimer;
  bool error = false;
  OverlayEntry? _bottomMessageEntry;
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
    try {
      if (_isLogin) {
        if (_formKey.currentState!.validate()) {
          error = false;
          setState(() {});
          await isUserRegistered(emailController.text.toLowerCase());
        } else {
          showBottomStickyMessage(
              context, "Please enter a valid email address.");
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Please enter a valid email')),
          // );
        }
        return;
      }
      // _isLoading = true;
      // setState(() {});

      final email = emailController.text.trim().toLowerCase();
      final password = passwordController.text;

      final QuerySnapshot userResult = await FirebaseFirestore.instance
          .collection('UserNode')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (userResult.docs.isNotEmpty) {
        final userDoc = userResult.docs.first;
        final userData = userDoc.data() as Map<String, dynamic>;
        final String? companyId = userData['companyid'];
        final String? userStatus = userData['status'];

        if (userStatus != "1") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("User is inactive.",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0XFF34425D),
          ));
          Provider.of<AuthState>(context, listen: false).chnageAuthState();
          return;
        }

        if (companyId == null || companyId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Company not associated with this user.",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0XFF34425D),
          ));
          return;
        }

        final QuerySnapshot companyDoc = await FirebaseFirestore.instance
            .collection('UserNode')
            .where('_id', isEqualTo: companyId)
            .limit(1)
            .get();

        if (companyDoc.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Associated company not found.",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0XFF34425D),
          ));
          return;
        }

        final companydoc = companyDoc.docs.first;
        final companydocData = companydoc.data() as Map<String, dynamic>;
        final String? companyStatus = companydocData['status'];

        if (companyStatus != "1") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Company is inactive.",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0XFF34425D),
          ));
          Provider.of<AuthState>(context, listen: false).chnageAuthState();
          return;
        }

        print("Both user and company are active");

        if (kDebugMode) {
          print("DEBUG MODE: Skipping real OTP API call");
          mobileSendId = "debug_id";
          otp = "123456";
          _start = 30;
          startTimer();
          _isLogin = false;
          setState(() {});
        } else {
          String url = baseUrl + sentOtp;
          String mobileNumber = _usernameController.text;

          try {
            var response =
                await http.post(Uri.parse(url), body: {"phone": mobileNumber});
            print("response of send otp : ${response.body}");
            var decodedResponse = jsonDecode(response.body);

            if (decodedResponse["status"] == false) {
              message = decodedResponse["message"] ?? "";
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(message, style: TextStyle(color: Colors.white)),
                backgroundColor: Color(0XFF34425D),
              ));
            } else {
              mobileSendId = decodedResponse['_id'] ?? "";
              otp = decodedResponse['otp'] ?? "";
              _start = 30;
              startTimer();
              _isLogin = false;
              setState(() {});
            }
          } catch (e) {
            print("Error sending OTP: $e");
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("This mobile number is not registered.",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0XFF34425D),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 20,
            right: 20,
          ),
          duration: Duration(seconds: 3),
        ));
      }
    } catch (e) {
      log("Error during login: $e");
    }
  }

  Future<bool> isUserRegistered(String email) async {
    _isLoading = true;
    setState(() {});
    log("Checking email: $email");

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('UserNode')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      _isLoading = false;
      setState(() {});

      if (snapshot.docs.isNotEmpty) {
        _isLogin = false;
        _isLoading = false;
        setState(() {});
        log("User exists in database");
        return true;
      } else {
        log("User not found in database");
        showBottomStickyMessage(context, "User not registered.");
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("User not registered.")),
        // );
        return false;
      }
    } catch (e) {
      log("Error checking registration: $e");
      _isLoading = false;
      setState(() {});
      return false;
    }
  }

  Future<void> verifyEmailLogin() async {
    log("🟢 Starting email-password login flow...");

    _isLoading = true;
    setState(() {});

    try {
      final email = emailController.text.trim().toLowerCase();
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        log("⚠️ Email or password field is empty");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Email and password cannot be empty.",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0XFF34425D),
        ));
        _isLoading = false;
        setState(() {});
        return;
      }

      log("📡 Verifying credentials for email: $email");

      final userQuery = await FirebaseFirestore.instance
          .collection('UserNode')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        log("🚫 Invalid email or password");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Invalid email or password.",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0XFF34425D),
        ));
        _isLoading = false;
        setState(() {});
        return;
      }

      final userDoc = userQuery.docs.first;
      final userData = userDoc.data() as Map<String, dynamic>;
      final userId = userDoc.id;
      final userStatus = userData['status'];
      final companyId = userData['companyid'];

      log("✅ User fetched: ID=$userId, Status=$userStatus, CompanyID=$companyId");

      if (userStatus != "1") {
        log("🚫 User inactive");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("User is inactive.", style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0XFF34425D),
        ));
        Provider.of<AuthState>(context, listen: false).chnageAuthState();
        return;
      }

      if (companyId == null || companyId.isEmpty) {
        log("🚫 Company ID missing for user");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Company not associated with this user.",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0XFF34425D),
        ));
        return;
      }

      // 🔍 Fetch company document
      final companyQuery = await FirebaseFirestore.instance
          .collection('UserNode')
          .where('_id', isEqualTo: companyId)
          .limit(1)
          .get();

      if (companyQuery.docs.isEmpty) {
        log("🚫 Company not found for ID: $companyId");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Associated company not found.",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0XFF34425D),
        ));
        return;
      }

      final companyDoc = companyQuery.docs.first;
      final companyData = companyDoc.data() as Map<String, dynamic>;
      final companyStatus = companyData['status'];
      log("🏢 Company status: $companyStatus");

      if (companyStatus != "1") {
        log("🚫 Company inactive");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Company is inactive.",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0XFF34425D),
        ));
        Provider.of<AuthState>(context, listen: false).chnageAuthState();
        return;
      }

      // ✅ Device validation (optional for non-web)
      if (!kIsWeb) {
        log("📱 Checking device binding...");
        final deviceId = await const AndroidId().getId();
        final deviceName = await DeviceScreenInfo.getModelName();
        log("🆔 Device ID: $deviceId | Model: $deviceName");

        if (userData.containsKey('imei')) {
          final storedImei = userData['imei'];
          if (storedImei != deviceId) {
            log("🚫 Device mismatch detected. Stored: $storedImei | Current: $deviceId");
            showBottomStickyMessage(context,
                "Your account is linked to another device. Contact your admin.");
            _isLoading = false;
            setState(() {});
            return;
          } else {
            log("✅ Device verified successfully.");
          }
        } else {
          log("🆕 Registering device IMEI for first login...");
          await userDoc.reference.update({
            'imei': deviceId,
            'model': deviceName,
          });
          log("✅ IMEI registered successfully.");
        }
      }

      // 💾 Save user data
      log("💾 Saving login data to SharedPreferences...");
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('email', email);
      await prefs.setString('password', password);
      await SharedPref.saveBool("walkthrough", true);
      await SharedPref.saveString('userId', userId);
      await SharedPref.saveBool('isFirst', true);
      await SharedPref.saveString("phoneNo", userData['mobile'] ?? '');
      await SharedPref.saveString('newCity', userData['city'] ?? '');
      await SharedPref.saveString('newCountry', userData['country'] ?? '');
      await SharedPref.saveString('joinDate', userData['joindate'] ?? '');
      await SharedPref.saveString('endDate', companyData['endDate'] ?? '');
      await SharedPref.saveBool('isLogedInBefore', true);
      await SharedPref.saveString('companyName', "Peter England");

      log("✅ User data saved successfully");

      // 🔄 Trigger AuthState refresh
      Provider.of<AuthState>(context, listen: false).checkAuthStatus();
      log("🎉 Login successful, navigating to main app");
    } catch (e, stack) {
      log("❌ Error during login: $e", stackTrace: stack);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Login failed. Please try again.",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0XFF34425D),
      ));
    } finally {
      _isLoading = false;
      setState(() {});
      log("🔚 Login flow ended");
    }
  }

  void showBottomStickyMessage(BuildContext context, String message) {
    // If a message is already showing, remove it first
    _bottomMessageEntry?.remove();

    _bottomMessageEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        // top: 0,
        child: Material(
          color: Colors.transparent,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            offset: const Offset(0, 0),
            child: Container(
              // height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _bottomMessageEntry?.remove();
                      _bottomMessageEntry = null;
                    },
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_bottomMessageEntry!);
  }

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

  String? validateEmail(String? val) {
    if (val == null || val.isEmpty) {
      setState(() {
        error = true;
      });
      return "Please enter an email address";
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(val)) {
      setState(() {
        error = true;
      });
      return "Please enter a valid email address";
    }

    setState(() {
      error = false;
    });

    return null;
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
    log("datetime${DateTime.now().toString()}");
    return UpgradeAlert(
      dialogStyle: kIsWeb
          ? UpgradeDialogStyle.material
          : (Platform.isAndroid
              ? UpgradeDialogStyle.material
              : UpgradeDialogStyle.cupertino),
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
                padding: EdgeInsets.only(top: 25),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.only(
                        top: isSplitScreen
                            ? getFullWidgetHeight(height: 30)
                            : getWidgetHeight(height: 30),
                        bottom: MediaQuery.of(context).viewInsets.bottom),
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
                              Container(
                                  height: 40,
                                  width: 40,
                                  child: Image.asset(
                                      "assets/images/profluent_ar_icon.png"))
                            ],
                          ),
                        ),
                        SizedBox(height: 40),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getFullWidgetHeight(height: 25),
                          ),
                          child: SizedBox(
                              height: isSplitScreen
                                  ? getFullWidgetHeight(height: 280)
                                  : getWidgetHeight(height: 280),
                              child: Image.asset(_isLogin
                                  ? 'assets/images/undraw_Messaging_app_re_aytg.png'
                                  : 'assets/images/SMSOTP.png')),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getWidgetHeight(height: 25),
                          ),
                          child: Text(
                            !_isLogin
                                ? "Enter Your Password"
                                : "Enter Your Email Address",
                            style: TextStyle(color: Color(0XFFF8F8F8F)),
                          ),
                        ),
                        SizedBox(height: 23),
                        // if (!_isLogin && !_isLoading)
                        //   Container(
                        //     padding: EdgeInsets.symmetric(
                        //         horizontal: getFullWidgetHeight(height: 25)),
                        //     width: kWidth,
                        //     child: PinCodeTextField(
                        //       autoFocus: true,
                        //       autoDisposeControllers: false,
                        //       keyboardType: TextInputType.number,
                        //       textStyle: TextStyle(
                        //         fontFamily: 'Noto',
                        //         color: Colors.black,
                        //         fontSize: 20,
                        //         fontWeight: FontWeight.w700,
                        //         fontStyle: FontStyle.normal,
                        //         letterSpacing: 0.25,
                        //       ),
                        //       length: 6,
                        //       obscureText: false,
                        //       animationType: AnimationType.fade,
                        //       pinTheme: PinTheme(
                        //           shape: PinCodeFieldShape.box,
                        //           borderRadius: BorderRadius.circular(10),
                        //           fieldHeight: 45,
                        //           fieldWidth: 43,
                        //           activeColor: Color(0XFFE8E8E8),
                        //           disabledColor: Color(0XFFE8E8E8),
                        //           inactiveColor:
                        //               redBox ? Colors.red : Color(0XFFE8E8E8),
                        //           selectedColor: Color(0XFFE8E8E8),
                        //           activeFillColor: Color(0XFFE8E8E8),
                        //           inactiveFillColor: Color(0XFFE8E8E8),
                        //           selectedFillColor: Color(0XFFE8E8E8)),
                        //       animationDuration: Duration(milliseconds: 300),
                        //       backgroundColor: Colors.transparent,
                        //       enableActiveFill: true,
                        //       enablePinAutofill: true,
                        //       errorAnimationController: errorController,
                        //       controller: _otp,
                        //       onChanged: (value) {
                        //         resendOnChangedOnTap();
                        //       },
                        //       beforeTextPaste: (text) {
                        //         return true;
                        //       },
                        //       appContext: context,
                        //     ),
                        //   ),
                        // if (_isLogin && !_isLoading)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getWidgetHeight(height: 25),
                          ),
                          child: SizedBox(
                            width:
                                getWidgetWidth(width: kWidth > 500 ? 200 : 375),
                            // height: getWidgetHeight(height: kWidth > 500 ? 75 : 50),
                            child: TextFormField(
                              cursorColor: Colors.black,
                              controller: !_isLogin
                                  ? passwordController
                                  : emailController,
                              keyboardType: !_isLogin
                                  ? TextInputType.text
                                  : TextInputType.emailAddress,
                              obscureText: !_isLogin ? _obscurePassword : false,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (value) {
                                _bottomMessageEntry?.remove();
                                _bottomMessageEntry = null;
                                if (!_isLogin) {
                                  _isLoading = false;
                                  setState(() {});
                                }
                                _isLogin ? loginNew() : verifyEmailLogin();
                                // login();
                              },
                              validator: (val) {
                                if (_isLogin) {
                                  return validateEmail(val);
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                counterText: "",
                                hintText:
                                    !_isLogin ? "Password" : "Email Address",
                                hintStyle: TextStyle(color: Colors.grey[600]),
                                fillColor: Color(0XFFE8E8E8),
                                filled: true,
                                prefixIcon: Icon(
                                  !_isLogin ? Icons.lock : Icons.email,
                                  color: Colors.grey,
                                ),
                                suffixIcon: !_isLogin
                                    ? IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });

                                          if (!_obscurePassword) {
                                            _hideTimer?.cancel();

                                            _hideTimer =
                                                Timer(Duration(seconds: 1), () {
                                              if (mounted) {
                                                setState(() {
                                                  _obscurePassword = true;
                                                });
                                              }
                                            });
                                          }
                                        },
                                      )
                                    : null,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 10,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0XFFE8E8E8)),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0XFFE8E8E8)),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 23),
                        if (!_isLoading)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: getFullWidgetHeight(height: 25),
                            ),
                            child: SizedBox(
                              width: getWidgetWidth(
                                  width: kWidth > 500 ? 200 : 375),
                              height: getWidgetHeight(
                                  height: kWidth > 500 ? 40 : 50),
                              child: CustomButton(
                                buttonText: _isLogin
                                    ? "Verify Login"
                                    : "Verify & Login",
                                onPressed: () async {
                                  _bottomMessageEntry?.remove();
                                  _bottomMessageEntry = null;
                                  if (!_isLogin) {
                                    _isLoading = false;
                                    setState(() {});
                                  }
                                  _isLogin
                                      ? await loginNew()
                                      : await verifyEmailLogin();
                                },
                              ),
                            ),
                          ),
                        if (_isLoading)
                          const Center(
                            child: SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xff293750)))),
                          ),
                        SizedBox(height: 15),
                        if (!_isLogin && !_isLoading)
                          TextButton(
                            onPressed: () {
                              passwordController.clear();
                              _isLogin = false;
                              setState(() {});
                            },
                            child: const Text(
                              "<< Back",
                              style: TextStyle(color: Colors.black),
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
