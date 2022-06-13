import 'package:flutter/material.dart';
import 'package:rivia/constants/fields.dart';
import 'package:rivia/constants/languages.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authToken = AuthToken();

Future<void> getSharedPref(Function()? callback) async {
  final instance = await SharedPreferences.getInstance();
  authToken.language =
      Lang.values[instance.getInt(Fields.lang) ?? authToken.language.index];
  authToken.token = instance.getString(Fields.token);
  authToken.refreshToken = instance.getString(Fields.refreshToken);
  callback?.call();
}

Future<void> setSharedPref() async {
  final instance = await SharedPreferences.getInstance();
  instance.setInt(Fields.lang, authToken.language.index);
  if (authToken.token == null) {
    instance.remove(Fields.token);
  } else {
    instance.setString(Fields.token, authToken.token!);
  }
  if (authToken.refreshToken == null) {
    instance.remove(Fields.refreshToken);
  } else {
    instance.setString(Fields.refreshToken, authToken.refreshToken!);
  }
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
  Lang language = Lang.en;
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

  Future<void> reset() async {
    _token = null;
    _refreshToken = null;
    notifyListeners();
    await setSharedPref();
  }
}

extension LangTextChoice on LangText {
  String get local => langTexts[this]![authToken.language.index];
}
