import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homeconnect/homeconnect.dart';

/// devicesProvider is an async provider that will fetch the list of devices.
///
/// HomeConnectApi needs to run authorize() before it can fetch the devices.
///
/// ## Example
/// ```dart
///    FutureBuilder(
///      future: ref.read(devicesProvider.future),
///      builder: (context, snapshot) {
///       if (snapshot.hasData) {
///        return ListView( ...
///
/// ```
/// **feel free to use your own implementation, this is just an example.**
final devicesProvider = FutureProvider<List<HomeDevice>>((ref) async {
  final api = ref.watch(apiProvider);
  final devices = await api.getApi().getDevices();
  return devices;
});

/// Helper provider to check if the user is authorized.
///
/// Can be used to show a login button or not.
/// Should be set after a succesful call to `authenticate()`.
/// ## Example setting the provider state
/// ```dart
///  return ElevatedButton(
/// onPressed: () async {
///   try {
///     api.authenticate();
///     ref.read(authrizationStateProvider.notifier).state = true;
///     autorized = true;
///   } catch (e) {
///     print(e);
///   }
/// },
/// ```
///
/// ## Example using the provider
/// ```dart
///   if (ref.watch(authrizationStateProvider)) {
///    return const Text('You are logged in');
///  } else {
///   return const Text('You are not logged in');
/// ```
final authrizationStateProvider = StateProvider<bool>((ref) {
  return false;
});

/// authProvider is an async provider that exposes a HomeConnectApi instance ready to use `authenticate()`
///
/// ## Example
/// ```dart
/// // reading the provider
/// AsyncValue homeconnectApi = ref.watch(authProvider);
///
/// // using the provider
/// homeconnectApi.when(
///  data: (value) {
///   // do something with the value
/// }
/// loading: () => const CircularProgressIndicator(),
/// error: (e, s) => Text("Error: $e"),
/// )
/// ```
final authProvider = FutureProvider<HomeConnectApi>((ref) async {
  await dotenv.load(fileName: ".env");
  final env = dotenv.env;
  final homeConnectApi = HomeConnectApi(
    Uri.parse(env["HOMECONNECT_URL"]!),
    credentials: HomeConnectClientCredentials(
      clientId: env['HOMECONNECT_CLIENT_ID']!,
      redirectUri: env['HOMECONNECT_REDIRECT_URL']!,
    ),
  );

  ref.read(apiProvider.notifier).state.setApi(homeConnectApi);
  return homeConnectApi;
});

///  apiProvider is a state provider that exposes a HomeConnectApi instance ready to fetch devices.
/// It is used by the [devicesProvider] to fetch the devices.
final apiProvider = StateProvider<ApiNotifier>((ref) => ApiNotifier());

class ApiNotifier extends StateNotifier<HomeConnectApi> {
  ApiNotifier()
      : super(
          HomeConnectApi(
            Uri.parse(""),
            credentials: HomeConnectClientCredentials(
              clientId: "",
              redirectUri: "",
            ),
          ),
        );

  void setApi(HomeConnectApi authapi) {
    state = authapi;
  }

  HomeConnectApi getApi() {
    return state;
  }
}

/// deviceProvider is a state provider that exposes a HomeDevice instance.
final deviceProvider = StateNotifierProvider<DeviceNotifier, HomeDevice?>((ref) => DeviceNotifier());

class DeviceNotifier extends StateNotifier<HomeDevice?> {
  DeviceNotifier() : super(null);

  void setDevice(HomeDevice device) {
    state = device;
  }

  HomeDevice getDevice() {
    return state!;
  }
}
