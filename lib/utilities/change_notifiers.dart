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

class AuthToken extends ChangeNotifier {
  String? _token;
  String? _refreshToken;

  String? get token => _token;
  String? get refreshToken => _refreshToken;

  set token(String? value) {
    _token = value;
    notifyListeners();
  }

  set refreshToken(String? value) {
    _refreshToken = value;
    notifyListeners();
  }

  void reset() {
    _token = null;
    _refreshToken = null;
    notifyListeners();
  }
}
