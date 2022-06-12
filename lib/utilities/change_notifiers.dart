import 'package:flutter/material.dart';
import 'package:rivia/constants/fields.dart';
import 'package:rivia/constants/languages.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authToken = AuthToken();

Future<void> getSharedPref(Function()? callback) async {
  language = Lang.values[
      (await SharedPreferences.getInstance()).getInt(Fields.lang) ??
          language.index];
  callback?.call();
}

Future<void> setSharedPref(Lang value) async {
  language = value;
  final instance = await SharedPreferences.getInstance();
  instance.setInt(Fields.lang, value.index);
}

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
