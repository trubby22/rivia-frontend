import 'package:flutter/material.dart';

class TimePicker extends StatefulWidget {
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Selected time: ${_time.format(context)}'),
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
