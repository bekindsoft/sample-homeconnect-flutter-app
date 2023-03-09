import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homeconnect/homeconnect.dart';
import 'package:homeconnect_flutter/homeconnect_flutter.dart';
import 'package:sample_homeconnect_flutter/components/gradient_background.dart';
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
      title: 'Home Connect Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue[900],
      ),
      initialRoute: '/',
      defaultTransition: Transition.native,
      getPages: [
        GetPage(name: '/', page: () => MyHomePage(title: 'Home Connect Demo', api: api)),
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
  bool authenticated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Builder(builder: (context) {
        final hcoauth = HomeConnectOauth(context: context);
        final homeconnectApi = widget.api;
        homeconnectApi.authenticator = hcoauth;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      await homeconnectApi.authenticate();
                      Get.snackbar("Success", "Authenticated", backgroundColor: Colors.green[100]);
                      setState(() {
                        authenticated = true;
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: GradientBackground(text: authenticated ? "Authenticated" : "Login"),
                ),
                const SizedBox(height: 16.0),
                authenticated
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DeviceListWidget(
                                        api: homeconnectApi,
                                      )));
                        },
                        child: const GradientBackground(text: "Show devices"),
                      )
                    : Container(),
              ],
            ),
          ),
        );
      }),
    );
  }
}
