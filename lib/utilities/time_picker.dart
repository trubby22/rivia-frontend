import 'package:flutter/material.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/sized_button.dart';

class TimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final void Function(TimeOfDay timeOfDay) notifyParent;
  final bool enabled;

  const TimePicker({
    Key? key,
    required this.initialTime,
    required this.notifyParent,
    this.enabled = true,
  }) : super(key: key);

  @override
  _TimePickerState createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  late TimeOfDay _time = widget.initialTime;

  void _selectTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _time,
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (newTime != null) {
      setState(() {
        _time = newTime;
      });
      widget.notifyParent(newTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedButton(
      primaryColour: Colors.black,
      selectedColour: Colors.white,
      backgroundColour: Colors.blue.shade100,
      onPressedColour: Colors.blue,
      height: null,
      width: null,
      onPressed: widget.enabled ? (_) => _selectTime(context) : null,
      child: Text(_time.format(context)),
    );
  }
}
