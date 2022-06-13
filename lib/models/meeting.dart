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
  final String organiserId;
  final List<Participant> participants;
  final Map<String, String> painPoints;

  Meeting({
    this.meetingId,
    required this.title,
    required this.startTime,
    required this.organiserId,
    required this.endTime,
    this.participants = const [],
    this.painPoints = const {},
  });

  static Meeting? fromJson(Map<String, dynamic> json) {
    // Flatten the json if necessary.
    if (json[Fields.meeting] != null) {
      json[Fields.title] = json[Fields.meeting]![Fields.title];
      json[Fields.startTime] = json[Fields.meeting]![Fields.startTime];
      json[Fields.endTime] = json[Fields.meeting]![Fields.endTime];
    }

    try {
      return Meeting(
        title: json[Fields.title],
        meetingId: json[Fields.meetingId],
        startTime: DateTimeJson.fromJSON(json[Fields.startTime]),
        endTime: DateTimeJson.fromJSON(json[Fields.endTime]),
        organiserId: json[Fields.organiserId],
        participants: (json[Fields.participants] as List<dynamic>?)
                ?.map((e) => Participant.fromJson(e))
                .toList() ??
            const [],
        painPoints: Map.fromEntries((json[Fields.painPoints] as List<dynamic>?)
                ?.map((e) => MapEntry(e['preset_q_id'], e['preset_q_text'])) ??
            const []),
      );
    } catch (e) {
      debugPrint("Error on deserialising meeting: $e");
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
        Fields.title: title,
        Fields.startTime: startTime.toJSON(),
        Fields.endTime: endTime.toJSON(),
        Fields.organiserId: organiserId,
        Fields.painPoints: painPoints.entries
            .map(
              (e) => {
                'preset_q_id': e.key,
                'preset_q_text': e.value,
              },
            )
            .toList(),
        Fields.participants: participants.map((e) => e.toJson()).toList(),
        if (meetingId != null) Fields.meetingId: meetingId,
        Fields.meeting: {
          Fields.title: title,
          Fields.startTime: startTime.toJSON(),
          Fields.endTime: endTime.toJSON(),
          Fields.participants: participants.map((e) => e.toJson()).toList(),
        },
      };
}

/// The builder for [Meeting].

class MeetingBuilder with ChangeNotifier {
  String? _meetingId;
  late String title;
  late String organiserId;
  final MeetingDateAndTime meetingDateAndTime = MeetingDateAndTime();
  final Set<Participant> participants = {};

  String? get meetingId => _meetingId;
  set meetingId(String? value) {
    _meetingId = value;
    notifyListeners();
  }

  /// Build a [Meeting].
  Meeting build() => Meeting(
        organiserId: organiserId,
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
