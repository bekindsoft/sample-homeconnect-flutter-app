import 'package:flutter/material.dart';
import 'package:homeconnect/homeconnect.dart';
import 'package:sample_homeconnect_flutter/page/program_page.dart';

class DevicePageWidget extends StatelessWidget {
  final HomeConnectApi api;
  final HomeDevice device;
  const DevicePageWidget({Key? key, required this.api, required this.device})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.info.name),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ListTile(
            title: Text(device.info.name),
            subtitle: Text(device.info.haId),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.power_settings_new),
                  onPressed: () async {
                    device.turnOn();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.offline_bolt),
                  onPressed: () async {
                    device.turnOff();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: api.getDevice(device),
              builder:
                  (BuildContext context, AsyncSnapshot<HomeDevice> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.programs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          title: Text(
                            snapshot.data!.programs[index].key.split('.').last,
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            onPressed: () async {
                              await device.selectProgram(
                                programKey: snapshot.data!.programs[index].key,
                              );
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProgramPageWidget(
                                            api: api,
                                            device: device,
                                            program:
                                                snapshot.data!.programs[index],
                                          )));
                            },
                          ));
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
