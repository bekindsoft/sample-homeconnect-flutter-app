import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homeconnect/homeconnect.dart';
import 'package:homeconnect_flutter/homeconnect_flutter.dart';
import 'package:sample_homeconnect_flutter/provider.dart';
import 'package:sample_homeconnect_flutter/screens/devices_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testProvider = ref.watch(apiProvider2);
    AsyncValue homeconnectApi = ref.watch(authProvider);
    bool autorized = ref.watch(authrizationStateProvider);
    final hcoAuth = HomeConnectOauth(context: context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Sample app',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              const Text(
                'Let\'s cook something!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: homeconnectApi.when(
                  data: (value) {
                    HomeConnectApi api = value;
                    api.authenticator = hcoAuth;
                    return ElevatedButton(
                      onPressed: () async {
                        try {
                          api.authenticate();
                          ref.read(authrizationStateProvider.notifier).state = true;
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: !ref.watch(authrizationStateProvider)
                          ? const Text(
                              'Login',
                              style: TextStyle(color: Colors.white),
                            )
                          : const Text(
                              'Logout',
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, s) => Text("Error: $e"),
                ),
              ),
              !autorized
                  ? const Text('Log in to check your devices')
                  : ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DevicesScreen()),
                        );
                      },
                      child: const Text('Check devices')),
            ],
          ),
        ),
      ),
    );
  }
}
