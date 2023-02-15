import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_home_connect_sdk/flutter_home_connect_sdk.dart';

import './components/login.dart' show showLogin;
import './auth/oauth.dart' show HomeConnectOauth;

const oauthUri = 'https://simulator.home-connect.com/security/oauth/authorize';
const oauthTokenUri = 'https://simulator.home-connect.com/security/oauth/token';
const clientId = '03943A3AF9137E54871439D690ADC05907F480DEC22E9385C0852C1BD1A6533C';
const clientSecret = '';
const redirectUrl = "https://api-docs.home-connect.com/quickstart/";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      defaultTransition: Transition.native,
      getPages: [
        GetPage(name: '/', page: () => const MyHomePage(title: 'Flutter Demo Home Page')),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class LoginView extends StatelessWidget {

  late final WebViewController controller;


  LoginView({super.key}) {

  }

  @override
  Widget build(BuildContext context) {
    final authorizationEndpoint = Uri.parse(oauthUri);
    //final redirectUrl = Uri.parse('http://localhost:3300');
    final redirectUrl = Uri.parse('https://api-docs.home-connect.com/quickstart/');
    final grant = oauth2.AuthorizationCodeGrant(
      clientId, Uri.parse(oauthUri), Uri.parse(oauthTokenUri));
    var authorizationUrl = grant.getAuthorizationUrl(redirectUrl);
    //WebViewController? _controller;
    controller = WebViewController()
      ..loadRequest(
        authorizationUrl
      );

    controller.setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (navReq) {
          print("requrl ${navReq.url.toString()}");
        if (navReq.url.startsWith(redirectUrl.toString())) {
          final responseUrl = Uri.parse(navReq.url);
          print(responseUrl);
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
        }
    ),);
    return WebViewWidget(
      //initialUrl: authorizationUrl,
      controller: controller,
      //javascriptMode: JavascriptMode.unrestricted,
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  HttpServer? _redirectServer;
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

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
    final clientId = '03943A3AF9137E54871439D690ADC05907F480DEC22E9385C0852C1BD1A6533C';
    //final clientId = '59E61AFB0770F46359C65D658AE7B0D12336DACF7E609D70FD90392F19B19F7C';

    final grant = oauth2.AuthorizationCodeGrant(
      clientId, Uri.parse(oauthUri), Uri.parse(oauthTokenUri));
    final redirectUrl = Uri.parse('http://localhost:3300');
    var authorizationUrl = grant.getAuthorizationUrl(redirectUrl);
 
    if (await canLaunch(authorizationUrl.toString())) {
      await launch(authorizationUrl.toString());
    }
    final Map<String, String> responseQueryParameter = await _listen();
    print("done: $responseQueryParameter");
    setState(() {
      _counter++;
    });
    closeWebView();

    void handleAuthResponse(Uri responseUrl) async {
      final res = await grant.handleAuthorizationResponse(responseUrl.queryParameters);
      print(res);
      print(res.credentials.accessToken);
    }

    Uri responseUrl = Uri.parse('');
    getLinksStream().listen((String? uri) {
      print("got url $uri");
      if (uri != null && uri.toString().startsWith(redirectUrl.toString())) {
        responseUrl = Uri.parse(uri);
        print(responseUrl);
        closeWebView();
        handleAuthResponse(responseUrl);
      }
    });
    //},);
  }

  @override
  Widget build(BuildContext context) {
    if (_counter == 0) {
      //return LoginView();
    }
    final hcoauth = HomeConnectOauth(context: context);
    final homeconnectApi = HomeConnectApi(
      "",
      accessToken: "",
      credentials: HomeConnectClientCredentials(
        clientId: clientId,
        redirectUri: redirectUrl,
      ),
      authenticator: hcoauth,
      // TODO support caching tokens
      //storage: FlutterSecureStorage(),
    );
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            TextButton(
              onPressed: () async {
                final creds = HomeConnectClientCredentials(
                  clientId: clientId,
                  clientSecret: clientSecret,
                  redirectUri: redirectUrl,
                );
                await homeconnectApi.authenticate();
              },
              child: Text("Login with HomeConnect"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
