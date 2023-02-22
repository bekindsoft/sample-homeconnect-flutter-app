import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_homeconnect_flutter/page/device_list.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_home_connect_sdk/flutter_home_connect_sdk.dart';

import './auth/oauth.dart' show HomeConnectOauth;

const oauthUri = 'https://simulator.home-connect.com/security/oauth/authorize';
const oauthTokenUri = 'https://simulator.home-connect.com/security/oauth/token';
// const tClientId =
//     '03943A3AF9137E54871439D690ADC05907F480DEC22E9385C0852C1BD1A6533C';
const tClientId =
    "5741E5A0CBB9CCE4CDE5AA6BFDBDB5E64A34325A329E091F6869754168605EE4";
const clientSecret = '';
const redirectUrl = "https://api-docs.home-connect.com/quickstart/";

void main() {
  final api =
      HomeConnectApi("https://simulator.home-connect.com/api/homeappliances",
          // accessToken: "",
          credentials: HomeConnectClientCredentials(
            clientId: tClientId,
            redirectUri: redirectUrl,
          ),
          authenticator: null
          // TODO support caching tokens
          //storage: FlutterSecureStorage(),
          );
  // accessToken: "",
  runApp(MyApp(api: api));
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  HomeConnectApi api;
  MyApp({super.key, required this.api});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      defaultTransition: Transition.native,
      getPages: [
        GetPage(
            name: '/',
            page: () => MyHomePage(title: 'Flutter Demo Home Page', api: api)),
      ],
    );
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title, required this.api});

  final String title;
  HomeConnectApi api;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class LoginView extends StatelessWidget {
  late final WebViewController controller;

  // ignore: prefer_const_constructors_in_immutables
  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final authorizationEndpoint = Uri.parse(oauthUri);
    //final redirectUrl = Uri.parse('http://localhost:3300');
    final redirectUrl =
        Uri.parse('https://api-docs.home-connect.com/quickstart/');
    final grant = oauth2.AuthorizationCodeGrant(
        tClientId, Uri.parse(oauthUri), Uri.parse(oauthTokenUri));
    var authorizationUrl = grant.getAuthorizationUrl(redirectUrl);
    //WebViewController? _controller;
    controller = WebViewController()..loadRequest(authorizationUrl);

    controller.setNavigationDelegate(
      NavigationDelegate(onNavigationRequest: (navReq) {
        if (navReq.url.startsWith(redirectUrl.toString())) {
          final responseUrl = Uri.parse(navReq.url);
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

class _MyHomePageState extends State<MyHomePage> {
  HttpServer? _redirectServer;

  Future<Map<String, String>> _listen() async {
    final HttpRequest request = await _redirectServer!.first;
    final Map<String, String> params = request.uri.queryParameters;
    request.response.statusCode = 200;
    request.response.headers.set('Content-Type', 'text/plain');
    request.response.writeln('Authenticated! You can close the window.');
    await request.response.close();
    await _redirectServer!.close();
    _redirectServer = null;
    return params;
  }

  void login() async {
    await _redirectServer?.close();
    // Bind to an ephemeral port on localhost
    //_redirectServer = await HttpServer.bind('localhost', 3300);;
    final authorizationEndpoint = Uri.parse('oauthUri');

    final grant = oauth2.AuthorizationCodeGrant(
        tClientId, Uri.parse(oauthUri), Uri.parse(oauthTokenUri));
    final redirectUrl = Uri.parse('http://localhost:3300');
    var authorizationUrl = grant.getAuthorizationUrl(redirectUrl);

    if (await canLaunch(authorizationUrl.toString())) {
      await launch(authorizationUrl.toString());
    }
    final Map<String, String> responseQueryParameter = await _listen();
    setState(() {});
    closeWebView();

    void handleAuthResponse(Uri responseUrl) async {
      final res =
          await grant.handleAuthorizationResponse(responseUrl.queryParameters);
    }

    Uri responseUrl = Uri.parse('');
    getLinksStream().listen((String? uri) {
      if (uri != null && uri.toString().startsWith(redirectUrl.toString())) {
        responseUrl = Uri.parse(uri);
        closeWebView();
        handleAuthResponse(responseUrl);
      }
    });
    //},);
  }

  @override
  Widget build(BuildContext context) {
    final hcoauth = HomeConnectOauth(context: context);
    final homeconnectApi = widget.api;
    homeconnectApi.setAuthenticator(hcoauth);
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () async {
                final creds = HomeConnectClientCredentials(
                  clientId: tClientId,
                  clientSecret: clientSecret,
                  redirectUri: redirectUrl,
                );
                await homeconnectApi.authenticate();
              },
              child: const Text("Login with HomeConnecttt"),
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DeviceListWidget(
                                api: homeconnectApi,
                              )));
                },
                child: const Text("List devices")),
          ],
        ),
      ),
    );
  }
}
