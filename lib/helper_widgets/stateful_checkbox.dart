import 'package:flutter/material.dart';

class StatefulCheckbox extends StatefulWidget {
  const StatefulCheckbox({Key? key}) : super(key: key);

  @override
  State<StatefulCheckbox> createState() => _StatefulCheckboxState();
}

class _StatefulCheckboxState extends State<StatefulCheckbox> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return Checkbox(value: _value, onChanged: (_) {
      setState(() {
        _value = !_value;
      });
    });
  }
}