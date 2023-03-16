import 'package:flutter/material.dart';
import 'package:homeconnect/homeconnect.dart';

class ProgramPageWidget extends StatefulWidget {
  const ProgramPageWidget({required this.api, required this.device, required this.program, super.key});
  final HomeConnectApi api;
  final HomeDevice device;
  final DeviceProgram program;

  @override
  State<ProgramPageWidget> createState() => _ProgramPageWidgetState();
}

class _ProgramPageWidgetState extends State<ProgramPageWidget> {
  Map<String, ProgramOptions> options = {};
  @override
  Widget build(BuildContext context) {
    // widget.api.eventEmitter.on("update", null, (event, context) => {print("Event occurred!")});

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.program.key.split('.').last),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(widget.program.key.split('.').last),
            subtitle: Text(widget.program.key),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.power_settings_new),
                  onPressed: () async {
                    await widget.device.startProgram(options: options.values.toList());
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  for (var option in widget.device.selectedProgram.options)
                    OptionsWidget(
                      option: option,
                      device: widget.device,
                      onUpdate: (ProgramOptions value) {
                        setState(() {
                          options[option.key] = value;
                        });
                      },
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OptionsWidget extends StatefulWidget {
  const OptionsWidget({super.key, required this.option, required this.device, required this.onUpdate});
  final ProgramOptions option;
  final HomeDevice device;
  final Function onUpdate;

  @override
  State<OptionsWidget> createState() => _OptionsWidgetState();
}

class _OptionsWidgetState extends State<OptionsWidget> {
  double? currentSliderValue;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.option.key),
        Slider(
          value: currentSliderValue ??= 100,
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
    );
  }
}
