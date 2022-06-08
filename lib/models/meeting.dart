import 'package:flutter/material.dart';
import 'package:rivia/constants/fields.dart';
import 'package:rivia/models/date_time_json.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/utilities/change_notifiers.dart';

/// The model for meetings.
class Meeting {
  final String? meetingId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final List<Participant> participants;
  final Map<String, String> painPoints;

  Meeting({
    this.meetingId,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.participants = const [],
    this.painPoints = const {},
  });

  Meeting.fromJson(Map<String, dynamic> json)
      : title = json[Fields.title],
        meetingId = json[Fields.meetingId],
        startTime = DateTimeJson.fromJSON(json[Fields.startTime]),
        endTime = DateTimeJson.fromJSON(json[Fields.endTime]),
        participants = (json[Fields.participantId] as List<dynamic>?)
                ?.map((e) => Participant.fromJson(e))
                .toList() ??
            const [],
        painPoints = {}
            // (json[Fields.painPoints] as Map<String, dynamic>?)?.cast() ??
            //     const {}
  ;

  Map<String, dynamic> toJson() => {
        Fields.title: title,
        Fields.startTime: startTime.toJSON(),
        Fields.endTime: endTime.toJSON(),
        // Fields.painPoints: painPoints,
        Fields.participants: participants.map((e) => e.toJson()).toList(),
        if (meetingId != null) Fields.meetingId: meetingId,
      };
}

/// The builder for [Meeting].

class MeetingBuilder with ChangeNotifier {
  String? _meetingId;
  late String title;
  final MeetingDateAndTime meetingDateAndTime = MeetingDateAndTime();
  final Set<Participant> participants = {};

  String? get meetingId => _meetingId;
  set meetingId(String? value) {
    _meetingId = value;
    notifyListeners();
  }

  /// Build a [Meeting].
  Meeting build() => Meeting(
        title: title,
        startTime: DateTime(
          meetingDateAndTime.date.year,
          meetingDateAndTime.date.month,
          meetingDateAndTime.date.day,
          meetingDateAndTime.startTime.hour,
          meetingDateAndTime.startTime.minute,
        ),
        endTime: DateTime(
          meetingDateAndTime.date.year,
          meetingDateAndTime.date.month,
          meetingDateAndTime.date.day,
          meetingDateAndTime.endTime.hour,
          meetingDateAndTime.endTime.minute,
        ),
        participants: participants.toList(),
      );

  /// Notify the listeners.
  void notify() {
    notifyListeners();
  }
}
