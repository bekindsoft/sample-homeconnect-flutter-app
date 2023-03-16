import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:homeconnect/homeconnect.dart';
import 'package:sample_homeconnect_flutter/provider.dart';

class DishWidget extends ConsumerStatefulWidget {
  const DishWidget({
    required this.dish,
    required this.homeConnectApi,
    super.key,
  });

  final Dish dish;
  final ApiState homeConnectApi;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DishWidgetState();
}

class _DishWidgetState extends ConsumerState<DishWidget> {
  String selectedProgram = 'Cooking.Oven.Program.HeatingMode.HotAir';
  @override
  Widget build(BuildContext context) {
    final homeConnectApi = ref.watch(apiProvider2);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Image.asset(
              widget.dish.image,
              fit: BoxFit.cover,
            ),
            ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  widget.dish.name,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              subtitle: Text(
                widget.dish.description,
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.timer),
                      const SizedBox(height: 8),
                      Text(widget.dish.duration.toString()),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.thermostat),
                      const SizedBox(height: 8),
                      Text(widget.dish.temperature.toString()),
                    ],
                  ),
                ],
              ),
            ),
            DropdownButton(
              value: selectedProgram,
              items: homeConnectApi.device!.programs
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.key.split('.').last),
                    ),
                  )
                  .toList(),
              onChanged: (value) async {
                final ovenDevice = homeConnectApi.device! as DeviceOven;
                try {
                  await ovenDevice.selectProgram(programKey: value!);
                  setState(() {
                    selectedProgram = value;
                  });
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    e.toString(),
                    snackPosition: SnackPosition.TOP,
                  );
                }

                await ovenDevice.setTemperature(temperature: widget.dish.temperature);
                await ovenDevice.setDuration(duration: widget.dish.duration * 60);
              },
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () async {
                    try {
                      await homeConnectApi.device!.startProgram();
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        e.toString(),
                        snackPosition: SnackPosition.TOP,
                      );
                    }
                  },
                  child: const Text("Let's cook!"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
