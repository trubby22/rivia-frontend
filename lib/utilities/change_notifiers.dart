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
  authToken.tenantDomain = instance.getString(Fields.organiserId);
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
  if (authToken.tenantDomain == null) {
    instance.remove(Fields.organiserId);
  } else {
    instance.setString(Fields.organiserId, authToken.tenantDomain!);
  }
}

class AuthToken {
  Lang language = Lang.en;
  String? token;
  String? refreshToken;
  String? userId;
  String? tenantDomain;

  Future<void> reset() async {
    token = null;
    refreshToken = null;
    userId = null;
    tenantDomain = null;
    await setSharedPref();
  }
}

extension LangTextChoice on LangText {
  String get local =>
      LangTextContent.langTexts[this]![authToken.language.index];
}

abstract class MeetingDate {
  DateTime get date;

  set date(DateTime date);
}

class MeetingStartDate extends ChangeNotifier implements MeetingDate {
  DateTime _date;

  MeetingStartDate(date) : _date = date;

  @override
  DateTime get date => _date;

  @override
  set date(DateTime date) {
    _date = date;
    notifyListeners();
  }
}

class MeetingEndDate extends ChangeNotifier implements MeetingDate {
  DateTime _date;

  MeetingEndDate(date) : _date = date;

  @override
  DateTime get date => _date;

  @override
  set date(DateTime date) {
    _date = date;
    notifyListeners();
  }
}

class MeetingDateAndTime extends ChangeNotifier implements MeetingDate {
  DateTime _date = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();

  @override
  DateTime get date => _date;

  @override
  set date(DateTime date) {
    _date = date;
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
