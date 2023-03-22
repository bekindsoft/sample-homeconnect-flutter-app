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
    final homeconnectApi = ref.watch(authProvider);
    final hcoAuth = HomeConnectOauth(
      context: context,
      scopes: [OauthScope.identifyAppliance, OauthScope.oven],
    );
    final authenticated = ref.watch(authentiacationStateProvider);

    Future<void> login(HomeConnectApi api) async {
      api.authenticator = hcoAuth;
      try {
        await api.authenticate();
        final auth = await api.isAuthenticated();
        ref.read(apiProvider2.notifier).setAuthenticated(auth);
      } catch (e) {
        print(e);
      }
    }

    Future<void> logout() async {
      try {
        await testProvider.api!.logout();
        final auth = await testProvider.api!.isAuthenticated();
        ref.read(apiProvider2.notifier).setAuthenticated(auth);
      } catch (e) {
        print(e);
      }
    }

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
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              const Text(
                "Let's cook something!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: homeconnectApi.when(
                  data: (value) {
                    return ElevatedButton(
                      onPressed: () async {
                        if (!testProvider.authenticated) {
                          await login(value);
                        } else {
                          await logout();
                        }
                      },
                      child: !testProvider.authenticated
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
                  error: (e, s) => Text('Error: $e'),
                ),
              ),
              if (!authenticated)
                const Text('Log in to check your devices')
              else
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DevicesScreen()),
                    );
                  },
                  child: const Text(
                    'Check devices',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
