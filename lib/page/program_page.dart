import 'package:flutter/material.dart';
import 'package:flutter_home_connect_sdk/flutter_home_connect_sdk.dart';

class ProgramPageWidget extends StatefulWidget {
  final HomeConnectApi api;
  final HomeDevice device;
  final DeviceProgram program;
  const ProgramPageWidget(
      {super.key,
      required this.api,
      required this.device,
      required this.program});

  @override
  State<ProgramPageWidget> createState() => _ProgramPageWidgetState();
}

class _ProgramPageWidgetState extends State<ProgramPageWidget> {
  Map<String, DeviceOptions> options = {};
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
          ListTile(
            title: Text(widget.program.key.split('.').last),
            subtitle: Text(widget.program.key),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.power_settings_new),
                  onPressed: () async {
                    widget.device
                        .startProgram(options: options.values.toList());
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
}

class OptionsWidget extends StatefulWidget {
  final DeviceOptions option;
  final HomeDevice device;
  final Function onUpdate;
  const OptionsWidget(
      {Key? key,
      required this.option,
      required this.device,
      required this.onUpdate})
      : super(key: key);

  @override
  State<OptionsWidget> createState() => _OptionsWidgetState();
}

class _OptionsWidgetState extends State<OptionsWidget> {
  double? _currentSliderValue;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.option.key),
        Slider(
          value: _currentSliderValue ??= widget.option.value.toDouble(),
          min: widget.option.constraints!.min.toDouble(),
          max: widget.option.constraints!.max.toDouble(),
          divisions: (widget.option.constraints!.max.toInt() -
                  widget.option.constraints!.min.toInt()) ~/
              widget.option.constraints!.stepsize.toInt(),
          label: _currentSliderValue.toString(),
          onChanged: (double value) {
            setState(() {
              _currentSliderValue = value;
              widget.onUpdate(DeviceOptions.toCommandPayload(
                  key: widget.option.key, value: _currentSliderValue));
            });
          },
        ),
      ],
    );
  }
}
