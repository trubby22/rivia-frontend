import 'package:rivia/constants/fields.dart';
import 'package:rivia/models/date_time_json.dart';
import 'package:rivia/models/participant.dart';

/// The model for meetings.
class Meeting {
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final List<Participant> participants;

  Meeting({
    required this.title,
    required this.startTime,
    required this.endTime,
    this.participants = const [],
  });

  Meeting.fromJson(Map<String, dynamic> json)
      : title = json[Fields.title],
        startTime = DateTimeJson.fromJSON(json[Fields.startTime]),
        endTime = DateTimeJson.fromJSON(json[Fields.endTime]),
        participants = (json[Fields.participantId] as List<dynamic>?)
                ?.map((e) => Participant.fromJson(e))
                .toList() ??
            const [];

  Map<String, dynamic> toJson() => {
        Fields.title: title,
        Fields.startTime: startTime.toJSON(),
        Fields.endTime: endTime.toJSON(),
        Fields.participants: participants.map((e) => e.toJson()).toList(),
      };
}
