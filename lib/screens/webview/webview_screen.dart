import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:litelearninglab/API/api.dart';
import 'package:litelearninglab/screens/process_learning/new_process_learning_screen.dart';
import 'package:litelearninglab/utils/commonfunctions/common_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/background_widget.dart';

class InAppWebViewPage extends StatefulWidget {
  InAppWebViewPage(
      {Key? key,
      required this.url,
      this.isLandscape = false,
      this.isMeetingEtiquite = false})
      : super(key: key);

  final String url;
  final bool isLandscape;
  final bool isMeetingEtiquite;

  @override
  _InAppWebViewPageState createState() => new _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage>
    with AfterLayoutMixin<InAppWebViewPage>, WidgetsBindingObserver {
  bool onLoad = false;

  @override
  void initState() {
    super.initState();

    startTimerMainCategory("name");
    // Add the observer for lifecycle events
    WidgetsBinding.instance.addObserver(this);
  }

  start() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastScreen = prefs.getString("lastYes");
    if (processLearning == lastScreen) {
      startTimerSubCategory(processLearning, pTitle);
    }
  }

  @override
  void dispose() {
    // Remove the observer when the widget is disposed
    WidgetsBinding.instance.removeObserver(this);

    if (widget.isLandscape || widget.isMeetingEtiquite) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    super.dispose();
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    if (widget.isMeetingEtiquite) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else if (widget.isLandscape) {
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.height);
    print(MediaQuery.of(context).size.width);

    return PopScope(
      onPopInvoked: (didPop) {
        stopTimerMainCategory();
      },
      child: BackgroundWidget(
        body: Stack(
          children: [
            Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: InAppWebView(
                        onLoadStop: (controller, url) {
                          setState(() {
                            onLoad = false;
                          });
                        },
                        onLoadStart: (controller, url) {
                          setState(() {
                            onLoad = true;
                          });
                        },
                        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                        initialOptions: InAppWebViewGroupOptions(
                          crossPlatform: InAppWebViewOptions(
                              mediaPlaybackRequiresUserGesture: false,
                              disableContextMenu: true),
                          android: AndroidInAppWebViewOptions(
                            // Disable file access
                            allowFileAccess: false,
                            // Disable content access
                            allowContentAccess: false,
                          ),
                          ios: IOSInAppWebViewOptions(
                            // Disable file access on iOS
                            allowsLinkPreview: false,
                          ),
                        ),
                        onWebViewCreated: (InAppWebViewController controller) {
                          // _webViewController = controller;
                        },
                        onDownloadStartRequest: (controller, request) async {
                          // Block all download requests
                          return;
                        },
                        shouldOverrideUrlLoading:
                            (controller, navigationAction) async {
                          // You can add additional URL filtering here if needed
                          return NavigationActionPolicy.ALLOW;
                        },
                        androidOnPermissionRequest:
                            (InAppWebViewController controller, String origin,
                                List<String> resources) async {
                          return PermissionRequestResponse(
                              resources: resources,
                              action: PermissionRequestResponseAction.GRANT);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!kIsWeb)
              Positioned(
                bottom: 20,
                left: 10,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // light shadow
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2), // subtle downward shadow
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      stopTimerMainCategory();
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
