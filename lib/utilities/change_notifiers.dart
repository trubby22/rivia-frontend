import 'package:flutter/material.dart';

class MeetingDateAndTime extends ChangeNotifier {
  DateTime? date;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  void setDate(DateTime date) {
    this.date = date;
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    startTime = time;
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    endTime = time;
    notifyListeners();
  }
}
