import 'package:flutter/material.dart';
import 'package:rivia/utilities/change_notifiers.dart';

enum StartEnd {
  start,
  end,
}

class TimePicker extends StatefulWidget {
  final MeetingDateAndTime meetingDateAndTime;
  final StartEnd startEnd;

  const TimePicker({
    Key? key,
    required this.meetingDateAndTime,
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
        widget.meetingDateAndTime.setStartTime(newTime);
      } else {
        widget.meetingDateAndTime.setEndTime(newTime);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Selected time: ${_time.format(context)}'),
        action: SnackBarAction(
          label: 'hide',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ));
    }
  }

  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => _selectTime(context),
          child: Text('SELECT TIME'),
        ),
        SizedBox(height: 8),
        Text(
          'Selected time: ${_time.format(context)}',
        ),
      ],
    );
  }
}
