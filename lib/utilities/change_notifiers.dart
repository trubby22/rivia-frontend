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
  authToken.userId = instance.getString(Fields.participantId);
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
  if (authToken.userId == null) {
    instance.remove(Fields.participantId);
  } else {
    instance.setString(Fields.participantId, authToken.userId!);
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

class AuthToken {
  Lang language = Lang.en;
  String? token;
  String? refreshToken;
  String? userId;

  Future<void> reset() async {
    token = null;
    refreshToken = null;
    userId = null;
    await setSharedPref();
  }
}

extension LangTextChoice on LangText {
  String get local =>
      LangTextContent.langTexts[this]![authToken.language.index];
}
