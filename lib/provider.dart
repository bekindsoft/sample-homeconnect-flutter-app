import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homeconnect/homeconnect.dart';

class Dish {
  final String name;
  final String image;
  final int duration;
  final int temperature;
  final String programKey;
  final String description;

  Dish(
      {required this.name,
      required this.image,
      required this.duration,
      required this.temperature,
      required this.programKey,
      required this.description});
}

final dishesProvider = Provider((ref) {
  return [
    Dish(
      name: 'Pizza',
      image: 'images/pizza.jpeg',
      duration: 30,
      temperature: 250,
      programKey: 'Cooking.Oven.Program.HeatingMode.PreHeating',
      description:
          'Pizza is a savory dish of Italian origin, consisting of a usually round, flattened base of leavened wheat-based dough topped with tomatoes, cheese, and often various other ingredients (such as anchovies, mushrooms, onions, olives, pineapple, meat, etc.) baked at a high temperature, traditionally in a wood-fired oven. A small pizza is sometimes called a pizzetta. A person who makes pizza is known as a pizzaiolo. The term pizza was first recorded in the 10th century in a Latin manuscript from the Southern Italian town of Gaeta in Lazio, on the border with Campania.',
    ),
    Dish(
      name: 'Bread',
      image: 'images/bread.jpeg',
      duration: 60,
      temperature: 100,
      programKey: 'Cooking.Oven.Program.HeatingMode.HotAir',
      description:
          'Bread is a staple food prepared from a dough of flour and water, usually by baking. Throughout recorded history it has been popular around the world and is one of the oldest artificial foods, having been of importance since the dawn of agriculture. Bread may be leavened by processes such as reliance on naturally occurring sourdough microbes, chemicals, industrially produced yeast, or high-pressure aeration. Some bread is cooked before it can leaven, including for traditional or religious reasons. Non-cereal ingredients such as fruits, nuts, and fats may be included. Commercial bread commonly contains additives to improve flavor, texture, color, shelf life, or ease of manufacturing. Bread is served in various forms with any meal. It is eaten as a snack by itself, dipped in various savory dishes, or used for sandwiches and to make toast. It is one of the most common and convenient prepared foods in the world.',
    ),
    Dish(
        name: 'Cake',
        image: 'images/cake.jpeg',
        duration: 60,
        temperature: 150,
        programKey: 'Cooking.Oven.Program.HeatingMode.TopBottomHeating',
        description:
            'Cake is a form of sweet dessert that is typically baked. In its oldest forms, cakes were modifications of breads, but cakes now cover a wide range of preparations that can be simple or elaborate, and that share features with other desserts such as pastries, meringues, custards, and pies. The most commonly used cake ingredients include flour, sugar, eggs, butter or oil or margarine, a liquid, and leavening agents, such as baking soda or baking powder. Common additional ingredients and flavourings include dried, candied, or fresh fruit, nuts, cocoa, and extracts such as vanilla, with numerous substitutions for the primary ingredients. Cakes can also be filled with fruit preserves, nuts or dessert sauces (like pastry cream), iced with buttercream or other icings, and decorated with marzipan, piped borders, or candied fruit.'),
    Dish(
      name: 'Roast',
      image: 'images/roast.jpeg',
      duration: 60,
      temperature: 250,
      programKey: 'Cooking.Oven.Program.HeatingMode.PizzaSetting',
      description:
          'Roast is a method of cooking meat, fish, or vegetables by dry heat applied to the outside of the food. The heat is usually indirect, from hot air circulating in the oven, or from a heated surface such as a grill or griddle. The food is cooked by conduction, and not by radiation as in microwave cooking. The cooking time is longer than for other cooking methods, but the meat is more tender and succulent. The word roast comes from the Anglo-Norman word rost, meaning "red", which is derived from the Old French word roste, meaning "red".',
    ),
  ];
});

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
  ref.read(apiProvider2.notifier).setApi(homeConnectApi);
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

final apiProvider2 = StateNotifierProvider<ApiNotifier2, ApiState>((ref) => ApiNotifier2());

class ApiNotifier2 extends StateNotifier<ApiState> {
  ApiNotifier2() : super(ApiState(null, false, null));

  void setApi(HomeConnectApi authapi) {
    state = state.copyWith(api: authapi);
  }

  void setAuthorized(bool authorized) {
    state = state.copyWith(authorized: authorized);
  }

  HomeConnectApi getApi() {
    return state.api!;
  }

  bool getAuthorized() {
    return state.authorized;
  }

  void setDevice(HomeDevice device) {
    state = state.copyWith(device: device);
  }

  HomeDevice getDevice() {
    return state.device!;
  }

  void setDevices(List<HomeDevice> devices) {
    state = state.copyWith(devices: devices);
  }

  List<HomeDevice> getDevices() {
    return state.devices;
  }
}

class ApiState {
  final HomeConnectApi? api;
  final bool authorized;
  final List<HomeDevice> devices = [];
  final HomeDevice? device;

  ApiState(this.api, this.authorized, this.device);

  ApiState copyWith({
    HomeConnectApi? api,
    bool? authorized,
    List<HomeDevice>? devices,
    HomeDevice? device,
  }) {
    return ApiState(api ?? this.api, authorized ?? this.authorized, device ?? this.device);
  }
}
