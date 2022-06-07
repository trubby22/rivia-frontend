import 'package:flutter/material.dart';

class MeetingDateAndTime extends ChangeNotifier {
  DateTime date = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();

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

class User extends ChangeNotifier {
  String? _uuid;

  String? get uuid => _uuid;

  set uuid(String? uuid) {
    _uuid = uuid;
    notifyListeners();
  }
}
