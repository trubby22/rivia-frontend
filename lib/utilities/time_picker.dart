import 'package:flutter/material.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/sized_button.dart';

enum StartEnd {
  start,
  end,
}

class TimePicker extends StatefulWidget {
  final MeetingDateAndTime meetingTime;
  final StartEnd startEnd;

  const TimePicker({
    Key? key,
    required this.meetingTime,
    required this.startEnd,
  }) : super(key: key);

  @override
  _TimePickerState createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  TimeOfDay _time = TimeOfDay.now();

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
      if (widget.startEnd == StartEnd.start) {
        widget.meetingTime.setStartTime(newTime);
      } else {
        widget.meetingTime.setEndTime(newTime);
      }
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
      onPressed: (_) => _selectTime(context),
      child: Text(_time.format(context)),
    );
  }
}
