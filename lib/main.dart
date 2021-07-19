import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

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
    FlutterStatusbarcolor.setStatusBarColor(emebuColor, animate: true);
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    return MaterialApp(
        home: InAppWebViewPage()
    );
  }
}

class InAppWebViewPage extends StatefulWidget {
  @override
  _InAppWebViewPageState createState() => new _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  InAppWebViewController webView;
  int _page = 2;
  bool _loadError = false;
  bool progressBar = true;
  StreamSubscription<ConnectivityResult> subscription;

  @override
  initState() {
    super.initState();
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none && webView != null) {
        print("reload");
        _loadError = false;
        webView.reload();
      }
    });
  }

  @override
  dispose() {
    super.dispose();
    subscription.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          child: Container(),
          preferredSize: Size.fromHeight(0.0),
        ),
        body: IndexedStack(
            index: _page,
            children: <Widget>[
              ModalProgressHUD(
                inAsyncCall: progressBar,
                child: InAppWebView(
                  initialUrl: "https://www.sdro.space/",
                  initialHeaders: {},
                  initialOptions: InAppWebViewWidgetOptions(
                    inAppWebViewOptions: InAppWebViewOptions(
                        mediaPlaybackRequiresUserGesture: false,
                        debuggingEnabled: true,
                        userAgent: 'Wolvpack/0.0.1 (iPhone; CPU iPhone OS 9_3_1 like Mac OS X)'
                    ),
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {
                    webView = controller;
                  },
                  onLoadStart: (InAppWebViewController controller, String url) {
                  setState(() {
                    progressBar=true;
                  });
                  },
                  onLoadStop: (InAppWebViewController controller, String url) {
                    print(url);
                    setState(() {
                      if (!_loadError) {
                        progressBar=false;
                        _page = 0;
                      } else {
                        progressBar=false;
                        _page = 1;
                      }
                    });
                  },
                  onPermissionRequest: (InAppWebViewController controller, String origin, List<String> resources) async {
                    print(origin);
                    print(resources);
                    return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
                  },
                  onLoadError: (InAppWebViewController controller, String url, int code, String message) async {
                    print("error $url: $code, $message");
                    _loadError = true;
                  },
                  onLoadHttpError: (InAppWebViewController controller, String url, int statusCode, String description) async {
                    print("HTTP error $url: $statusCode, $description");
                  },
                ),
              ),
              Container(
                color: emebuColor,
                child: Center(
                  child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        Container(
                          color: emebuColor,
                          child: Center(
                              child: new Image.asset(
                                  'assets/failed.png',
                                  width: 250
                              )
                          ),
                        ),
                        TextButton(
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.focused))
                                    return Colors.red;
                                  return null; // Defer to the widget's default.
                                }
                            ),
                          ),
                          onPressed: () {


                            setState(() {
                              webView.reload();
                              _page = 0;
                              webView.reload();
                            });

                          },
                          child: Text('Refresh'),
                        )
                      ]
                  ),
                ),
              ),
              Container(
                color: emebuColor,
                child: Center(
                    child: new Image.asset(
                        'assets/image.png',
                        width: 150
                    )
                ),
              )
            ])
    );
  }
}

const MaterialColor emebuColor = const MaterialColor(
    0xFF011633, const <int, Color>{100: const Color(0xFF011633)});
