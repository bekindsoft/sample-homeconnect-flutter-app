import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homeconnect/homeconnect.dart';

class ProgramPageWidget extends StatefulWidget {
  final HomeConnectApi api;
  final HomeDevice device;
  final DeviceProgram program;
  const ProgramPageWidget({super.key, required this.api, required this.device, required this.program});

  @override
  State<ProgramPageWidget> createState() => _ProgramPageWidgetState();
}

class _ProgramPageWidgetState extends State<ProgramPageWidget> {
  Map<String, ProgramOptions> options = {};
  bool ready = true;

  @override
  void initState() {
    statusChange(ev, cnt) {
      String res = DeviceEvent.toEventList(ev).first.value;
      if (res == "BSH.Common.EnumType.OperationState.Ready") {
        setState(
          () {
            ready = true;
          },
        );
      } else if (res == "BSH.Common.EnumType.OperationState.Inactive") {
        setState(
          () {
            ready = false;
          },
        );
      }
      // DeviceEvent.toEventList(ev).forEach((element) {
      //   print(element.key);
      //   print(element.value);
      // });
      Get.snackbar("Status Change", DeviceEvent.toEventList(ev).first.value,
          backgroundColor: Colors.green[100], snackPosition: SnackPosition.BOTTOM, barBlur: 10);
    }

    super.initState();
    widget.device.startListening();
    widget.device.onStatus(callback: (ev, cnt) => statusChange(ev, cnt));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.program.key.split('.').last),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            child: ListTile(
              title: Text(
                widget.program.key.split('.').last,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.blueAccent),
              ),
              subtitle: Text(
                widget.program.key,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.power_settings_new,
                      color: ready ? Colors.greenAccent : Colors.grey,
                    ),
                    onPressed: () async {
                      widget.device.startProgram(options: options.values.toList());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.offline_bolt),
                    onPressed: () async {
                      widget.device.stopProgram();
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                for (var option in widget.device.selectedProgram.options)
                  OptionsWidget(
                      option: option,
                      device: widget.device,
                      onUpdate: (value) {
                        setState(() {
                          options[option.key] = value;
                        });
                      })
              ],
            ),
          )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.device.stopListening();
    widget.device.removeListener(listener: widget.device.listeners.first);
    super.dispose();
  }
}

class OptionsWidget extends StatefulWidget {
  final ProgramOptions option;
  final HomeDevice device;
  final Function onUpdate;
  const OptionsWidget({Key? key, required this.option, required this.device, required this.onUpdate}) : super(key: key);

  @override
  State<OptionsWidget> createState() => _OptionsWidgetState();
}

class _OptionsWidgetState extends State<OptionsWidget> {
  double? currentSliderValue;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Text(widget.option.key.split('.').last,
                style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 20)),
            Slider(
              thumbColor: Colors.pink,
              activeColor: Colors.pink.shade400,
              inactiveColor: Colors.pink.shade100,
              value: currentSliderValue ??= widget.option.value.toDouble(),
              min: widget.option.constraints!.min.toDouble(),
              max: widget.option.constraints!.max.toDouble(),
              divisions: (widget.option.constraints!.max.toInt() - widget.option.constraints!.min.toInt()) ~/
                  widget.option.constraints!.stepsize.toInt(),
              label: currentSliderValue.toString(),
              onChanged: (double value) {
                setState(() {
                  currentSliderValue = value;
                  widget.onUpdate(ProgramOptions.toCommandPayload(key: widget.option.key, value: currentSliderValue));
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
