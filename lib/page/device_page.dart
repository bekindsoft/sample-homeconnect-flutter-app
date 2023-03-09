import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homeconnect/homeconnect.dart';
import 'package:sample_homeconnect_flutter/page/program_page.dart';

class DevicePageWidget extends StatefulWidget {
  final HomeConnectApi api;
  final HomeDevice device;
  const DevicePageWidget({Key? key, required this.api, required this.device}) : super(key: key);

  @override
  State<DevicePageWidget> createState() => _DevicePageWidgetState();
}

class _DevicePageWidgetState extends State<DevicePageWidget> {
  Function statusChange = (ev, cnt) {
    Get.snackbar("Status Change", DeviceEvent.toEventList(ev).first.value,
        backgroundColor: Colors.green[100], snackPosition: SnackPosition.BOTTOM, barBlur: 10);
  };

  @override
  void initState() {
    super.initState();
    widget.device.init();
    // widget.device.startListening();
    // widget.device.onStatus(callback: (ev, cnt) => statusChange(ev, cnt));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.info.name),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ListTile(
            tileColor: Theme.of(context).primaryColorLight,
            title: Text(widget.device.info.name),
            subtitle: Text(widget.device.info.haId),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.power_settings_new),
                  onPressed: () async {
                    widget.device.turnOn();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.offline_bolt),
                  onPressed: () async {
                    widget.device.turnOff();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: widget.device.init(),
              builder: (BuildContext context, AsyncSnapshot<HomeDevice> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.programs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: ListTile(
                            title: Text(
                              snapshot.data!.programs[index].key.split('.').last,
                              style: const TextStyle(fontSize: 12, letterSpacing: 1.5),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios),
                              onPressed: () async {
                                await widget.device.selectProgram(programKey: snapshot.data!.programs[index].key);
                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProgramPageWidget(
                                      api: widget.api,
                                      device: widget.device,
                                      program: snapshot.data!.programs[index],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
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
