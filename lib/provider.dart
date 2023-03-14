import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homeconnect/homeconnect.dart';

final devicesProvider = FutureProvider<List<HomeDevice>>((ref) async {
  final api = ref.watch(apiProvider);
  final devices = await api.getApi().getDevices();
  return devices;
});

final authrizationStateProvider = StateProvider<bool>((ref) {
  return false;
});

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
