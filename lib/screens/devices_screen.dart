import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_homeconnect_flutter/provider.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceProvider);
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
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome!',
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              device != null
                  ? Text(
                      "You have selected: ${device.deviceName}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                    )
                  : const Text(
                      'You have not selected a device',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
              const Text(
                'Pick your home appliance',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              FutureBuilder(
                future: ref.read(devicesProvider.future),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView(
                      shrinkWrap: true,
                      children: snapshot.data!
                          .map(
                            (device) => Center(
                              child: Card(
                                elevation: 10,
                                color: Colors.orange.shade300,
                                child: ListTile(
                                  onTap: () {
                                    ref.read(deviceProvider.notifier).setDevice(device);
                                  },
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    device.deviceName,
                                    style:
                                        const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  } else {
                    return const CircularProgressIndicator(
                      color: Colors.blueGrey,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
