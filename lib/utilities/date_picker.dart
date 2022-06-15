import 'package:flutter/material.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/sized_button.dart';

class DatePicker extends StatefulWidget {
  const DatePicker({
    Key? key,
    required this.restorationId,
    required this.meetingDate,
  }) : super(key: key);

  final String? restorationId;
  final MeetingDate meetingDate;

  @override
  State<DatePicker> createState() => _DatePickerState();
}

/// RestorationProperty objects can be used because of RestorationMixin.
class _DatePickerState extends State<DatePicker> with RestorationMixin {
  // In this example, the restoration ID for the mixin is passed in through
  // the [StatefulWidget]'s constructor.
  @override
  String? get restorationId => widget.restorationId;

  late final RestorableDateTime _selectedDate =
      RestorableDateTime(widget.meetingDate.date);
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
      widget.meetingDate.date = newSelectedDate;
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
