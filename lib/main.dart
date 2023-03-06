import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homeconnect/homeconnect.dart';
import 'package:homeconnect_flutter/homeconnect_flutter.dart';
import 'package:sample_homeconnect_flutter/page/device_list.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  final env = dotenv.env;
  final api = HomeConnectApi(Uri.parse(env["HOMECONNECT_URL"]!),
      credentials: HomeConnectClientCredentials(
        clientId: env["HOMECONNECT_CLIENT_ID"]!,
        redirectUri: env["HOMECONNECT_REDIRECT_URL"]!, // redirectUrl,
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
        GetPage(name: '/', page: () => MyHomePage(title: 'Flutter Demo Home Page', api: api)),
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

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Builder(builder: (context) {
        final hcoauth = HomeConnectOauth(context: context);
        final homeconnectApi = widget.api;
        homeconnectApi.authenticator = hcoauth as HomeConnectAuth?;
        return Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                onPressed: () async {
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
        );
      }),
    );
  }
}
