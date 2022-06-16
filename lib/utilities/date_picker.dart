import 'package:flutter/material.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/sized_button.dart';

class DatePicker extends StatefulWidget {
  const DatePicker({
    Key? key,
    required this.restorationId,
    required this.initialDate,
    required this.notifyParent,
  }) : super(key: key);

  final String? restorationId;
  final DateTime initialDate;
  final void Function(DateTime dateTime) notifyParent;

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> with RestorationMixin {
  @override
  String? get restorationId => widget.restorationId;

  late final RestorableDateTime _selectedDate =
      RestorableDateTime(widget.initialDate);
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(2022),
          lastDate: DateTime(2023),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
      });
      widget.notifyParent(newSelectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedButton(
      onPressed: (_) {
        _restorableDatePickerRouteFuture.present();
      },
      primaryColour: Colors.black,
      selectedColour: Colors.white,
      backgroundColour: Colors.blue.shade100,
      onPressedColour: Colors.blue,
      height: null,
      width: null,
      child: Text(
        '${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}',
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  DateTime addTime(TimeOfDay time) {
    return DateTime(year, month, day, time.hour, time.minute);
  }
}
