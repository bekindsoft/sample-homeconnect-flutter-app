import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

const oauthUri = 'https://simulator.home-connect.com/security/oauth/authorize';
const oauthTokenUri = 'https://simulator.home-connect.com/security/oauth/token';

class LoginView extends StatelessWidget {
  late final WebViewController controller;
  final String clientId;
  final String redirectUrl;
  final void Function(Map<String, dynamic>) onLogin;

  // ignore: prefer_const_constructors_in_immutables
  LoginView({
    super.key,
    required this.clientId,
    required this.redirectUrl,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final authorizationEndpoint = Uri.parse(oauthUri);
    // const clientId =
    //     '03943A3AF9137E54871439D690ADC05907F480DEC22E9385C0852C1BD1A6533C';
    //final redirectUrl = Uri.parse('http://localhost:3300');
    final redirectUrl =
        Uri.parse('https://api-docs.home-connect.com/quickstart/');
    final grant = oauth2.AuthorizationCodeGrant(
        clientId, Uri.parse(oauthUri), Uri.parse(oauthTokenUri));
    var authorizationUrl = grant.getAuthorizationUrl(redirectUrl);
    //WebViewController? _controller;
    controller = WebViewController()..loadRequest(authorizationUrl);

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
}) async {
  final authorizationEndpoint = Uri.parse(oauthUri);
  final grant = oauth2.AuthorizationCodeGrant(
      clientId, Uri.parse(oauthUri), Uri.parse(oauthTokenUri));
  final authorizationUrl = grant.getAuthorizationUrl(Uri.parse(redirectUrl));

  /*
  //return Future(() async {
  final completer = Completer<Map<String, dynamic>?>();
    if (await launcher.canLaunch(authorizationUrl.toString())) {
      await launcher.launchUrl(authorizationUrl);
    }
      linkStream.listen((String? uri) {
        //completer.complete({"token": event.queryParameters["code"]});
      if (uri != null && uri.toString().startsWith(redirectUrl.toString())) {
        final responseUrl = Uri.parse(uri);
        launcher.closeWebView();
        //handleAuthResponse(responseUrl);
      }
      });
    //return <String, dynamic>{};
    return completer.future;
  //});
  //
  */

  return showGeneralDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 10,
          height: MediaQuery.of(context).size.height - 80,
          child: LoginView(
            clientId: clientId,
            redirectUrl: redirectUrl,
            onLogin: (token) {
              Navigator.of(context).pop(token);
            },
          ),
        ),
      );
    },
  );
  /*
  */
}
