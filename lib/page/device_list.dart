import 'package:flutter/material.dart';
import 'package:homeconnect/homeconnect.dart';
import 'package:sample_homeconnect_flutter/page/device_page.dart';

class DeviceListWidget extends StatelessWidget {
  final HomeConnectApi api;
  const DeviceListWidget({Key? key, required this.api}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var list = api.getDevices();
    var list = api.getDevices();
    // print(list);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device List'),
      ),
      body: FutureBuilder(
        future: list,
        builder: (BuildContext context, AsyncSnapshot<List<HomeDevice>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    title: Text(snapshot.data![index].info.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return DevicePageWidget(
                            api: api,
                            device: snapshot.data![index],
                          );
                        }));
                      },
                    ));
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
