import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homeconnect/homeconnect.dart';
import 'package:sample_homeconnect_flutter/provider.dart';

class DishesScreen extends ConsumerWidget {
  const DishesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeConnectApi = ref.watch(apiProvider2);
    List<Dish> dishes = ref.watch(dishesProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Dishes',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(children: [
        for (var dish in dishes)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 10,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Image.asset(
                    dish.image,
                    fit: BoxFit.cover,
                  ),
                  ListTile(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(dish.name,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                    subtitle: Text(
                      dish.description,
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.timer),
                            const SizedBox(height: 8),
                            Text(dish.duration.toString()),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.thermostat),
                            const SizedBox(height: 8),
                            Text(dish.temperature.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await homeConnectApi.device!.selectProgram(programKey: dish.programKey);
                          final option1 = ProgramOptions.toCommandPayload(
                              key: 'Cooking.Oven.Option.SetpointTemperature', value: dish.temperature);
                          final option2 = ProgramOptions.toCommandPayload(
                              key: 'BSH.Common.Option.Duration', value: dish.duration * 60);
                          homeConnectApi.device!.startProgram(programKey: dish.programKey, options: [option1, option2]);
                        },
                        child: const Text("Let's cook!"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ]),
    );
  }
}
