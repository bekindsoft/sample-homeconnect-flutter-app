import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

const oauthUri = 'https://simulator.home-connect.com/security/oauth/authorize';
const oauthTokenUri = 'https://simulator.home-connect.com/security/oauth/token';

class LoginView extends StatelessWidget {
  late final WebViewController controller;
  final String clientId;
  final String redirectUrl;
  final String authorizationUrl;
  final void Function(Map<String, dynamic>) onLogin;

  // ignore: prefer_const_constructors_in_immutables
  LoginView({
    super.key,
    required this.clientId,
    required this.authorizationUrl,
    required this.redirectUrl,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    controller = WebViewController()..loadRequest(Uri.parse(authorizationUrl));

    controller.setNavigationDelegate(
      NavigationDelegate(onNavigationRequest: (navReq) {
        // if redirect url is called, we have to extract the code from the url
        if (navReq.url.startsWith(redirectUrl.toString())) {
          final responseUrl = Uri.parse(navReq.url);
          onLogin({"token": responseUrl.queryParameters["code"]});
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      }),
    );
    return WebViewWidget(
      //initialUrl: authorizationUrl,
      controller: controller,
      //javascriptMode: JavascriptMode.unrestricted,
    );
  }
}

Future<Map<String, dynamic>?> showLogin({
  required BuildContext context,
  required String clientId,
  required String redirectUrl,
  required String authorizationUrl,
}) async {

  return showGeneralDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 10,
          height: MediaQuery.of(context).size.height - 10,
          child: LoginView(
            clientId: clientId,
            authorizationUrl: authorizationUrl,
            redirectUrl: redirectUrl,
            onLogin: (token) {
              Navigator.of(context).pop(token);
            },
          ),
        ),
      );
    },
  );
}
